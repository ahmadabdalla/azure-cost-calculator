---
name: github
description: GitHub CLI (gh) commands for repositories, issues, pull requests, and actions. Use when user mentions PRs, issues, CI/CD, workflows, or GitHub operations.
metadata:
  author: ahmadabdalla
  version: "1.0"
---

# GitHub CLI Reference

Use `gh` (GitHub CLI) for all GitHub operations. This skill provides correct command syntax to avoid trial-and-error.

## Authentication

```bash
# Check current auth status
gh auth status

# Login (interactive)
gh auth login

# Refresh token with additional scopes
gh auth refresh -s read:project
```

## Repositories

```bash
# Clone a repository
gh repo clone owner/repo

# Create new repository (interactive)
gh repo create

# Create with flags
gh repo create my-repo --public --description "My project"

# View repo in browser
gh repo view --web

# View repo info in terminal
gh repo view owner/repo

# List your repositories
gh repo list

# List org repositories
gh repo list my-org --limit 50
```

## Issues

```bash
# List open issues
gh issue list

# List with filters
gh issue list --state closed --label "bug" --assignee @me

# Create issue (interactive)
gh issue create

# Create with flags
gh issue create --title "Bug: Login fails" --body "Steps to reproduce..."

# Create with multi-line body (PREFERRED: use file creation tool + --body-file)
# 1. Use the file creation tool (NOT a terminal heredoc) to write the body to a temp file
# 2. Run gh issue create with --body-file pointing to that file
# 3. Clean up the temp file afterward
gh issue create --title "Feature request" --body-file /tmp/issue-body.md
rm -f /tmp/issue-body.md

# WARNING: Do NOT use terminal heredocs (cat << 'EOF') to write the body file.
# Heredocs are fragile in agent/automated contexts — special characters, backticks,
# and markdown formatting corrupt the output. Always use the file creation tool instead.

# RETRY SAFETY: Before retrying a failed gh issue create, verify it didn't
# actually succeed in the background:
# gh issue list --search "exact title" --state open --json number,title

# View issue
gh issue view 123

# View in browser
gh issue view 123 --web

# Close issue
gh issue close 123

# Reopen issue
gh issue reopen 123

# Add comment
gh issue comment 123 --body "Fixed in PR #456"

# Assign issue
gh issue edit 123 --add-assignee @me

# Add labels
gh issue edit 123 --add-label "priority:high"
```

## Pull Requests

### Listing and Viewing

```bash
# List open PRs
gh pr list

# List with filters
gh pr list --state merged --author @me --base main

# View PR details
gh pr view 123

# View in browser
gh pr view 123 --web

# View PR diff
gh pr diff 123

# Check CI status
gh pr checks 123
```

### Creating PRs

```bash
# Create PR (interactive)
gh pr create

# Create with title and body
gh pr create --title "Add feature X" --body "Description here"

# Create with multi-line body (PREFERRED: write to temp file)
cat > /tmp/pr-body.md << 'BODY'
## Summary
- Implement JWT-based authentication
- Add login/logout endpoints

## Test Plan
- [ ] Unit tests pass
- [ ] Manual testing completed

Co-Authored-By: Claude <noreply@anthropic.com>
BODY
gh pr create --title "Add user authentication" --body-file /tmp/pr-body.md

# Create draft PR
gh pr create --draft --title "WIP: New feature"

# Create PR to specific base branch
gh pr create --base develop --title "Feature for develop"

# Create and immediately open in browser
gh pr create --web
```

### Reviewing and Merging

```bash
# Checkout PR locally
gh pr checkout 123

# Approve PR
gh pr review 123 --approve

# Request changes
gh pr review 123 --request-changes --body "Please fix the typo on line 42"

# Comment without approval/rejection
gh pr review 123 --comment --body "Looks good, minor suggestion..."

# Merge PR (default strategy)
gh pr merge 123

# Merge with squash
gh pr merge 123 --squash

# Merge with rebase
gh pr merge 123 --rebase

# Merge and delete branch
gh pr merge 123 --squash --delete-branch

# Close PR without merging
gh pr close 123
```

## Actions (CI/CD)

### Workflow Runs

```bash
# List recent workflow runs
gh run list

# List runs for specific workflow
gh run list --workflow build.yml

# List failed runs only
gh run list --status failure

# View run details
gh run view 12345678

# View with logs
gh run view 12345678 --log

# View failed job logs only
gh run view 12345678 --log-failed

# Watch run in progress
gh run watch 12345678

# Rerun failed jobs
gh run rerun 12345678 --failed
```

### Workflows

```bash
# List all workflows
gh workflow list

# View workflow details
gh workflow view build.yml

# Manually trigger workflow
gh workflow run build.yml

# Trigger with inputs
gh workflow run deploy.yml -f environment=staging -f version=1.2.3

# Disable/enable workflow
gh workflow disable build.yml
gh workflow enable build.yml
```

## Common Workflows

### Quick PR Creation Flow

```bash
# 1. Check current branch status
git status

# 2. Stage and commit changes
git add . && git commit -m "Add feature X"

# 3. Push and create PR in one command
git push -u origin HEAD && gh pr create --fill
```

### Review and Merge Flow

```bash
# 1. Checkout the PR
gh pr checkout 123

# 2. Run tests locally
npm test  # or your test command

# 3. Check CI status
gh pr checks 123

# 4. Approve and merge
gh pr review 123 --approve && gh pr merge 123 --squash --delete-branch
```

### CI Debugging Flow

```bash
# 1. Find failed run
gh run list --status failure --limit 5

# 2. View failed logs
gh run view <run-id> --log-failed

# 3. Rerun after fix
gh run rerun <run-id> --failed
```

## API Access (Advanced)

```bash
# GET request
gh api repos/owner/repo

# POST request
gh api repos/owner/repo/issues --method POST -f title="Bug" -f body="Details"

# GraphQL query
gh api graphql -f query='{ viewer { login } }'

# Paginate results
gh api repos/owner/repo/issues --paginate
```

## Tips

- Use `--help` on any command for full options: `gh pr create --help`
- Use `--json` flag for machine-readable output: `gh pr list --json number,title`
- Set default repo: `gh repo set-default owner/repo`
- Environment variable `GH_TOKEN` can provide auth token
- **Prefer `--body-file`** over heredocs/`--body` for multi-line content — heredocs are fragile in agent and automated contexts (shell quoting, terminal rendering)
- **Verify before retrying create commands** — if a `gh issue create` or `gh pr create` produces ambiguous output, check with `gh issue list --search` or `gh pr list` before running it again to avoid duplicates
