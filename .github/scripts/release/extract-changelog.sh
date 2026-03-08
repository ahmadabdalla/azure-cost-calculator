#!/usr/bin/env bash
# Purpose:  Extract the changelog section for a given version from CHANGELOG.md.
# Inputs:   $1 = version string (required, e.g. 1.2.3)
#           $2 = path to CHANGELOG.md (default: CHANGELOG.md)
#           $3 = output file path (default: /tmp/release-body.md)
# Outputs:  Writes the changelog section to the output file.
# Exit codes:
#   0 = success
#   1 = version argument missing or no matching section found

set -euo pipefail

VERSION="${1:?Usage: $0 <version> [changelog-file] [output-file]}"
CHANGELOG="${2:-CHANGELOG.md}"
OUTPUT_FILE="${3:-/tmp/release-body.md}"

# Use -v to pass version as an awk variable (avoids interpolation issues).
BODY=$(awk -v ver="$VERSION" '
  $0 ~ "^## \\[" ver "\\]" { found=1; next }
  /^## \[/ { if (found) exit }
  found { print }
' "$CHANGELOG")

if [ -z "$BODY" ]; then
  echo "::error::No changelog section found for version ${VERSION} in ${CHANGELOG}" >&2
  exit 1
fi

echo "$BODY" > "$OUTPUT_FILE"
echo "Changelog extracted for v${VERSION} -> $OUTPUT_FILE"
