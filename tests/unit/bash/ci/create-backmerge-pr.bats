#!/usr/bin/env bats
# Tests for .github/scripts/release/create-backmerge-pr.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path
}

teardown() {
    teardown_mock_path
}

# Sets up git and gh mocks for a new-PR scenario (no existing PR found).
setup_new_pr_mocks() {
    create_git_dispatch_mock
    set_git_response fetch "" 0
    set_git_response checkout "" 0
    set_git_response push "" 0
    create_gh_dispatch_mock
    set_gh_response pr_list ""
    set_gh_response pr_create ""
}

@test "new PR with push_race reason includes concurrently in body" {
    export GH_TOKEN="fake-token" FALLBACK_REASON="push_race" RUN_ID="12345"
    setup_new_pr_mocks
    run bash "$CI_SCRIPTS_DIR/release/create-backmerge-pr.sh"
    [ "$status" -eq 0 ]
    gh_log="$(cat "$MOCK_DIR/gh_state/call_log")"
    [[ "$gh_log" == *"concurrently"* ]]
    # Verify pr create was called (not pr edit)
    [[ "$gh_log" == *"pr create"* ]]
}

@test "new PR with fetch_failure reason mentions could not fetch" {
    export GH_TOKEN="fake-token" FALLBACK_REASON="fetch_failure" RUN_ID="12345"
    setup_new_pr_mocks
    run bash "$CI_SCRIPTS_DIR/release/create-backmerge-pr.sh"
    [ "$status" -eq 0 ]
    [[ "$(cat "$MOCK_DIR/gh_state/call_log")" == *"could not fetch"* ]]
}

@test "new PR with unresolved_conflict reason mentions merge conflicts" {
    export GH_TOKEN="fake-token" FALLBACK_REASON="unresolved_conflict" RUN_ID="12345"
    setup_new_pr_mocks
    run bash "$CI_SCRIPTS_DIR/release/create-backmerge-pr.sh"
    [ "$status" -eq 0 ]
    [[ "$(cat "$MOCK_DIR/gh_state/call_log")" == *"Merge conflicts remained"* ]]
}

@test "existing PR is updated instead of creating a new one" {
    export GH_TOKEN="fake-token" FALLBACK_REASON="push_race" RUN_ID="12345"
    create_git_dispatch_mock
    set_git_response fetch "" 0
    set_git_response checkout "" 0
    set_git_response push "" 0
    create_gh_dispatch_mock
    set_gh_response pr_list "42"
    set_gh_response pr_view "backmerge-main-to-dev-existing"
    set_gh_response pr_edit ""
    run bash "$CI_SCRIPTS_DIR/release/create-backmerge-pr.sh"
    [ "$status" -eq 0 ]
    gh_log="$(cat "$MOCK_DIR/gh_state/call_log")"
    # Should use pr edit, not pr create
    [[ "$gh_log" == *"pr edit"* ]]
    [[ "$gh_log" != *"pr create"* ]]
}

@test "missing GH_TOKEN exits with error" {
    unset GH_TOKEN
    export FALLBACK_REASON="push_race" RUN_ID="12345"
    run bash "$CI_SCRIPTS_DIR/release/create-backmerge-pr.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"GH_TOKEN"* ]]
}

@test "missing FALLBACK_REASON exits with error" {
    export GH_TOKEN="fake-token" RUN_ID="12345"
    unset FALLBACK_REASON
    run bash "$CI_SCRIPTS_DIR/release/create-backmerge-pr.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FALLBACK_REASON"* ]]
}

@test "missing RUN_ID exits with error" {
    export GH_TOKEN="fake-token" FALLBACK_REASON="push_race"
    unset RUN_ID
    run bash "$CI_SCRIPTS_DIR/release/create-backmerge-pr.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"RUN_ID"* ]]
}
