#!/usr/bin/env bash
# ---------------------------------------------------------
# check-skillspector-threshold.sh
# ---------------------------------------------------------
# Parses a SkillSpector JSON report and exits non-zero when
# the assessed severity meets or exceeds the failure threshold.
#
# Used as the gating step in .github/workflows/skill-security-scan.yml
# because the SkillSpector CLI does not provide a --fail-on flag of
# its own.
#
# Usage:
#   check-skillspector-threshold.sh <path-to-skillspector.json>
#
# Optional env vars:
#   SKILLSPECTOR_FAIL_ON  Failure threshold (not an exact-match list). The gate
#                         fails when the report severity rank is at or above the
#                         lowest-ranked severity listed here. Accepts a single
#                         severity ("HIGH") or a comma-separated list kept for
#                         backward compatibility ("HIGH,CRITICAL"); the minimum
#                         rank in the list is used as the threshold. Matched
#                         case-insensitively. Default: "HIGH,CRITICAL".
#                         Rank order: LOW < MEDIUM < HIGH < CRITICAL.
#
# Exit codes:
#   0  severity is below the failure threshold (gate passes)
#   1  severity meets or exceeds the failure threshold (gate fails)
#   2  input error: missing file, invalid JSON, missing field, or an
#      unrecognized severity in the report or in SKILLSPECTOR_FAIL_ON
#
# SkillSpector JSON schema (relevant fields):
#   .risk_assessment.score          integer 0-100
#   .risk_assessment.severity       "LOW" | "MEDIUM" | "HIGH" | "CRITICAL"
#   .risk_assessment.recommendation "SAFE" | "CAUTION" | "DO_NOT_INSTALL"
#   .issues                         array of findings
# ---------------------------------------------------------

set -euo pipefail

REPORT_PATH="${1:-}"
FAIL_ON="${SKILLSPECTOR_FAIL_ON:-HIGH,CRITICAL}"

if [ -z "$REPORT_PATH" ]; then
  echo "::error::Usage: check-skillspector-threshold.sh <path-to-skillspector.json>"
  exit 2
fi

if [ ! -f "$REPORT_PATH" ]; then
  echo "::error::Report file not found: $REPORT_PATH"
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "::error::jq is required but not installed."
  exit 2
fi

# Validate JSON parses before we try to read fields.
if ! jq empty "$REPORT_PATH" >/dev/null 2>&1; then
  echo "::error::Report is not valid JSON: $REPORT_PATH"
  exit 2
fi

SEVERITY="$(jq -r '.risk_assessment.severity // empty' "$REPORT_PATH")"
SCORE="$(jq -r '.risk_assessment.score // empty' "$REPORT_PATH")"
RECOMMENDATION="$(jq -r '.risk_assessment.recommendation // empty' "$REPORT_PATH")"
ISSUE_COUNT="$(jq -r '.issues | length // 0' "$REPORT_PATH")"

if [ -z "$SEVERITY" ]; then
  echo "::error::Missing field .risk_assessment.severity in $REPORT_PATH"
  exit 2
fi

# Normalise to uppercase for comparison.
SEVERITY_UPPER="$(printf '%s' "$SEVERITY" | tr '[:lower:]' '[:upper:]')"
FAIL_ON_UPPER="$(printf '%s' "$FAIL_ON" | tr '[:lower:]' '[:upper:]')"

# Rank severities so the threshold is an ordering, not exact membership.
# Unknown severities return rank 0 and are treated as input errors.
severity_rank() {
  case "$1" in
    LOW) printf '1' ;;
    MEDIUM) printf '2' ;;
    HIGH) printf '3' ;;
    CRITICAL) printf '4' ;;
    *) printf '0' ;;
  esac
}

# Inverse of severity_rank: turn a numeric rank back into its severity name so
# the log can show the effective gate, not just the configured FAIL_ON list.
rank_severity() {
  case "$1" in
    1) printf 'LOW' ;;
    2) printf 'MEDIUM' ;;
    3) printf 'HIGH' ;;
    4) printf 'CRITICAL' ;;
    *) printf 'UNKNOWN' ;;
  esac
}

SEVERITY_RANK="$(severity_rank "$SEVERITY_UPPER")"
if [ "$SEVERITY_RANK" -eq 0 ]; then
  echo "::error::Unrecognized severity '${SEVERITY_UPPER}' in $REPORT_PATH"
  exit 2
fi

# Threshold = lowest rank among the configured FAIL_ON severities.
THRESHOLD_RANK=0
IFS=',' read -r -a FAIL_LIST <<< "$FAIL_ON_UPPER"
for entry in "${FAIL_LIST[@]}"; do
  trimmed="$(printf '%s' "$entry" | tr -d '[:space:]')"
  [ -z "$trimmed" ] && continue
  rank="$(severity_rank "$trimmed")"
  if [ "$rank" -eq 0 ]; then
    echo "::error::Unrecognized severity '${trimmed}' in SKILLSPECTOR_FAIL_ON"
    exit 2
  fi
  if [ "$THRESHOLD_RANK" -eq 0 ] || [ "$rank" -lt "$THRESHOLD_RANK" ]; then
    THRESHOLD_RANK="$rank"
  fi
done

if [ "$THRESHOLD_RANK" -eq 0 ]; then
  echo "::error::SKILLSPECTOR_FAIL_ON contains no recognized severity."
  exit 2
fi

# Effective threshold severity (lowest-ranked entry in FAIL_ON). The gate fails
# at this severity or higher, regardless of how FAIL_ON was written.
THRESHOLD_LABEL="$(rank_severity "$THRESHOLD_RANK")"

# Fail when the report severity is at or above the threshold.
FAIL=0
if [ "$SEVERITY_RANK" -ge "$THRESHOLD_RANK" ]; then
  FAIL=1
fi

# Always print a human-readable summary so the job log is self-explanatory.
echo "SkillSpector report: $REPORT_PATH"
echo "  Score:          ${SCORE:-unknown}/100"
echo "  Severity:       ${SEVERITY_UPPER}"
echo "  Recommendation: ${RECOMMENDATION:-unknown}"
echo "  Issues:         ${ISSUE_COUNT}"
echo "  Fail threshold: ${THRESHOLD_LABEL} or higher (configured: ${FAIL_ON_UPPER})"

# Write the same summary to the GitHub Actions step summary when available.
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### SkillSpector security gate"
    echo
    echo "| Metric | Value |"
    echo "|---|---|"
    echo "| Score | ${SCORE:-unknown}/100 |"
    echo "| Severity | ${SEVERITY_UPPER} |"
    echo "| Recommendation | ${RECOMMENDATION:-unknown} |"
    echo "| Issues | ${ISSUE_COUNT} |"
    echo "| Fail threshold | ${THRESHOLD_LABEL} or higher (configured: ${FAIL_ON_UPPER}) |"
  } >> "$GITHUB_STEP_SUMMARY"

  # Enumerate the individual findings so the run page is self-contained:
  # an author can read what tripped the gate without opening the Security
  # tab or downloading the JSON report. Finding text derives from the
  # scanned (untrusted) skill, so each field is sanitised before it is
  # written: table-breaking pipes and backslashes are escaped, newlines/
  # tabs are collapsed, and the detail is truncated to keep one finding per
  # row. The table is capped (see MAX_SUMMARY_ROWS) so a report with very
  # many findings cannot blow past GitHub's step-summary size limit; the
  # full set always remains in the uploaded JSON artifact.
  if [ "${ISSUE_COUNT}" -gt 0 ]; then
    MAX_SUMMARY_ROWS=50
    {
      echo
      echo "#### Findings (${ISSUE_COUNT})"
      echo
      echo "| Severity | Rule | Location | Detail |"
      echo "|---|---|---|---|"
      jq -r --argjson max "$MAX_SUMMARY_ROWS" '
        def san: (. // "-") | tostring | gsub("\\\\"; "\\\\") | gsub("\\|"; "\\|") | gsub("[\r\n\t]+"; " ");
        def trunc($n): if (length > $n) then (.[0:$n] + "...") else . end;
        .issues[0:$max][]
        | "| " + (.severity | san)
        + " | " + (.id | san)
        + " | " + ((.location.file | san) + ":" + ((.location.start_line // 0) | san))
        + " | " + (((.explanation // .message) | san) | trunc(160))
        + " |"
      ' "$REPORT_PATH"
      if [ "${ISSUE_COUNT}" -gt "${MAX_SUMMARY_ROWS}" ]; then
        echo
        echo "_Showing first ${MAX_SUMMARY_ROWS} of ${ISSUE_COUNT} findings; see the uploaded report artifact for the full list._"
      fi
    } >> "$GITHUB_STEP_SUMMARY"
  fi
fi

if [ "$FAIL" -eq 1 ]; then
  echo "::error::SkillSpector severity ${SEVERITY_UPPER} meets fail threshold ${THRESHOLD_LABEL} or higher (configured: ${FAIL_ON_UPPER}). Blocking merge."
  exit 1
fi

echo "SkillSpector gate passed."
exit 0
