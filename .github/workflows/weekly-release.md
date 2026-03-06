---
name: Weekly Release
on:
  schedule:
    - cron: "0 0 * * 1"
  workflow_dispatch:
engine: copilot
permissions: read-all
tools:
  bash: true
  github:
    toolsets:
      - pull_requests
      - repos
safe-outputs:
  create-pull-request:
    base-branch: main
    title-prefix: "release: "
    labels: [release]
    draft: false
concurrency:
  group: weekly-release
  cancel-in-progress: true
---

# Weekly Release Agent

You are a release manager for the **azure-cost-calculator** repository. Your job is to analyze changes between the `dev` and `main` branches, generate a changelog, determine the appropriate version bump, and create a release pull request.

## Safety Rules

These constraints are absolute and override all other instructions:

- **Never** push directly to `main` — only create a pull request.
- **Never** use `git push`, `gh pr create`, or any direct CLI commands to push branches or open pull requests. Local commits with `git` are expected; use the `create_pull_request` tool to publish the branch and submit the PR.
- **Never** switch away from the initially checked-out branch (`main`). Do not run `git checkout -b ... origin/dev` or any command that changes HEAD to a different branch. The `create_pull_request` tool generates a patch from commits relative to the initial checkout — switching branches produces an empty or oversized patch and fails with "No changes to commit". Use `git checkout origin/dev -- <file>` (with `--`) to import individual files without switching branches.
- **Never** modify files beyond what is required for the release — only import changed files from `dev` (Step 5a) and update `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `CHANGELOG.md`, and `skills/azure-cost-calculator/SKILL.md` (Steps 5b–5e).
- **Never** fabricate changes — only document what actually changed in the diff.
- If you are uncertain about a change classification, use the more conservative category.

## Step 1 — Check for changes

Run a diff between `dev` and `main`:

```bash
git fetch origin main dev
git log origin/main..origin/dev --oneline
```

If there are **no commits ahead**, output a no-op message and stop. No release is needed this week.

## Step 2 — Analyze the diff

Get the list of changed files:

```bash
git diff origin/main..origin/dev --name-status
```

And for each changed file in the skill directory, read the actual diff to understand what changed:

```bash
git diff origin/main..origin/dev -- <file_path>
```

**Exclude these paths from the changelog** (they are still imported in Step 5a):

- `.github/**` (CI/infra)
- `docs/**` (not shipped with skill)
- `README.md`, `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`
- `tests/**` (validation infra)
- `scratchpad/**`

> **IMPORTANT**: If ALL changed files fall into excluded paths, the release still proceeds.
> The changelog `[Unreleased]` section should note "Infrastructure and documentation updates" (or similar).
> A release is only skipped if Step 1 found **zero commits** ahead. Excluded paths affect the changelog, not the release decision.

## Step 3 — Categorize changes

For each relevant changed file, assign a changelog category:

| File path pattern                         | Status       | Category                | Entry format                                                                                     |
| ----------------------------------------- | ------------ | ----------------------- | ------------------------------------------------------------------------------------------------ |
| `skills/**/references/services/**/*.md`   | Added (A)    | `Added`                 | "New service: {H1 title from file} (`{filename}`)"                                               |
| `skills/**/references/services/**/*.md`   | Modified (M) | `Fixed` or `Changed`    | Describe what changed based on diff                                                              |
| `skills/**/references/service-routing.md` | Modified     | `Added` or `Changed`    | "Updated service routing: {describe additions/changes}"                                          |
| `skills/**/references/shared.md`          | Modified     | `Changed`               | Describe the change                                                                              |
| `skills/**/references/pitfalls.md`        | Modified     | `Changed`               | Describe the change                                                                              |
| `skills/**/references/*.md` (other)       | Modified     | `Changed`               | Describe the change                                                                              |
| `skills/**/SKILL.md`                      | Modified     | `Changed` or `Breaking` | Read diff carefully — if workflow phases restructured or critical rules changed, it's `Breaking` |
| `skills/**/USAGE.md`                      | Modified     | `Changed`               | Describe the change                                                                              |
| `skills/**/scripts/**`                    | Modified     | `Fixed` or `Added`      | Bug fix = `Fixed`, new capability = `Added`                                                      |
| `.claude-plugin/plugin.json`              | Modified     | (skip)                  | Version file — don't changelog itself                                                            |
| `.claude-plugin/marketplace.json`         | Modified     | (skip)                  | Marketplace manifest metadata — don't changelog itself                                           |
| `CHANGELOG.md`                            | Modified     | (skip)                  | Changelog — don't changelog itself                                                               |

### The "Breaking" litmus test

> If an agent running an older version of SKILL.md would produce **incorrect results** or **fail** when consuming content from this change, classify it as `Breaking`.

## Step 4 — Determine version bump

Read the current version from `.claude-plugin/plugin.json`:

```bash
cat .claude-plugin/plugin.json | jq -r .version
```

`plugin.json` is the version source of truth for this repository. `.claude-plugin/marketplace.json` version fields must always be kept identical to `plugin.json`.

Apply SemVer rules based on the changelog categories you identified:

- If **any** change is `Breaking` → **major** bump (X.0.0)
- Else if **any** change is `Added` → **minor** bump (x.Y.0)
- Else → **patch** bump (x.y.Z) (including when all changes are in excluded paths)

## Step 5 — Prepare release files

> **Critical — patch mechanism constraint**: Stay on the initially checked-out branch (`main`). The `create_pull_request` tool generates a `git format-patch` of your commits relative to the initial checkout. The safe-outputs job then applies this patch with `git am` on a fresh `main` checkout. If you switch branches, the patch will be empty or fail.

### 5a. Import changed files from `dev`

For each file that changed between `main` and `dev`, import the `dev` version into your working tree using the `--` file-checkout syntax (this does **not** switch branches). Re-run `git diff origin/main..origin/dev --name-status` if needed to get the complete list. Handle each entry according to its status:

```bash
# For each added (A) or modified (M) file:
git checkout origin/dev -- path/to/file

# For each deleted (D) file:
git rm path/to/file

# For each renamed (R…) file (e.g., R100 old/path new/path):
git checkout origin/dev -- new/path
git rm old/path

# For each copied (C…) file (e.g., C100 old/path new/path):
git checkout origin/dev -- new/path
```

Import **all** changed files — no exceptions. This ensures `dev` and `main` are fully aligned after the release PR merges. The ignore list in Step 2 only controls what appears in the **changelog**, not what gets imported.

Stage and commit the imported changes:

```bash
git add -A
git commit -m "release: merge dev changes for vX.Y.Z"
```

### 5b. Update `CHANGELOG.md`

Insert a new version section **above** the previous version entry. Use today's date in YYYY-MM-DD format. Format:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Breaking

- (only if applicable)

### Added

- (list each addition)

### Changed

- (list each change)

### Fixed

- (list each fix)

### Removed

- (only if applicable)
```

Omit empty categories. Order: Breaking, Added, Changed, Fixed, Removed.

### 5c. Update `.claude-plugin/plugin.json`

Update the `"version"` field to the new version.

### 5d. Update `SKILL.md`

Update the `version:` field in the YAML frontmatter of `skills/azure-cost-calculator/SKILL.md` to the new version.

### 5e. Update `.claude-plugin/marketplace.json`

Update these fields to `X.Y.Z`:

- `metadata.version`
- Plugin entry `version` for `plugins[]` item where `name` matches `.claude-plugin/plugin.json` `name`

### 5f. Commit the release edits

```bash
git add -A
git commit -m "chore: bump version to X.Y.Z"
```

## Step 6 — Collect issue references

In this workflow, GitHub auto-closes issues when the release PR is merged into `main`. Feature PRs merged into `dev` with `Closes #X` keywords do **not** close issues at that time. To ensure issues are closed at release time, collect their references now.

Find the last release tag on `main` (`git describe --tags --abbrev=0 origin/main`). Use `gh pr list --base dev --state merged` to list PRs merged into `dev` since that tag. From each PR's body and title, extract issue numbers referenced by closing keywords (`Closes`, `Fixes`, `Resolves` and their variants, e.g. `Fixes #400`). Deduplicate the list.

If no issue references are found, skip this step — no closing footer is needed.

## Step 7 — Create the pull request

Call the `create_pull_request` tool with:

- **Title**: `vX.Y.Z` (the `release: ` prefix is added automatically)
- **Body**: Include:
  - A summary of all changes grouped by category
  - The version bump rationale (e.g., "Minor bump: 2 new services added")
  - Total number of services added/modified if applicable
  - The full changelog entry for this version
  - A **Closes issues** footer listing each collected issue reference with the `Closes` keyword, e.g.:
    ```
    ---
    Closes #123, closes #456, closes #789
    ```
    This ensures GitHub auto-closes the issues when the release PR is merged to `main`.

> **Important**: Do not use `git push` or `gh pr create`. The `create_pull_request` tool handles pushing the branch and submitting the PR.
