#!/usr/bin/env bats
# Tests for .github/scripts/security/run-skillspector-scan.sh
#
# Regression cover for issue #984: SkillSpector writes its output file
# and then exits non-zero when it finds HIGH/CRITICAL issues. The wrapper
# must treat such a run as a success (output is valid) so the downstream
# threshold gate stays the single decision authority, while still failing
# closed when no usable output is produced.

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"

    SCRIPT="$CI_SCRIPTS_DIR/security/run-skillspector-scan.sh"
    setup_mock_path

    OUT="$(mktemp -u)"
    export OUT
}

teardown() {
    teardown_mock_path
    if [[ -n "${OUT:-}" && -f "$OUT" ]]; then
        rm -f "$OUT"
    fi
}

# Create a fake `skillspector` on PATH. It honours --output <path>,
# writing $payload there (skip writing when $payload is the literal
# NO_OUTPUT), then exits with $exit_code.
# Usage: stub_skillspector <exit_code> <payload>
stub_skillspector() {
    local exit_code="$1" payload="$2"
    printf '%s' "$payload" > "$MOCK_DIR/skillspector_payload"
    printf '%s' "$exit_code" > "$MOCK_DIR/skillspector_exit"
    cat > "$MOCK_DIR/skillspector" <<'SCRIPT'
#!/usr/bin/env bash
out=""
prev=""
for arg in "$@"; do
    [[ "$prev" == "--output" ]] && out="$arg"
    prev="$arg"
done
payload="$(cat "$(dirname "$0")/skillspector_payload")"
if [[ -n "$out" && "$payload" != "NO_OUTPUT" ]]; then
    printf '%s' "$payload" > "$out"
fi
exit "$(cat "$(dirname "$0")/skillspector_exit")"
SCRIPT
    chmod +x "$MOCK_DIR/skillspector"
}

# ---------------------------------------------------------
# Success: valid output, regardless of SkillSpector exit code
# ---------------------------------------------------------

@test "exit 0 with valid JSON output passes" {
    stub_skillspector 0 '{"risk_assessment":{"severity":"LOW"},"issues":[]}'
    run bash "$SCRIPT" skills/azure-cost-calculator json "$OUT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"is present and parses"* ]]
}

@test "exit 1 with valid output still passes (the #984 regression)" {
    stub_skillspector 1 '{"risk_assessment":{"severity":"CRITICAL"},"issues":[{"id":"X"}]}'
    run bash "$SCRIPT" skills/azure-cost-calculator json "$OUT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"exit 1"* ]]
}

@test "exit 1 with valid SARIF output passes" {
    stub_skillspector 1 '{"version":"2.1.0","runs":[]}'
    run bash "$SCRIPT" skills/azure-cost-calculator sarif "$OUT"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------
# Fail closed: no usable output
# ---------------------------------------------------------

@test "exit 1 with no output file fails closed" {
    stub_skillspector 1 'NO_OUTPUT'
    run bash "$SCRIPT" skills/azure-cost-calculator json "$OUT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"wrote no json output"* ]]
}

@test "empty output file fails closed" {
    stub_skillspector 0 ''
    run bash "$SCRIPT" skills/azure-cost-calculator json "$OUT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"wrote no json output"* ]]
}

@test "non-JSON output fails closed" {
    stub_skillspector 1 'not json{'
    run bash "$SCRIPT" skills/azure-cost-calculator json "$OUT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not valid JSON"* ]]
}

# ---------------------------------------------------------
# Input errors (exit 2)
# ---------------------------------------------------------

@test "missing arguments exit 2" {
    run bash "$SCRIPT" skills/azure-cost-calculator json
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage"* ]]
}
