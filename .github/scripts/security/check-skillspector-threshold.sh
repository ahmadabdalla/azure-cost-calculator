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
#   SKILLSPECTOR_FAIL_ON  Comma-separated severities that cause exit 1.
#                         Default: "HIGH,CRITICAL". Severities are matched
#                         case-insensitively against risk_assessment.severity.
#
# Exit codes:
#   0  severity is below the failure threshold (gate passes)
#   1  severity meets or exceeds the failure threshold (gate fails)
#   2  input error: missing file, invalid JSON, or missing field
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

# Match SEVERITY_UPPER against the comma-separated FAIL_ON list.
FAIL=0
IFS=',' read -r -a FAIL_LIST <<< "$FAIL_ON_UPPER"
for entry in "${FAIL_LIST[@]}"; do
  trimmed="$(printf '%s' "$entry" | tr -d '[:space:]')"
  if [ "$SEVERITY_UPPER" = "$trimmed" ]; then
    FAIL=1
    break
  fi
done

# Always print a human-readable summary so the job log is self-explanatory.
echo "SkillSpector report: $REPORT_PATH"
echo "  Score:          ${SCORE:-unknown}/100"
echo "  Severity:       ${SEVERITY_UPPER}"
echo "  Recommendation: ${RECOMMENDATION:-unknown}"
echo "  Issues:         ${ISSUE_COUNT}"
echo "  Fail threshold: ${FAIL_ON_UPPER}"

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
    echo "| Fail threshold | ${FAIL_ON_UPPER} |"
  } >> "$GITHUB_STEP_SUMMARY"
fi

if [ "$FAIL" -eq 1 ]; then
  echo "::error::SkillSpector severity ${SEVERITY_UPPER} meets fail threshold (${FAIL_ON_UPPER}). Blocking merge."
  exit 1
fi

echo "SkillSpector gate passed."
exit 0
