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
CHANGELOG_BODY=$(awk -v ver="$VERSION" '
  index($0, "## [" ver "]") == 1 { found=1; next }
  /^## \[/ { if (found) exit }
  found { print }
' "$CHANGELOG")

if [ -z "$CHANGELOG_BODY" ]; then
  echo "::warning::No changelog section found for v${VERSION}; using placeholder" >&2
  CHANGELOG_BODY="See CHANGELOG.md for details."
fi

# --- Extract issue references from version-bump PR body ---
# Looks for "Issue references: #123, #456, #789" in the PR body
ISSUE_REFS=""
if issue_line=$(printf '%s\n' "$PR_BODY" | grep -i '^Issue references:' | head -1); then
  # Extract just the issue numbers
  ISSUE_REFS=$(printf '%s\n' "$issue_line" | grep -oE '#[0-9]+' | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
fi

# --- Build the release PR body ---
CLOSES_FOOTER=""
if [ -n "$ISSUE_REFS" ]; then
  # Convert "#123, #456" to "Closes #123, closes #456"
  CLOSES_FOOTER=$(printf '%s\n' "$ISSUE_REFS" | sed 's/#\([0-9]*\)/closes #\1/g; s/^closes/Closes/')
fi

PR_BODY_FILE=$(mktemp)
trap 'rm -f "$PR_BODY_FILE"' EXIT

cat > "$PR_BODY_FILE" <<BODY
## Release v${VERSION}

Merges \`dev\` into \`main\` for release v${VERSION}.

> **Merge this PR with a merge commit** (not squash) to preserve the full commit history from \`dev\`.

### Changelog

${CHANGELOG_BODY}
BODY

if [ -n "$CLOSES_FOOTER" ]; then
  cat >> "$PR_BODY_FILE" <<BODY

---
${CLOSES_FOOTER}
BODY
fi

# --- Check for existing release PR ---
# Use exact title matching via jq filter (--search is case-insensitive and could match prefixes).
# Do NOT suppress errors; API failures should surface, not silently create duplicates.
existing_pr=$(gh pr list --base main --state open \
  --json number,title \
  --jq --arg v "release: v${VERSION}" 'first(.[] | select(.title == $v) | .number) // empty')

if [ -n "$existing_pr" ]; then
  echo "::notice::Release PR #${existing_pr} already exists for v${VERSION}; updating body" >&2
  gh pr edit "$existing_pr" --body-file "$PR_BODY_FILE"
  pr_number="$existing_pr"
else
  # Create the PR directly from dev; no new branch needed.
  # dev already contains the version bump, and the PR preserves its full history.
  pr_number=$(gh pr create \
    --base main \
    --head dev \
    --title "release: v${VERSION}" \
    --label release \
    --body-file "$PR_BODY_FILE" \
    --json number \
    --jq '.number') || {
      echo "::error::Failed to create release PR" >&2
      exit 1
    }
  echo "::notice::Created release PR #${pr_number} for v${VERSION}" >&2
fi

# --- Write outputs ---
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=${VERSION}" >> "$GITHUB_OUTPUT"
  echo "pr_number=${pr_number}" >> "$GITHUB_OUTPUT"
fi
