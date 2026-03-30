#!/usr/bin/env bash
# Purpose:  Create a release pull request from dev to main after a version-bump PR merges.
#           The release PR is a true descendant of dev, so merging it with a merge commit
#           preserves the full dev branch history on main.
# Inputs:   PR_BODY     = body of the merged version-bump PR (env var, required)
#           GH_TOKEN    = GitHub token with contents:read + pull-requests:write (env var, required)
#           PLUGIN_JSON = path to plugin.json (env var, default: .claude-plugin/plugin.json)
#           CHANGELOG   = path to CHANGELOG.md (env var, default: CHANGELOG.md)
# Outputs:  Writes to $GITHUB_OUTPUT:
#             version    = the version string (e.g. 1.5.0)
#             pr_number  = the created PR number
# Exit codes:
#   0 = success
#   1 = missing required input or version extraction failure

set -euo pipefail

if [ -z "${GH_TOKEN:-}" ]; then
  echo "::error::GH_TOKEN environment variable is required" >&2
  exit 1
fi

if [ -z "${PR_BODY:-}" ]; then
  echo "::error::PR_BODY environment variable is required" >&2
  exit 1
fi

PLUGIN_JSON="${PLUGIN_JSON:-.claude-plugin/plugin.json}"
CHANGELOG="${CHANGELOG:-CHANGELOG.md}"

# --- Extract and validate version ---
# jq -e exits non-zero for null/false but not for empty string; the explicit
# empty check below is intentional and must not be removed.
if ! VERSION=$(jq -er '.version' "$PLUGIN_JSON"); then
  echo "::error::Failed to read '.version' from $PLUGIN_JSON" >&2
  exit 1
fi

if [ -z "$VERSION" ]; then
  echo "::error::Version is empty in $PLUGIN_JSON" >&2
  exit 1
fi

if ! [[ "$VERSION" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$ ]]; then
  echo "::error::Version '$VERSION' is not valid semver (expected: X.Y.Z, e.g. 1.2.3)" >&2
  exit 1
fi

echo "::notice::Detected version: $VERSION" >&2

# --- Extract changelog section ---
# Allocate and protect both temp files before doing any work that could fail.
CHANGELOG_TMP=$(mktemp)
trap 'rm -f "$CHANGELOG_TMP" "${PR_BODY_FILE:-}"' EXIT
PR_BODY_FILE=$(mktemp)

# Delegate to extract-changelog.sh; on failure (section not found or any other
# error) fall back to a placeholder so the release PR is still created.
if bash "$(dirname -- "$0")/extract-changelog.sh" "$VERSION" "$CHANGELOG" "$CHANGELOG_TMP"; then
  CHANGELOG_BODY=$(cat "$CHANGELOG_TMP")
else
  echo "::warning::No changelog section found for v${VERSION}; using placeholder" >&2
  CHANGELOG_BODY="See CHANGELOG.md for details."
fi

# --- Extract issue references from version-bump PR body ---
# Looks for "Issue references: #123, #456, #789" in the PR body.
ISSUE_REFS=""
if issue_line=$(printf '%s\n' "$PR_BODY" | grep -i '^Issue references:' | head -1); then
  ISSUE_REFS=$(printf '%s\n' "$issue_line" | grep -oE '#[0-9]+' | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
fi

# --- Build the release PR body ---
# Use a quoted heredoc (<<'BODY') for static structure to prevent shell expansion
# of changelog or footer content, which is partially attacker-influenced.
# Dynamic values are appended separately with printf.
CLOSES_FOOTER=""
if [ -n "$ISSUE_REFS" ]; then
  # Convert "#123, #456" to "Closes #123, closes #456"
  CLOSES_FOOTER=$(printf '%s\n' "$ISSUE_REFS" | sed 's/#\([0-9]*\)/closes #\1/g; s/^closes/Closes/')
fi

{
  printf '## Release v%s\n\n' "$VERSION"
  printf 'Merges `dev` into `main` for release v%s.\n\n' "$VERSION"
  printf '> **Merge this PR with a merge commit** (not squash) to preserve the full commit history from `dev`.\n\n'
  printf '### Changelog\n\n'
  printf '%s\n' "$CHANGELOG_BODY"
} > "$PR_BODY_FILE"

if [ -n "$CLOSES_FOOTER" ]; then
  printf '\n---\n%s\n' "$CLOSES_FOOTER" >> "$PR_BODY_FILE"
fi

# --- Check for existing release PR ---
# Use exact title matching via jq filter (--search is case-insensitive and could match prefixes).
# Explicit error guard: a gh API failure must surface as a clear error, not silently
# fall through to the create path and create a duplicate PR.
if ! gh_pr_list_output=$(gh pr list --base main --state open --json number,title); then
  echo "::error::Failed to query open PRs from GitHub API" >&2
  exit 1
fi
existing_pr=$(printf '%s\n' "$gh_pr_list_output" \
  | jq -r --arg v "release: v${VERSION}" 'first(.[] | select(.title == $v) | .number) // empty')

if [ -n "$existing_pr" ]; then
  echo "::notice::Release PR #${existing_pr} already exists for v${VERSION}; updating body" >&2
  gh pr edit "$existing_pr" --body-file "$PR_BODY_FILE"
  pr_number="$existing_pr"
else
  # Create the PR directly from dev; no new branch needed.
  # dev already contains the version bump, and the PR preserves its full history.
  pr_url=$(gh pr create \
    --base main \
    --head dev \
    --title "release: v${VERSION}" \
    --label release \
    --body-file "$PR_BODY_FILE") || {
      echo "::error::Failed to create release PR" >&2
      exit 1
    }
  pr_number=$(printf '%s\n' "$pr_url" | grep -oE 'pull/[0-9]+' | head -1 | grep -oE '[0-9]+' || true)
  if [ -z "$pr_number" ]; then
    echo "::error::Could not extract PR number from gh output: $pr_url" >&2
    exit 1
  fi
  echo "::notice::Created release PR #${pr_number} for v${VERSION}" >&2
fi

# --- Write outputs ---
# Use the HEREDOC delimiter format to prevent newline injection into GITHUB_OUTPUT.
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    printf 'version<<_EOF\n%s\n_EOF\n' "$VERSION"
    printf 'pr_number<<_EOF\n%s\n_EOF\n' "$pr_number"
  } >> "$GITHUB_OUTPUT"
fi
