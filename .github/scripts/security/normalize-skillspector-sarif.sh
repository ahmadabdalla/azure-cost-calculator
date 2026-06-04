#!/usr/bin/env bash
# ---------------------------------------------------------
# normalize-skillspector-sarif.sh
# ---------------------------------------------------------
# Rewrites the artifactLocation.uri values in a SkillSpector
# SARIF report so they are repository-relative instead of
# skill-directory-relative.
#
# WHY THIS EXISTS
# SkillSpector records component paths relative to the scanned
# skill directory (see build_context.py: rel = item.relative_to(
# skill_dir)). So a finding in skills/azure-cost-calculator/SKILL.md
# is emitted as uri "SKILL.md", not "skills/azure-cost-calculator/
# SKILL.md". GitHub code scanning resolves SARIF uris against the
# repository root, so without this rewrite every alert lands on the
# wrong path (or is dropped). This prepends the skill path to each
# uri so alerts annotate the correct file on the PR diff.
#
# FAIL-CLOSED SANITISATION
# The uri is the only fork-influenced value uploaded to code
# scanning. A crafted uri (absolute path, URL scheme, backslash, or
# ".." traversal) could mislocate an alert onto an unrelated victim
# file. Any uri that is not a plain, in-tree relative path is
# treated as hostile and the script exits non-zero (exit 3) so the
# caller blocks rather than uploads a poisoned report.
#
# Usage:
#   normalize-skillspector-sarif.sh <path-to.sarif> <path-prefix>
#
# Arguments:
#   <path-to.sarif>  SARIF file to rewrite in place.
#   <path-prefix>    Repo-relative skill directory, no trailing slash
#                    (e.g. skills/azure-cost-calculator).
#
# Exit codes:
#   0  rewrite succeeded (file modified in place)
#   2  input error: missing args, missing file, invalid JSON, no jq
#   3  unsafe uri detected: nothing written, caller must fail closed
# ---------------------------------------------------------

set -euo pipefail

SARIF_PATH="${1:-}"
PREFIX="${2:-}"

if [ -z "$SARIF_PATH" ] || [ -z "$PREFIX" ]; then
  echo "::error::Usage: normalize-skillspector-sarif.sh <path-to.sarif> <path-prefix>"
  exit 2
fi

if [ ! -f "$SARIF_PATH" ]; then
  echo "::error::SARIF file not found: $SARIF_PATH"
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "::error::jq is required but not installed."
  exit 2
fi

if ! jq empty "$SARIF_PATH" >/dev/null 2>&1; then
  echo "::error::SARIF is not valid JSON: $SARIF_PATH"
  exit 2
fi

# Strip any trailing slash so we control the single separator we add.
PREFIX="${PREFIX%/}"

# A uri is acceptable only when it is a plain in-tree relative path: the
# safe character class below excludes ":" (schemes), "\" (Windows
# separators), "%" (encoded traversal) and leading "/" (absolute), and the
# second test rejects any ".." path segment. We deliberately do NOT let an
# existing prefix short-circuit the traversal check: a legitimate
# already-prefixed uri (e.g. skills/azure-cost-calculator/SKILL.md) still
# satisfies this character class and carries no "..", so idempotent re-runs
# stay safe, while a hostile prefixed uri carrying ".." is still rejected.
# Everything else is hostile.
UNSAFE="$(jq -r --arg p "$PREFIX" '
  [ .runs[]?.results[]?.locations[]?.physicalLocation.artifactLocation.uri
    | select(. != null and . != "")
    | select(
        ( test("^[A-Za-z0-9._-][A-Za-z0-9._/-]*$")
          and ( test("(^|/)\\.\\.(/|$)") | not ) )
        | not
      )
  ] | unique | .[]
' "$SARIF_PATH")"

if [ -n "$UNSAFE" ]; then
  echo "::error::Refusing to upload SkillSpector SARIF: unsafe artifact uri(s) detected:"
  printf '%s\n' "$UNSAFE" | while IFS= read -r u; do
    printf '::error::  %s\n' "$u"
  done
  exit 3
fi

TMP="$(mktemp)"
jq --arg p "$PREFIX" '
  ( .runs[]?.results[]?.locations[]?.physicalLocation.artifactLocation.uri ) |=
    ( if (. == null or . == "") then .
      elif startswith($p + "/") then .
      else $p + "/" + . end )
' "$SARIF_PATH" > "$TMP"
mv "$TMP" "$SARIF_PATH"

echo "Normalised SkillSpector SARIF uris under prefix: $PREFIX/"
exit 0
