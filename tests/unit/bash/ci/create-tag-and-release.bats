#!/usr/bin/env bats
# Tests for .github/scripts/release/create-tag-and-release.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path
    NOTES_FILE="$(mktemp)"
    echo "Test release notes" > "$NOTES_FILE"
}

teardown() {
    rm -f "$NOTES_FILE"
    teardown_mock_path
}

@test "successful tag and release creation" {
    export GH_TOKEN="fake-token"
    create_git_dispatch_mock
    set_git_response config "" 0
    set_git_response tag "" 0
    set_git_response push "" 0
    create_gh_dispatch_mock
    set_gh_response release_create "" 0
    run bash "$CI_SCRIPTS_DIR/release/create-tag-and-release.sh" "1.2.3" "$NOTES_FILE"
    [ "$status" -eq 0 ]
    # Verify correct version was used in tag and push
    git_log="$(cat "$MOCK_DIR/git_state/call_log")"
    [[ "$git_log" == *"v1.2.3"* ]]
    # Verify gh release was called with correct version and notes file
    gh_log="$(cat "$MOCK_DIR/gh_state/call_log")"
    [[ "$gh_log" == *"v1.2.3"* ]]
    [[ "$gh_log" == *"$NOTES_FILE"* ]]
}

@test "missing version argument exits non-zero" {
    export GH_TOKEN="fake-token"
    run bash "$CI_SCRIPTS_DIR/release/create-tag-and-release.sh"
    [ "$status" -ne 0 ]
}

@test "missing notes file argument exits non-zero" {
    export GH_TOKEN="fake-token"
    run bash "$CI_SCRIPTS_DIR/release/create-tag-and-release.sh" "1.2.3"
    [ "$status" -ne 0 ]
}

@test "missing GH_TOKEN exits with error message" {
    unset GH_TOKEN
    run bash "$CI_SCRIPTS_DIR/release/create-tag-and-release.sh" "1.2.3" "$NOTES_FILE"
    [ "$status" -eq 1 ]
    [[ "$output" == *"GH_TOKEN"* ]]
}

@test "git push failure propagates as non-zero exit" {
    export GH_TOKEN="fake-token"
    create_git_dispatch_mock
    set_git_response config "" 0
    set_git_response tag "" 0
    set_git_response push "" 1
    run bash "$CI_SCRIPTS_DIR/release/create-tag-and-release.sh" "1.2.3" "$NOTES_FILE"
    [ "$status" -ne 0 ]
}

@test "gh release create failure propagates as non-zero exit" {
    export GH_TOKEN="fake-token"
    create_git_dispatch_mock
    set_git_response config "" 0
    set_git_response tag "" 0
    set_git_response push "" 0
    create_gh_dispatch_mock
    set_gh_response release_create "" 1
    run bash "$CI_SCRIPTS_DIR/release/create-tag-and-release.sh" "1.2.3" "$NOTES_FILE"
    [ "$status" -ne 0 ]
}
