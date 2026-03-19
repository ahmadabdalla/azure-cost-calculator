# Weekly Release Automation - Operations Guide

Automated weekly releases using [GitHub Agentic Workflows (gh-aw)](https://github.github.io/gh-aw/introduction/overview/) with the **Copilot** engine.

| Item            | Detail                                                                           |
| --------------- | -------------------------------------------------------------------------------- |
| Workflow source | `.github/workflows/weekly-release.md`                                            |
| Compiled lock   | `.github/workflows/weekly-release.lock.yml`                                      |
| Action pins     | `.github/aw/actions-lock.json`                                                   |
| Engine          | `copilot` (GitHub Copilot)                                                       |
| Trigger         | `schedule: Monday 00:00 UTC` + `workflow_dispatch`                               |
| Companions      | `create-release-pr.yml` (dev → main PR), `create-release.yml` (tag + release)    |

---

## What it does

The release process has three stages, each handled by a separate workflow:

### Stage 1 — Version bump PR to `dev` (weekly-release agent)

Every Monday (or on manual trigger), the agent workflow:

1. **Compares** `dev` and `main` branches to detect changes.
2. **Skips** the release if no commits are ahead (no-op).
3. **Analyzes** the diff to categorize each change (Added, Changed, Fixed, Breaking). Paths like `.github/**`, `docs/**`, `tests/**`, and `scratchpad/**` are excluded from the changelog but still trigger a release (with a generic changelog entry).
4. **Determines** the SemVer bump from changelog categories (Breaking → major, Added → minor, else → patch).
5. **Imports** `.claude-plugin/plugin.json`, `SKILL.md`, and `CHANGELOG.md` from `dev` (the agent is checked out on the default branch), then **updates** them with the new version.
6. **Creates a PR** targeting `dev` with title `version: vX.Y.Z`.

The maintainer reviews and merges the version-bump PR into `dev`.

### Stage 2 — Release PR from `dev` to `main` (create-release-pr.yml)

When the version-bump PR merges to `dev`, `create-release-pr.yml`:

1. **Reads** the version from `.claude-plugin/plugin.json`.
2. **Extracts** the changelog section for that version.
3. **Collects** issue references from the version-bump PR body.
4. **Creates a PR** from `dev` to `main` with title `release: vX.Y.Z` and `Closes` keywords.

> **Important**: This PR must be merged with a **merge commit** (not squash). The merge commit preserves the full commit history from `dev` on `main`, making every individual PR traceable on the main branch.

The maintainer reviews and merges the release PR into `main`.

### Stage 3 — Tag and GitHub Release (create-release.yml)

When the release PR merges to `main`, `create-release.yml`:

1. **Creates** an annotated git tag (`vX.Y.Z`) and pushes it.
2. **Creates** a GitHub Release with the changelog body.

> **Note — no back-merge needed**: Because the version bump happens on `dev` first and `dev` is then merged into `main`, both branches share the same Git ancestry. There is nothing to back-merge.

### Issue auto-closing

GitHub only auto-closes issues (via `Closes #X` keywords) when a PR is merged into the **default branch** (`main`). Feature PRs merged into `dev` with `Closes #X` keywords do **not** close issues.

The flow handles this by:
1. The weekly-release agent collects issue references from merged `dev` PRs and includes them in the version-bump PR body as `Issue references: #X, #Y` (without closing keywords).
2. `create-release-pr.yml` copies these references to the release PR (targeting `main`) with proper `Closes` keywords.
3. Issues are auto-closed when the release PR merges to `main`.

### Change categorization

| File path                                     | Category                        |
| --------------------------------------------- | ------------------------------- |
| `skills/**/references/services/**` (new)      | `Added` — new service reference |
| `skills/**/references/services/**` (modified) | `Fixed` or `Changed`            |
| `skills/**/SKILL.md`                          | `Changed` or `Breaking`         |
| `skills/**/references/service-routing.md`     | `Added` or `Changed`            |
| `skills/**/references/shared.md`, `pitfalls.md` | `Changed`                    |
| `skills/**/USAGE.md`                          | `Changed`                       |
| `skills/**/scripts/**`                        | `Fixed` or `Added`              |
| `.github/**`, `docs/**`, `tests/**`           | Ignored (not in changelog)      |

### Git history model

```
dev:     A---B---C---D---E---F (version bump merged)
                              \
main:    ----prev-release------M (merge commit, preserves A-F ancestry)
```

- `git log main` shows every individual commit from `dev`.
- `git log --first-parent main` shows only merge commits (one per release) for a clean "releases only" view.
- `git merge-base main dev` correctly identifies shared history, so future merges are trivial.

---

## Prerequisites

| Requirement                            | Notes                                                                                                                            |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **`COPILOT_GITHUB_TOKEN`** repo secret | Fine-grained PAT scoped to this repo with the **Copilot Requests** account permission. Required by Stage 1 (agent) only. Stages 2 and 3 use the built-in `GITHUB_TOKEN`. Same token used by issue-triage workflow. |
| **`release` label**                    | Must exist in the repo — applied to both version-bump and release PRs by the workflows.                                          |
| **Actions permissions**                | "Read and write permissions" + "Allow GitHub Actions to create and approve pull requests" in Settings → Actions → General.       |
| **Branch protection**                  | `main` must allow PRs and **merge commits** (not squash-only). `dev` must allow PRs.                                             |
| **gh-aw CLI**                          | Installed via `gh extension install github/gh-aw`. Only needed for compiling changes — not at runtime.                           |

---

## Making changes to the workflows

### Agent workflow (weekly-release.md)

> **Never manually edit** `weekly-release.lock.yml` or `actions-lock.json` — they are overwritten on every compile.

1. Edit `.github/workflows/weekly-release.md`.
2. Compile:
   ```bash
   gh aw compile
   ```
3. Commit **both** the `.md` and the regenerated `.lock.yml` (and `actions-lock.json` if changed).
4. Push / open a PR. The scheduled workflow runs from the **default branch** (`main`), so changes take effect after merge.

### Companion workflows

Edit `.github/workflows/create-release-pr.yml` or `.github/workflows/create-release.yml` directly — they are standard YAML workflows with no compilation step.

### Helper scripts

Scripts in `.github/scripts/release/`:

| Script                    | Purpose                                          |
| ------------------------- | ------------------------------------------------ |
| `extract-version.sh`     | Reads and validates version from plugin.json     |
| `extract-changelog.sh`   | Extracts changelog section for a given version (exits 1 if not found; used by Stage 3) |
| `create-tag-and-release.sh` | Creates annotated git tag and GitHub Release  |
| `create-release-pr.sh`   | Creates the release PR from dev to main (falls back to placeholder if changelog section missing) |

---

## Triggering an out-of-band release

For critical fixes that can't wait until Monday:

1. **Trigger the agent** (Stage 1):
   ```bash
   gh workflow run weekly-release.lock.yml
   ```
   Or use the GitHub UI: Actions → Weekly Release → Run workflow.
2. **Review and merge** the version-bump PR into `dev` (Stage 1 output).
3. **Wait** for `create-release-pr.yml` to auto-create the release PR from `dev` → `main` (Stage 2).
4. **Review and merge** the release PR into `main` with a **merge commit** (Stage 2 output).
5. `create-release.yml` runs automatically to tag and publish the GitHub Release (Stage 3).

---

## Monitoring & troubleshooting

### Viewing runs

```bash
# Weekly release agent
gh run list --workflow=weekly-release.lock.yml --limit 10

# Release PR creation
gh run list --workflow=create-release-pr.yml --limit 10

# Tag and release
gh run list --workflow=create-release.yml --limit 10
```

### Inspecting a failed run

```bash
gh run view <run-id> --log-failed
```

### Common failure modes

| Symptom                                  | Likely cause                                                    | Fix                                                                                     |
| ---------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Workflow never triggers                  | Edited `.md` but forgot to compile, or changes not on `main`   | Run `gh aw compile`, merge to `main`                                                    |
| `401 Unauthorized` in agent job          | `COPILOT_GITHUB_TOKEN` expired or revoked                      | Rotate the PAT (see issue-triage ops doc)                                               |
| Agent creates PR with wrong version      | Changelog parsing or version detection logic needs tuning       | Edit categorization rules in `weekly-release.md`, recompile                             |
| No PR created when changes exist         | Agent classified all changes as ignorable (CI/docs only)        | Check agent logs — may need to adjust ignore rules                                      |
| Release PR not created after version bump | `create-release-pr.yml` trigger didn't match PR title prefix   | Verify version-bump PR title starts with `version: `                                    |
| Release PR fails validation              | Service reference changes have validation errors                | Fix on `dev`, wait for next release or trigger manual dispatch                          |
| Tag already exists                       | Version in `.claude-plugin/plugin.json` wasn't bumped correctly | Check `create-release.yml` logs — it guards against duplicate tags                      |
| History not preserved on main            | Release PR was squash-merged instead of merge-committed         | Branch protection on `main` should enforce merge commits for release PRs                |
| Release PR shows conflicts               | `main` has commits not in `dev` (shouldn't happen normally)     | Merge `main` into `dev` first, then re-run the release                                  |
| Duplicate release PR created             | Two version-bump PRs merged in rapid succession                 | `create-release-pr.sh` checks for existing open PRs by title; merge or close the duplicate |
| Manual dispatch cancels scheduled run    | `concurrency: cancel-in-progress: true` on the agent workflow   | Expected behavior; the manual run replaces the scheduled one                            |

### Job architecture

The compiled lock file produces the standard gh-aw job chain:

```
activation → agent → detection → safe_outputs → conclusion
```

- **activation**: Sets up the workflow context.
- **agent**: Copilot analyzes the diff and prepares version bump files (read-only + bash). Checked out on the default branch (`main`); imports version files from `origin/dev` before editing.
- **detection**: Threat-scans the agent output.
- **safe_outputs**: Checks out `dev` (the `base-branch`), applies the agent's patch, creates the version-bump PR (only job with write access).
- **conclusion**: Reports final status.

The companion workflows run separately:

```
create-release-pr.yml:  version-bump PR merged to dev  →  create release PR (dev → main)
create-release.yml:     release PR merged to main      →  tag + GitHub Release
```

---

## Upgrading gh-aw

```bash
gh extension upgrade github/gh-aw
gh aw compile
```

Commit the updated lock files after upgrading.

---

## References

- [gh-aw overview](https://github.github.io/gh-aw/introduction/overview/) — GitHub Agentic Workflows engine
- [DailyOps pattern](https://github.github.io/gh-aw/patterns/daily-ops/) — the scheduling pattern this workflow uses
- [issue-triage ops doc](issue-triage.md) — companion agentic workflow in this repo
- [Keep a Changelog](https://keepachangelog.com/) — changelog format used
- [Semantic Versioning](https://semver.org/) — versioning scheme
