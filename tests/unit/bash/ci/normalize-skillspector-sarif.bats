#!/usr/bin/env bats
# Tests for .github/scripts/security/normalize-skillspector-sarif.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"

    SCRIPT="$CI_SCRIPTS_DIR/security/normalize-skillspector-sarif.sh"
    PREFIX="skills/azure-cost-calculator"
    SARIF="$(mktemp)"
    export SARIF PREFIX
}

teardown() {
    if [[ -n "${SARIF:-}" && -f "$SARIF" ]]; then
        rm -f "$SARIF"
    fi
}

# Write a SARIF report whose results carry the given uris.
# Usage: write_sarif <uri> [<uri> ...]
write_sarif() {
    local results="" first=1
    for uri in "$@"; do
        [ "$first" -eq 1 ] || results+=","
        first=0
        results+='{"ruleId":"X1","locations":[{"physicalLocation":{"artifactLocation":{"uri":"'"$uri"'"},"region":{"startLine":1}}}]}'
    done
    cat > "$SARIF" <<JSON
{"version":"2.1.0","runs":[{"tool":{"driver":{"name":"skillspector"}},"results":[${results}]}]}
JSON
}

# Read back the list of uris as a compact JSON array.
read_uris() {
    jq -c '[.runs[].results[]?.locations[]?.physicalLocation.artifactLocation.uri]' "$SARIF"
}

# ---------------------------------------------------------
# Happy path: skill-relative uris become repo-relative
# ---------------------------------------------------------

@test "prefixes a top-level uri" {
    write_sarif "SKILL.md"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 0 ]
    [ "$(read_uris)" = '["skills/azure-cost-calculator/SKILL.md"]' ]
}

@test "prefixes a nested uri" {
    write_sarif "scripts/lib/pricing.sh"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 0 ]
    [ "$(read_uris)" = '["skills/azure-cost-calculator/scripts/lib/pricing.sh"]' ]
}

@test "prefixes multiple uris in one report" {
    write_sarif "SKILL.md" "references/services/redis-cache.md"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 0 ]
    [ "$(read_uris)" = '["skills/azure-cost-calculator/SKILL.md","skills/azure-cost-calculator/references/services/redis-cache.md"]' ]
}

@test "is idempotent on already-prefixed uris" {
    write_sarif "SKILL.md"
    bash "$SCRIPT" "$SARIF" "$PREFIX"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 0 ]
    [ "$(read_uris)" = '["skills/azure-cost-calculator/SKILL.md"]' ]
}

@test "tolerates a trailing slash on the prefix" {
    write_sarif "SKILL.md"
    run bash "$SCRIPT" "$SARIF" "$PREFIX/"
    [ "$status" -eq 0 ]
    [ "$(read_uris)" = '["skills/azure-cost-calculator/SKILL.md"]' ]
}

@test "handles a result with no locations" {
    cat > "$SARIF" <<'JSON'
{"version":"2.1.0","runs":[{"tool":{"driver":{"name":"skillspector"}},"results":[{"ruleId":"X1","locations":[]}]}]}
JSON
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 0 ]
}

@test "handles a report with no results" {
    cat > "$SARIF" <<'JSON'
{"version":"2.1.0","runs":[{"tool":{"driver":{"name":"skillspector"}},"results":[]}]}
JSON
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------
# Fail-closed sanitisation (exit 3, file untouched)
# ---------------------------------------------------------

@test "rejects parent-directory traversal" {
    write_sarif "../../.github/workflows/ci.yml"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 3 ]
    [[ "$output" == *"unsafe artifact uri"* ]]
}

@test "rejects mid-path traversal" {
    write_sarif "scripts/../../secret"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 3 ]
}

@test "rejects an absolute path" {
    write_sarif "/etc/passwd"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 3 ]
}

@test "rejects a url scheme" {
    write_sarif "https://evil.example/x"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 3 ]
}

@test "rejects percent-encoded traversal" {
    write_sarif "%2e%2e/secret"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 3 ]
}

@test "rejects a backslash separator" {
    write_sarif 'scripts\\windows.ps1'
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 3 ]
}

@test "leaves the file unchanged when an unsafe uri is rejected" {
    write_sarif "../escape"
    before="$(cat "$SARIF")"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 3 ]
    [ "$(cat "$SARIF")" = "$before" ]
}

# ---------------------------------------------------------
# Input errors (exit 2)
# ---------------------------------------------------------

@test "missing arguments exit 2" {
    run bash "$SCRIPT"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage"* ]]
}

@test "missing prefix argument exits 2" {
    write_sarif "SKILL.md"
    run bash "$SCRIPT" "$SARIF"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage"* ]]
}

@test "missing file exits 2" {
    run bash "$SCRIPT" "/tmp/does-not-exist-$$.sarif" "$PREFIX"
    [ "$status" -eq 2 ]
    [[ "$output" == *"not found"* ]]
}

@test "invalid JSON exits 2" {
    printf 'not json{' > "$SARIF"
    run bash "$SCRIPT" "$SARIF" "$PREFIX"
    [ "$status" -eq 2 ]
    [[ "$output" == *"not valid JSON"* ]]
}
