#!/usr/bin/env bats
# Tests for .github/scripts/test/install-bats.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path
    # Mock sudo to log arguments without privilege escalation
    mkdir -p "$MOCK_DIR/sudo_log"
    cat > "$MOCK_DIR/sudo" <<'MOCK'
#!/usr/bin/env bash
echo "$@" >> "$(dirname "$0")/sudo_log/calls"
exit 0
MOCK
    chmod +x "$MOCK_DIR/sudo"
    create_mock "bats" "Bats 1.11.1"
}

teardown() {
    teardown_mock_path
}

@test "installs pinned bats@1.11.1 via npm" {
    run bash "$CI_SCRIPTS_DIR/test/install-bats.sh"
    [ "$status" -eq 0 ]
    [[ "$(cat "$MOCK_DIR/sudo_log/calls")" == *"bats@1.11.1"* ]]
}

@test "installs jq via apt-get" {
    run bash "$CI_SCRIPTS_DIR/test/install-bats.sh"
    [ "$status" -eq 0 ]
    [[ "$(cat "$MOCK_DIR/sudo_log/calls")" == *"jq"* ]]
}

@test "reports bats version on completion" {
    run bash "$CI_SCRIPTS_DIR/test/install-bats.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Bats"* ]]
}
