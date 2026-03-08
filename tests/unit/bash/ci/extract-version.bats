#!/usr/bin/env bats
# Tests for .github/scripts/release/extract-version.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path

    # Default mocks: jq returns valid semver, git tag not found (exit 128)
    create_mock "jq" "1.2.3" 0
    create_mock "git" "" 128
}

teardown() {
    teardown_mock_path
}

@test "valid semver is extracted successfully" {
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "dummy.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.2.3"* ]]
}

@test "valid semver with prerelease tag" {
    create_mock "jq" "1.0.0-beta.1" 0
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "dummy.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.0.0-beta.1"* ]]
}

@test "tag already exists fails with error" {
    create_mock "git" "" 0
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "dummy.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"already exists"* ]]
}

@test "invalid semver with letters fails" {
    create_mock "jq" "abc" 0
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "dummy.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not valid semver"* ]]
}

@test "invalid semver with leading zero fails" {
    create_mock "jq" "01.2.3" 0
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "dummy.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not valid semver"* ]]
}

@test "empty version fails" {
    create_mock "jq" "" 0
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "dummy.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"empty"* ]] || [[ "$output" == *"Failed to read"* ]]
}

@test "jq failure exits with error" {
    create_mock "jq" "" 1
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "dummy.json"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to read"* ]]
}

@test "custom plugin.json path is passed through" {
    create_mock "jq" "2.0.0" 0
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "/tmp/custom-plugin.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.0.0"* ]]
}

@test "valid semver with build metadata" {
    create_mock "jq" "1.0.0+build.123" 0
    run bash "$CI_SCRIPTS_DIR/release/extract-version.sh" "dummy.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.0.0+build.123"* ]]
}
