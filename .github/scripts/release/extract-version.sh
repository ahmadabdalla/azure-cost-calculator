#!/usr/bin/env bash
# Purpose:  Read and validate the plugin version, then verify the git tag does not exist.
# Inputs:   $1 = path to plugin.json (default: .claude-plugin/plugin.json)
# Outputs:  Prints VERSION to stdout so the caller can capture it.
# Exit codes:
#   0 = success
#   1 = version missing, invalid, or tag already exists

set -euo pipefail

PLUGIN_JSON="${1:-.claude-plugin/plugin.json}"

if ! VERSION=$(jq -er '.version' "$PLUGIN_JSON"); then
  echo "::error::Failed to read '.version' from $PLUGIN_JSON (invalid JSON, missing file, or null value)" >&2
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

if git rev-parse --verify --quiet "refs/tags/v${VERSION}" >/dev/null 2>&1; then
  echo "::error::Tag v${VERSION} already exists" >&2
  exit 1
fi

echo "Detected version: $VERSION" >&2
echo "$VERSION"
