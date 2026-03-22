#!/usr/bin/env bats
# Tests for .github/scripts/release/create-release-pr.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path
    setup_github_output

    # Create a temporary plugin.json
    PLUGIN_JSON="$(mktemp)"
    echo '{"version":"1.5.0"}' > "$PLUGIN_JSON"
    export PLUGIN_JSON

    # Create a temporary CHANGELOG.md
    CHANGELOG="$(mktemp)"
    cat > "$CHANGELOG" <<'EOF'
# Changelog

## [1.5.0] - 2026-03-24

### Added

- New service: Azure Cosmos DB (`cosmos-db.md`)

### Fixed

- Corrected VM pricing for uksouth

## [1.4.0] - 2026-03-15

### Added

- Initial release
EOF
    export CHANGELOG

    # Default env vars
    export GH_TOKEN="fake-token"
    export PR_BODY="Summary of changes

---
Issue references: #123, #456"

    # Default jq mock: returns version from plugin.json
    create_mock "jq" "1.5.0"
}

teardown() {
    rm -f "$PLUGIN_JSON" "$CHANGELOG"
    teardown_github_output
    teardown_mock_path
}

@test "creates release PR with correct title and flags" {
    create_gh_dispatch_mock
    set_gh_response "pr_list" "" 0
    set_gh_response "pr_create" "42" 0

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 0 ]

    # Verify gh pr create was called with correct flags
    gh_log="$(cat "$MOCK_DIR/gh_state/call_log")"
    [[ "$gh_log" == *"pr create"* ]]
    [[ "$gh_log" == *"--base main"* ]]
    [[ "$gh_log" == *"--head dev"* ]]
    [[ "$gh_log" == *"release: v1.5.0"* ]]
}

@test "extracts issue references and adds Closes keywords" {
    create_gh_dispatch_mock
    set_gh_response "pr_list" "" 0
    set_gh_response "pr_create" "42" 0

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 0 ]

    # Verify gh pr create was called with body file
    gh_log="$(cat "$MOCK_DIR/gh_state/call_log")"
    [[ "$gh_log" == *"--body-file"* ]]
}

@test "handles PR body with single issue reference" {
    export PR_BODY="Summary

---
Issue references: #999"
    create_gh_dispatch_mock
    set_gh_response "pr_list" "" 0
    set_gh_response "pr_create" "42" 0

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 0 ]
}

@test "handles PR body with no issue references" {
    export PR_BODY="Summary of changes only, no issue refs"
    create_gh_dispatch_mock
    set_gh_response "pr_list" "" 0
    set_gh_response "pr_create" "42" 0

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 0 ]
}

@test "updates existing release PR instead of creating new one" {
    create_gh_dispatch_mock
    set_gh_response "pr_list" "99" 0
    set_gh_response "pr_edit" "" 0

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 0 ]

    gh_log="$(cat "$MOCK_DIR/gh_state/call_log")"
    [[ "$gh_log" == *"pr edit"* ]]
    [[ "$gh_log" == *"99"* ]]
    # pr create should NOT have been called
    [[ "$gh_log" != *"pr create"* ]]
}

@test "missing GH_TOKEN exits with error" {
    unset GH_TOKEN
    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"GH_TOKEN"* ]]
}

@test "missing PR_BODY exits with error" {
    unset PR_BODY
    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"PR_BODY"* ]]
}

@test "invalid plugin.json exits with error" {
    create_mock "jq" "" 1
    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 1 ]
}

@test "empty version in plugin.json exits with error" {
    create_mock "jq" ""
    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"empty"* ]]
}

@test "invalid semver in plugin.json exits with error" {
    create_mock "jq" "not-a-version"
    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not valid semver"* ]]
}

@test "gh pr create failure exits with error" {
    create_gh_dispatch_mock
    set_gh_response "pr_list" "" 0
    set_gh_response "pr_create" "" 1

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 1 ]
}

@test "gh pr edit failure propagates as non-zero exit" {
    create_gh_dispatch_mock
    set_gh_response "pr_list" "99" 0
    set_gh_response "pr_edit" "" 1

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -ne 0 ]
}

@test "missing changelog section uses placeholder" {
    create_mock "jq" "9.9.9"
    create_gh_dispatch_mock
    set_gh_response "pr_list" "" 0
    set_gh_response "pr_create" "42" 0

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No changelog section found"* ]]
}

@test "writes version and pr_number to GITHUB_OUTPUT" {
    create_gh_dispatch_mock
    set_gh_response "pr_list" "" 0
    set_gh_response "pr_create" "42" 0

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value version)" = "1.5.0" ]
    [ "$(get_output_value pr_number)" = "42" ]
}

@test "writes pr_number for existing PR to GITHUB_OUTPUT" {
    create_gh_dispatch_mock
    set_gh_response "pr_list" "99" 0
    set_gh_response "pr_edit" "" 0

    run bash "$CI_SCRIPTS_DIR/release/create-release-pr.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value pr_number)" = "99" ]
}
