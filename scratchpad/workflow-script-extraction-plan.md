# Workflow Inline Script Extraction Plan

## Problem Statement

GitHub Actions workflows in `.github/workflows/` contain significant inline shell scripts
embedded in `run:` blocks. This makes them:

- **Hard to test locally** — inline scripts can't be executed or debugged outside CI
- **Hard to lint** — ShellCheck, PSScriptAnalyzer, etc. can't target YAML-embedded code
- **Hard to reuse** — duplicated logic across steps can't be shared
- **Hard to review** — long YAML files with embedded multi-line scripts obscure workflow structure

**Goal:** Extract inline scripts into standalone files under `.github/scripts/`, keeping workflows
as thin orchestration layers that call external scripts.

---

## Current State Inventory

### Workflow Files

| Workflow                          | Type                       | Jobs | Inline `run:` Steps | Inline Script Lines | External Scripts Already Referenced                              |
| --------------------------------- | -------------------------- | ---- | ------------------- | ------------------- | ---------------------------------------------------------------- |
| `create-release.yml`              | Hand-authored              | 2    | 7                   | ~126                | None                                                             |
| `unit-tests.yml`                  | Hand-authored              | 2    | 7                   | ~18                 | `tests/unit/Run-PesterTests.ps1`, `tests/unit/run-bats-tests.sh` |
| `validate-service-references.yml` | Hand-authored              | 1    | 5                   | ~69                 | `tests/Validate-ServiceReference.ps1`                            |
| `issue-triage.lock.yml`           | **Auto-generated** (gh-aw) | 5    | 26                  | ~387                | Framework scripts at `/opt/gh-aw/actions/`                       |
| `weekly-release.lock.yml`         | **Auto-generated** (gh-aw) | 5    | 27                  | ~385                | Framework scripts at `/opt/gh-aw/actions/`                       |

### Key Finding: Lock Files Are Out of Scope

`issue-triage.lock.yml` and `weekly-release.lock.yml` are **auto-generated** by `gh aw compile`
from their companion `.md` files. They carry a `DO NOT EDIT` header. Any manual changes would be
overwritten on the next compile. These workflows are **excluded from this migration**.

### Existing Script Layout

```
skills/azure-cost-calculator/scripts/    # Skill scripts (PowerShell + Bash parity)
  lib/                                   # Shared library functions
tests/                                   # Validation + unit test scripts
  Validate-ServiceReference.ps1
  unit/Run-PesterTests.ps1
  unit/run-bats-tests.sh
  lib/validation/                        # PowerShell validation library
```

**No `.github/scripts/` directory exists today.**

### Language Conventions

- **Bash** — used for CI workflow steps, git operations, release tooling
- **PowerShell (pwsh)** — used for validation, test execution, linting
- Naming: Bash uses `kebab-case.sh`, PowerShell uses `Verb-Noun.ps1`

---

## Proposed Target Layout

Following GitHub Actions best practices (see [GitHub Docs: Adding scripts to your workflow](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/add-scripts)):

```
.github/
  scripts/
    release/
      extract-version.sh          # Extract + validate semver from plugin.json
      extract-changelog.sh        # Extract changelog section for a given version
      create-tag-and-release.sh   # Create annotated git tag + GitHub release
      back-merge.sh               # Retry-loop merge of main → dev
      create-backmerge-pr.sh      # Fallback PR when back-merge fails
    validate/
      detect-change-scope.sh      # Git diff detection for service/infra changes
      run-validation.ps1          # Wrapper to invoke Validate-ServiceReference.ps1
    test/
      install-pester.ps1          # Install Pester + PSScriptAnalyzer modules
      run-script-analyzer.ps1     # PSScriptAnalyzer lint check
      install-bats.sh             # Install bats-core + jq
  workflows/
    create-release.yml            # (simplified — calls scripts)
    unit-tests.yml                # (simplified — calls scripts)
    validate-service-references.yml  # (simplified — calls scripts)
    issue-triage.lock.yml         # (unchanged — auto-generated)
    issue-triage.md               # (unchanged — gh-aw source)
    weekly-release.lock.yml       # (unchanged — auto-generated)
    weekly-release.md             # (unchanged — gh-aw source)
```

---

## Extraction Plan by Workflow

### 1. `create-release.yml` — **High Priority** (126 lines inline, most complex)

This workflow has the most to gain from extraction. It contains two jobs with substantial logic.

#### Job: `release` (Tag and release)

| Step                               | Current Lines | Action                                   | Target Script                                                |
| ---------------------------------- | ------------- | ---------------------------------------- | ------------------------------------------------------------ |
| Extract version from plugin.json   | 15            | **Extract**                              | `.github/scripts/release/extract-version.sh`                 |
| Check tag does not already exist   | 4             | **Merge into extract-version.sh**        | (above — add tag-exists check as part of version validation) |
| Extract changelog for this version | 6             | **Extract**                              | `.github/scripts/release/extract-changelog.sh`               |
| Create tag                         | 4             | **Merge into create-tag-and-release.sh** | `.github/scripts/release/create-tag-and-release.sh`          |
| Create GitHub Release              | 3             | **Merge into create-tag-and-release.sh** | (above — combines tag creation + release creation)           |

**Script details:**

**`extract-version.sh`** — Accepts plugin.json path as argument, validates JSON, validates
semver format, checks git tag doesn't already exist, outputs version string. Exit codes: 0 success,
1 validation failure.

**`extract-changelog.sh`** — Accepts version string and CHANGELOG.md path, extracts the matching
section using awk, writes to a specified output file. Exit codes: 0 success, 1 no section found.

**`create-tag-and-release.sh`** — Accepts version string and release notes file path, configures
git identity, creates annotated tag, pushes tag, creates GitHub release via `gh`. Requires `GH_TOKEN`
env var. Exit codes: 0 success, 1 failure.

#### Job: `back-merge` (Merge main back to dev)

| Step                        | Current Lines | Action      | Target Script                                    |
| --------------------------- | ------------- | ----------- | ------------------------------------------------ |
| Merge main into dev         | 67            | **Extract** | `.github/scripts/release/back-merge.sh`          |
| Create PR on merge conflict | 27            | **Extract** | `.github/scripts/release/create-backmerge-pr.sh` |

**Script details:**

**`back-merge.sh`** — Contains the full 3-attempt retry loop with `merge_and_push()` helper
function. Accepts no arguments (operates on current repo). Outputs `result` and `fallback_reason`
to `$GITHUB_OUTPUT`. Exit code always 0 (result communicated via outputs).

**`create-backmerge-pr.sh`** — Accepts `fallback_reason` and `run_id` as arguments (or env vars).
Checks for existing back-merge PR, creates/updates branch from origin/main, creates or updates PR.
Requires `GH_TOKEN` env var.

#### Resulting workflow YAML (approximate)

```yaml
# release job steps become:
- run: |
    version=$(.github/scripts/release/extract-version.sh .claude-plugin/plugin.json)
    echo "version=$version" >> "$GITHUB_OUTPUT"
  id: version

- run: .github/scripts/release/extract-changelog.sh "${{ steps.version.outputs.version }}" CHANGELOG.md /tmp/release-body.md

- run: .github/scripts/release/create-tag-and-release.sh "${{ steps.version.outputs.version }}" /tmp/release-body.md
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# back-merge job steps become:
- run: .github/scripts/release/back-merge.sh
  id: merge

- if: steps.merge.outputs.result == 'conflict'
  run: .github/scripts/release/create-backmerge-pr.sh
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    FALLBACK_REASON: ${{ steps.merge.outputs.fallback_reason }}
    RUN_ID: ${{ github.run_id }}
```

---

### 2. `validate-service-references.yml` — **Medium Priority** (69 lines inline)

#### Job: `validate`

| Step                               | Current Lines | Shell | Action                            | Target Script                                     |
| ---------------------------------- | ------------- | ----- | --------------------------------- | ------------------------------------------------- |
| Skip notice                        | 1             | bash  | **Keep inline**                   | N/A (trivial echo)                                |
| Detect change scope                | 35            | bash  | **Extract**                       | `.github/scripts/validate/detect-change-scope.sh` |
| Validate changed service files     | 14            | pwsh  | **Extract**                       | `.github/scripts/validate/run-validation.ps1`     |
| Validate all service files (infra) | 13            | pwsh  | **Merge into run-validation.ps1** | (above — parameterize mode)                       |
| Validate routing file sync         | 6             | pwsh  | **Merge into run-validation.ps1** | (above — parameterize mode)                       |

**Script details:**

**`detect-change-scope.sh`** — Accepts `DIFF_BASE`, `DIFF_HEAD`, and `SERVICES_ROOT` as env vars.
Runs git diff to detect changed service files and infrastructure files. Writes `service_changed`,
`infra_changed`, and `all_changed_files` to `$GITHUB_OUTPUT`.

**`run-validation.ps1`** — A unified PowerShell wrapper that accepts a `-Mode` parameter:

- `ChangedOnly` — validates only the files listed in `-ChangedFiles`
- `Full` — validates all .md files under services root
- `RoutingSyncOnly` — validates routing file sync against any single file

This consolidates the three separate pwsh `run:` blocks into one parameterized script that
delegates to `tests/Validate-ServiceReference.ps1`.

#### Resulting workflow YAML (approximate)

```yaml
- run: .github/scripts/validate/detect-change-scope.sh
  id: changed
  shell: bash
  env:
    DIFF_BASE: ${{ github.event.pull_request.base.sha }}
    DIFF_HEAD: ${{ github.event.pull_request.head.sha }}
    SERVICES_ROOT: ${{ env.SERVICES_ROOT }}

- if: # service changed, no infra change
  run: >
    pwsh .github/scripts/validate/run-validation.ps1
    -Mode ChangedOnly
    -ChangedFiles "${{ steps.changed.outputs.all_changed_files }}"
  shell: pwsh

- if: # infra changed
  run: >
    pwsh .github/scripts/validate/run-validation.ps1
    -Mode Full
  shell: pwsh

- if: # neither changed (deletion edge case)
  run: >
    pwsh .github/scripts/validate/run-validation.ps1
    -Mode RoutingSyncOnly
  shell: pwsh
```

---

### 3. `unit-tests.yml` — **Low Priority** (18 lines inline, already well-structured)

This workflow is already well-factored — test execution delegates to external scripts. The remaining
inline code is mostly CI setup boilerplate (install dependencies, skip notices).

| Step                              | Current Lines | Shell | Action          | Target Script                                  |
| --------------------------------- | ------------- | ----- | --------------- | ---------------------------------------------- |
| Skip notice (×2)                  | 1 each        | bash  | **Keep inline** | N/A                                            |
| Install Pester + PSScriptAnalyzer | 5             | pwsh  | **Extract**     | `.github/scripts/test/install-pester.ps1`      |
| Run PSScriptAnalyzer              | 6             | pwsh  | **Extract**     | `.github/scripts/test/run-script-analyzer.ps1` |
| Run Pester tests                  | 1             | pwsh  | **Keep inline** | N/A (already calls external script)            |
| Install bats-core + jq            | 3             | bash  | **Extract**     | `.github/scripts/test/install-bats.sh`         |
| Run bats tests                    | 1             | bash  | **Keep inline** | N/A (already calls external script)            |

**Note:** The extraction here is optional. These are small, stable setup scripts. The primary
benefit is allowing local execution of the install/lint steps for debugging.

---

### 4. `issue-triage.lock.yml` — **Out of Scope**

Auto-generated by `gh aw compile` from `issue-triage.md`. Marked `DO NOT EDIT`.
No action needed — the `gh-aw` framework already manages its own script extraction via
`/opt/gh-aw/actions/*.sh`.

### 5. `weekly-release.lock.yml` — **Out of Scope**

Auto-generated by `gh aw compile` from `weekly-release.md`. Marked `DO NOT EDIT`.
Same as above — managed by the `gh-aw` framework.

---

## Implementation Approach

### Phase 1: Create `.github/scripts/` Directory + Release Scripts

**Why first:** `create-release.yml` has the most complex inline logic (126 lines, including the
67-line back-merge retry loop). This is the highest-value extraction.

1. Create `.github/scripts/release/` directory
2. Extract 5 scripts from `create-release.yml`
3. Set executable permissions (`chmod +x`)
4. Update `create-release.yml` to call the scripts
5. Test: run ShellCheck on all extracted scripts
6. Test: verify workflow still works via manual trigger or PR simulation

**Scripts to create (in order):**

- `extract-version.sh` (~20 lines)
- `extract-changelog.sh` (~10 lines)
- `create-tag-and-release.sh` (~15 lines)
- `back-merge.sh` (~70 lines)
- `create-backmerge-pr.sh` (~35 lines)

### Phase 2: Validate Service References Scripts

1. Create `.github/scripts/validate/` directory
2. Extract `detect-change-scope.sh` from the bash step
3. Create `run-validation.ps1` unifying the three pwsh steps
4. Update `validate-service-references.yml`
5. Test: run ShellCheck on bash script, PSScriptAnalyzer on ps1

### Phase 3: Unit Tests Setup Scripts (Optional)

1. Create `.github/scripts/test/` directory
2. Extract `install-pester.ps1`, `run-script-analyzer.ps1`, `install-bats.sh`
3. Update `unit-tests.yml`
4. Test locally

---

## Script Conventions

Based on existing repo conventions and GitHub Actions best practices:

| Convention            | Rule                                                                                  |
| --------------------- | ------------------------------------------------------------------------------------- |
| **Location**          | `.github/scripts/<category>/`                                                         |
| **Bash naming**       | `kebab-case.sh` (matches existing repo convention)                                    |
| **PowerShell naming** | `Verb-Noun.ps1` (matches existing repo convention)                                    |
| **Permissions**       | All `.sh` files must be `chmod +x` (committed via `git update-index --chmod=+x`)      |
| **Error handling**    | All bash scripts start with `set -euo pipefail`                                       |
| **Inputs**            | Prefer environment variables over positional args for GitHub Actions context values   |
| **Outputs**           | Write to `$GITHUB_OUTPUT` for step outputs (scripts must be aware of CI context)      |
| **Secrets**           | Never hardcode; pass via `env:` in the workflow YAML                                  |
| **Shebang**           | `#!/usr/bin/env bash` for bash, no shebang needed for PowerShell (invoked via `pwsh`) |
| **Documentation**     | Each script starts with a comment block: purpose, inputs, outputs, exit codes         |
| **Linting**           | Bash: ShellCheck clean. PowerShell: PSScriptAnalyzer clean (Error/Warning level)      |

---

## Verification Checklist

For each extracted script:

- [ ] Script runs successfully when invoked standalone (with mock env vars)
- [ ] ShellCheck (bash) or PSScriptAnalyzer (pwsh) passes with no errors/warnings
- [ ] Workflow YAML references the script with correct relative path
- [ ] Script has executable permission in git (`git ls-files -s` shows `100755`)
- [ ] `actions/checkout` step exists before any script invocation
- [ ] All required env vars / secrets are mapped in the workflow `env:` block
- [ ] Step outputs (`$GITHUB_OUTPUT`) are still correctly emitted and consumed

---

## Risk Considerations

| Risk                                     | Mitigation                                                                                  |
| ---------------------------------------- | ------------------------------------------------------------------------------------------- |
| Breaking the release workflow            | Test on a feature branch with a mock `release:` PR first                                    |
| Missing environment variables            | Each script validates required env vars at startup                                          |
| File permission issues on runners        | Commit with `git update-index --chmod=+x`; no runtime `chmod` needed                        |
| Lock file workflows accidentally touched | Clearly marked out of scope; `.lock.yml` files left untouched                               |
| Back-merge logic regression              | The back-merge script is the most complex extraction — add integration test or dry-run mode |

---

## Summary

| Metric                                          | Before                                              | After                                    |
| ----------------------------------------------- | --------------------------------------------------- | ---------------------------------------- |
| Hand-authored inline script lines               | ~213                                                | ~10 (echo notices + 1-line script calls) |
| Testable script files                           | 0 (in `.github/`)                                   | 10 new scripts                           |
| Workflows with complex inline logic             | 2 (`create-release`, `validate-service-references`) | 0                                        |
| Scripts lintable by ShellCheck/PSScriptAnalyzer | 0 (embedded in YAML)                                | 10                                       |
