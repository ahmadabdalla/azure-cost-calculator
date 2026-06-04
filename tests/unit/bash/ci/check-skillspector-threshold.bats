#!/usr/bin/env bats
# Tests for .github/scripts/security/check-skillspector-threshold.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"

    SCRIPT="$CI_SCRIPTS_DIR/security/check-skillspector-threshold.sh"
    REPORT="$(mktemp)"
    export REPORT
}

teardown() {
    if [[ -n "${REPORT:-}" && -f "$REPORT" ]]; then
        rm -f "$REPORT"
    fi
}

# Build a minimal valid SkillSpector JSON report.
# Usage: write_report <severity> [score] [recommendation] [issue_count]
write_report() {
    local severity="$1"
    local score="${2:-50}"
    local recommendation="${3:-CAUTION}"
    local issue_count="${4:-0}"

    local issues="[]"
    if [ "$issue_count" -gt 0 ]; then
        issues="["
        for ((i=1; i<=issue_count; i++)); do
            issues+='{"rule_id":"X1","severity":"'"$severity"'","message":"x"}'
            [ "$i" -lt "$issue_count" ] && issues+=","
        done
        issues+="]"
    fi

    cat > "$REPORT" <<JSON
{
  "skill": {"name": "test", "source": ".", "scanned_at": "2026-01-01T00:00:00Z"},
  "risk_assessment": {
    "score": ${score},
    "severity": "${severity}",
    "recommendation": "${recommendation}"
  },
  "components": [],
  "issues": ${issues},
  "metadata": {}
}
JSON
}

# ---------------------------------------------------------
# Pass cases (severity below default fail threshold)
# ---------------------------------------------------------

@test "LOW severity passes" {
    write_report "LOW" 10 "SAFE" 0
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Severity:       LOW"* ]]
    [[ "$output" == *"gate passed"* ]]
}

@test "MEDIUM severity passes" {
    write_report "MEDIUM" 35 "CAUTION" 2
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Severity:       MEDIUM"* ]]
}

@test "lowercase severity is normalised and passes for low" {
    write_report "low" 5 "SAFE" 0
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Severity:       LOW"* ]]
}

# ---------------------------------------------------------
# Fail cases (severity at or above default fail threshold)
# ---------------------------------------------------------

@test "HIGH severity fails the gate" {
    write_report "HIGH" 60 "DO_NOT_INSTALL" 1
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"meets fail threshold"* ]]
    [[ "$output" == *"Blocking merge"* ]]
}

@test "CRITICAL severity fails the gate" {
    write_report "CRITICAL" 90 "DO_NOT_INSTALL" 3
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Severity:       CRITICAL"* ]]
    [[ "$output" == *"meets fail threshold"* ]]
}

@test "lowercase critical is normalised and fails" {
    write_report "critical" 95 "DO_NOT_INSTALL" 1
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 1 ]
}

# ---------------------------------------------------------
# Custom threshold via SKILLSPECTOR_FAIL_ON
# ---------------------------------------------------------

@test "custom threshold CRITICAL only lets HIGH pass" {
    write_report "HIGH" 60 "DO_NOT_INSTALL" 1
    SKILLSPECTOR_FAIL_ON="CRITICAL" run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Fail threshold: CRITICAL"* ]]
}

@test "custom threshold MEDIUM,HIGH,CRITICAL fails MEDIUM" {
    write_report "MEDIUM" 30 "CAUTION" 1
    SKILLSPECTOR_FAIL_ON="MEDIUM,HIGH,CRITICAL" run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 1 ]
}

@test "custom threshold tolerates whitespace and case" {
    write_report "HIGH" 60 "DO_NOT_INSTALL" 1
    SKILLSPECTOR_FAIL_ON="high , critical" run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 1 ]
}

# ---------------------------------------------------------
# Threshold ordering (not exact-match membership)
# ---------------------------------------------------------

@test "threshold HIGH also fails CRITICAL (ordering, not exact match)" {
    write_report "CRITICAL" 90 "DO_NOT_INSTALL" 1
    SKILLSPECTOR_FAIL_ON="HIGH" run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"meets fail threshold"* ]]
}

@test "threshold HIGH fails HIGH" {
    write_report "HIGH" 60 "DO_NOT_INSTALL" 1
    SKILLSPECTOR_FAIL_ON="HIGH" run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 1 ]
}

@test "threshold HIGH lets MEDIUM pass" {
    write_report "MEDIUM" 30 "CAUTION" 1
    SKILLSPECTOR_FAIL_ON="HIGH" run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 0 ]
}

@test "list threshold uses lowest rank (MEDIUM,CRITICAL fails HIGH)" {
    write_report "HIGH" 60 "DO_NOT_INSTALL" 1
    SKILLSPECTOR_FAIL_ON="MEDIUM,CRITICAL" run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 1 ]
}

@test "unrecognized report severity exits 2" {
    write_report "BOGUS" 50 "CAUTION" 0
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Unrecognized severity"* ]]
}

@test "unrecognized SKILLSPECTOR_FAIL_ON token exits 2" {
    write_report "HIGH" 60 "DO_NOT_INSTALL" 1
    SKILLSPECTOR_FAIL_ON="NONSENSE" run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Unrecognized severity"* ]]
}

# ---------------------------------------------------------
# Input error cases (exit 2)
# ---------------------------------------------------------

@test "missing argument exits 2" {
    run bash "$SCRIPT"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage"* ]]
}

@test "missing report file exits 2" {
    run bash "$SCRIPT" "/tmp/does-not-exist-$$.json"
    [ "$status" -eq 2 ]
    [[ "$output" == *"not found"* ]]
}

@test "invalid JSON exits 2" {
    printf 'not json{' > "$REPORT"
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 2 ]
    [[ "$output" == *"not valid JSON"* ]]
}

@test "missing severity field exits 2" {
    cat > "$REPORT" <<'JSON'
{
  "skill": {"name": "test"},
  "risk_assessment": {"score": 50},
  "issues": []
}
JSON
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Missing field"* ]]
}

# ---------------------------------------------------------
# GITHUB_STEP_SUMMARY integration
# ---------------------------------------------------------

@test "writes markdown summary to GITHUB_STEP_SUMMARY when set" {
    write_report "LOW" 5 "SAFE" 0
    GITHUB_STEP_SUMMARY="$(mktemp)"
    export GITHUB_STEP_SUMMARY
    run bash "$SCRIPT" "$REPORT"
    [ "$status" -eq 0 ]
    summary="$(cat "$GITHUB_STEP_SUMMARY")"
    [[ "$summary" == *"SkillSpector security gate"* ]]
    [[ "$summary" == *"| Severity | LOW |"* ]]
    rm -f "$GITHUB_STEP_SUMMARY"
}
