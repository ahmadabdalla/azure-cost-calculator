#!/usr/bin/env bash
# Purpose:  Create an annotated git tag and publish a GitHub Release.
# Inputs:   $1       = version string (required, e.g. 1.2.3)
#           $2       = path to release notes file (required, e.g. /tmp/release-body.md)
#           GH_TOKEN = GitHub token with contents:write permission (required env var)
# Outputs:  None (side-effects: tag pushed, release created).
# Exit codes:
#   0 = success
#   1 = missing arguments or GH_TOKEN not set

set -euo pipefail

VERSION="${1:?Usage: $0 <version> <release-notes-file>}"
NOTES_FILE="${2:?Usage: $0 <version> <release-notes-file>}"

if [ -z "${GH_TOKEN:-}" ]; then
  echo "::error::GH_TOKEN environment variable is required"
  exit 1
fi

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git tag -a "v${VERSION}" -m "Release v${VERSION}"
git push origin "v${VERSION}"

gh release create "v${VERSION}" \
  --title "v${VERSION}" \
  --notes-file "$NOTES_FILE"
