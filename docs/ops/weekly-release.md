# Weekly Release Automation - Operations Guide

Automated weekly releases using [GitHub Agentic Workflows (gh-aw)](https://github.github.io/gh-aw/introduction/overview/) with the **Copilot** engine.

| Item            | Detail                                                                 |
| --------------- | ---------------------------------------------------------------------- |
| Workflow source | `.github/workflows/weekly-release.md`                                  |
| Compiled lock   | `.github/workflows/weekly-release.lock.yml`                            |
| Action pins     | `.github/aw/actions-lock.json`                                         |
| Engine          | `copilot` (GitHub Copilot)                                             |
| Trigger         | `schedule: Monday 00:00 UTC` + `workflow_dispatch`                     |
| Companion       | `.github/workflows/create-release.yml` (tag + GitHub Release on merge) |

---

## What it does

Every Monday (or on manual trigger), the workflow:

1. **Compares** `dev` and `main` branches to detect changes.
2. **Skips** the release if no commits are ahead (no-op).
3. **Analyzes** the diff to categorize each change (Added, Changed, Fixed, Breaking).
4. **Determines** the SemVer bump from changelog categories (Breaking → major, Added → minor, else → patch).
5. **Updates** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `SKILL.md` frontmatter, and `CHANGELOG.md` with the new version.
6. **Creates a draft PR** targeting `main` with title `release: vX.Y.Z`.

The maintainer reviews and merges the PR. On merge, `create-release.yml`:

1. **Creates** a git tag and GitHub Release automatically.
2. **Back-merges** `main` into `dev` so version bumps and changelog updates flow back. The workflow retries race conditions when `dev` moves and, on conflict, retries with `-X theirs` (favoring `main` for conflicting hunks). If conflict remains, it opens a PR from a dedicated back-merge branch (never from `main`) for manual resolution.

> **Marketplace versioning policy**
>
> `.claude-plugin/marketplace.json` supports optional `metadata.version` and plugin-entry `version` fields. This repository includes both and requires them to stay aligned with `.claude-plugin/plugin.json` on every release. `plugin.json` remains the source of truth; marketplace versions mirror it.
> **Note — Issue auto-closing and the `dev` branch**
>
> GitHub only auto-closes issues (via `Closes #X` keywords) when a PR is merged into the **default branch** (`main`). Feature PRs merged into `dev` will **not** auto-close linked issues, even if their description contains closing keywords — GitHub ignores them entirely for non-default branches.
>
> The weekly release agent handles this by collecting issue references from merged `dev` PRs (Step 6) and including `Closes #X` keywords in the release PR body. Since the release PR targets `main`, the issues are auto-closed when the release merges.

### Change categorization

| File path                                     | Category                        |
| --------------------------------------------- | ------------------------------- |
| `skills/**/references/services/**` (new)      | `Added` — new service reference |
| `skills/**/references/services/**` (modified) | `Fixed` or `Changed`            |
| `skills/**/SKILL.md`                          | `Changed` or `Breaking`         |
| `skills/**/scripts/**`                        | `Fixed` or `Added`              |
| `.github/**`, `docs/**`, `tests/**`           | Ignored (not in changelog)      |

---

## Prerequisites

| Requirement                            | Notes                                                                                                                            |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **`COPILOT_GITHUB_TOKEN`** repo secret | Fine-grained PAT scoped to this repo with the **Copilot Requests** account permission. Same token used by issue-triage workflow. |
| **`release` label**                    | Must exist in the repo — applied to release PRs by the workflow.                                                                 |
| **Actions permissions**                | "Read and write permissions" + "Allow GitHub Actions to create and approve pull requests" in Settings → Actions → General.       |
| **Branch protection**                  | `main` must allow PRs (release PR). `dev` must allow PRs (back-merge fallback).                                                  |
| **gh-aw CLI**                          | Installed via `gh extension install github/gh-aw`. Only needed for compiling changes — not at runtime.                           |

---

## Making changes to the workflow

> **Never manually edit** `weekly-release.lock.yml` or `actions-lock.json` — they are overwritten on every compile.

1. Edit `.github/workflows/weekly-release.md`.
2. Compile:
   ```bash
   gh aw compile
   ```
3. Commit **both** the `.md` and the regenerated `.lock.yml` (and `actions-lock.json` if changed).
4. Push / open a PR. The scheduled workflow runs from the **default branch** (`dev`), so changes take effect after merge.

---

## Triggering an out-of-band release

For critical fixes that can't wait until Monday:

```bash
gh workflow run weekly-release.lock.yml
```

Or use the GitHub UI: Actions → Weekly Release → Run workflow.

---

## Monitoring & troubleshooting

### Viewing runs

```bash
gh run list --workflow=weekly-release.lock.yml --limit 10
```

### Inspecting a failed run

```bash
gh run view <run-id> --log-failed
```

### Common failure modes

| Symptom                                  | Likely cause                                                                  | Fix                                                                                                                                                               |
| ---------------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Workflow never triggers                  | Edited `.md` but forgot to compile, or changes not on `dev`                   | Run `gh aw compile`, merge to `dev`                                                                                                                               |
| `401 Unauthorized` in agent job          | `COPILOT_GITHUB_TOKEN` expired or revoked                                     | Rotate the PAT (see issue-triage ops doc)                                                                                                                         |
| Agent creates PR with wrong version      | Changelog parsing or version detection logic needs tuning                     | Edit categorization rules in `weekly-release.md`, recompile                                                                                                       |
| No PR created when changes exist         | Agent classified all changes as ignorable (CI/docs only)                      | Check agent logs — may need to adjust ignore rules                                                                                                                |
| Release PR fails validation              | Service reference changes in the release have validation errors               | Fix on `dev`, wait for next release or trigger manual dispatch                                                                                                    |
| Tag already exists                       | Version in `.claude-plugin/plugin.json` wasn't bumped correctly               | Check `create-release.yml` logs — it guards against duplicate tags                                                                                                |
| Release job fails before tag step        | Marketplace versions drift from `.claude-plugin/plugin.json`                  | Ensure `.claude-plugin/marketplace.json` `metadata.version` and matching plugin-entry `version` equal `.claude-plugin/plugin.json`                                |
| Back-merge fails with conflict           | `dev` diverged from `main` and auto-resolution was insufficient               | Resolve the generated back-merge PR (head: `backmerge-main-to-dev-*`) so fixes are not committed to `main`                                                        |
| Back-merge PR already open               | Previous fallback PR is still open from an earlier run                        | The workflow refreshes the existing PR branch to the latest `main`; review and merge that updated PR                                                              |
| Manual back-merge PR despite no conflict | Repeated fetch failures or API/permission/rate-limit issues during back-merge | Inspect back-merge logs for fetch/permission errors, retry the workflow, verify runner network and token/rate limits, or merge `backmerge-main-to-dev-*` manually |

### Job architecture

The compiled lock file produces the standard gh-aw job chain:

```
pre_activation → activation → agent → detection → safe_outputs → conclusion
```

- **activation**: Sets up the workflow context.
- **agent**: Copilot analyzes the diff and prepares release files (read-only + bash).
- **detection**: Threat-scans the agent output.
- **safe_outputs**: Creates the PR targeting `main` (only job with write access).
- **conclusion**: Reports final status.

The companion `create-release.yml` runs separately, triggered by the merged PR:

```
release → back-merge
```

- **release**: Creates a git tag and GitHub Release from the merged PR.
- **back-merge**: Merges `main` back into `dev`, retries push races, retries conflicts with `-X theirs`, and only then opens a dedicated back-merge PR.

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
