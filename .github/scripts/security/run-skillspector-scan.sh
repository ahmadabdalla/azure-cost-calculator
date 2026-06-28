#!/usr/bin/env bash
# ---------------------------------------------------------
# run-skillspector-scan.sh
# ---------------------------------------------------------
# Runs `skillspector scan` and tolerates a non-zero exit code
# WHEN the scanner still produced usable output.
#
# WHY THIS EXISTS
# SkillSpector writes its output file and then exits non-zero
# (1) when it finds HIGH/CRITICAL issues. Under the workflow's
# default `set -e` shell, that non-zero exit would abort the job
# at the scan step, before the threshold gate and the SARIF
# upload ever run. The result was that the documented gate
# (check-skillspector-threshold.sh) never decided anything for
# exactly the dangerous skills, and no code-scanning finding was
# produced. See issue #984.
#
# CONTRACT
# The exit CODE is not trusted as a pass/fail signal (future
# SkillSpector versions may use other non-zero codes). Instead,
# OUTPUT VALIDITY controls continuation:
#   - output file exists, is non-empty, parses as JSON (SkillSpector
#     SARIF is JSON too), AND carries the minimal shape its consumer
#     needs (SARIF: a non-empty runs[]; JSON: a string
#     risk_assessment.severity, the one field the gate reads) ->
#     succeed (exit 0), so the gate downstream becomes the single
#     decision authority.
#   - missing, empty, unparseable, or structurally empty output -> a
#     genuine tooling failure; exit 1 so the caller fails closed.
#
# Usage:
#   run-skillspector-scan.sh <skill-path> <format> <output-file>
#
# Arguments:
#   <skill-path>   Repo-relative skill directory, no trailing slash
#                  (e.g. skills/azure-cost-calculator).
#   <format>       SkillSpector --format value (json or sarif).
#   <output-file>  Path SkillSpector writes the report to.
#
# Exit codes:
#   0  scan produced valid output (regardless of SkillSpector's code)
#   1  scan produced no usable output (missing/empty/unparseable)
#   2  input error: missing arguments, unsupported format, or jq not
#      installed
# ---------------------------------------------------------

set -euo pipefail

SKILL_PATH="${1:-}"
FORMAT="${2:-}"
OUTPUT="${3:-}"

if [ -z "$SKILL_PATH" ] || [ -z "$FORMAT" ] || [ -z "$OUTPUT" ]; then
  echo "::error::Usage: run-skillspector-scan.sh <skill-path> <format> <output-file>"
  exit 2
fi

# Validate FORMAT once, up front, so the downstream shape check is provably
# exhaustive: an unsupported value must not slip past structural validation
# and return a false success.
case "$FORMAT" in
  json|sarif) ;;
  *)
    echo "::error::Unsupported format '${FORMAT}'; expected 'json' or 'sarif'."
    exit 2
    ;;
esac

if ! command -v jq >/dev/null 2>&1; then
  echo "::error::jq is required but not installed."
  exit 2
fi

# Remove any pre-existing output so a stale or planted file cannot be trusted
# if the scanner fails to write. The workflow uses fixed repo-root filenames in
# an untrusted pull_request checkout, so the path is attacker-influenceable.
rm -f -- "$OUTPUT"

# Tolerate SkillSpector's non-zero "findings present" exit; the output
# file, not the exit code, is the source of truth (see CONTRACT above).
set +e
skillspector scan "./${SKILL_PATH}/" \
  --no-llm \
  --format "$FORMAT" \
  --output "$OUTPUT"
rc=$?
set -e

if [ ! -s "$OUTPUT" ]; then
  echo "::error::SkillSpector wrote no ${FORMAT} output to ${OUTPUT} (exit ${rc}); failing closed."
  exit 1
fi

if ! jq empty "$OUTPUT" >/dev/null 2>&1; then
  echo "::error::SkillSpector ${FORMAT} output ${OUTPUT} is not valid JSON (exit ${rc}); failing closed."
  exit 1
fi

# Valid JSON is necessary but not sufficient: a stub or a partially written
# file could be "{}" and still parse. Require the minimal shape the
# downstream consumer needs so an empty-but-valid document fails closed here
# rather than silently producing no gate decision / no code-scanning alert.
# FORMAT was validated above, so this case is exhaustive by construction.
case "$FORMAT" in
  sarif)
    if ! jq -e '(.runs | type) == "array" and (.runs | length) > 0' "$OUTPUT" >/dev/null 2>&1; then
      echo "::error::SkillSpector SARIF output ${OUTPUT} has no runs[] (exit ${rc}); failing closed."
      exit 1
    fi
    ;;
  json)
    if ! jq -e '(.risk_assessment.severity | type) == "string"' "$OUTPUT" >/dev/null 2>&1; then
      echo "::error::SkillSpector JSON output ${OUTPUT} has no risk_assessment.severity (exit ${rc}); failing closed."
      exit 1
    fi
    ;;
esac

echo "SkillSpector ${FORMAT} scan completed (exit ${rc}); ${OUTPUT} is present and parses."
exit 0
