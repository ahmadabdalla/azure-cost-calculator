#!/usr/bin/env bats
# Tests for .github/scripts/validate/detect-change-scope.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path
    setup_github_output

    # Mock openssl to return a fixed hex string for deterministic delimiters
    create_mock "openssl" "deadbeefcafe1234deadbeefcafe1234" 0

    # Default env vars required by the script
    export DIFF_BASE="origin/main"
    export DIFF_HEAD="HEAD"
    export SERVICES_ROOT="services"
    export INFRA_PATHS="skills/ tests/ .github/"
}

teardown() {
    teardown_github_output
    teardown_mock_path
}

@test "service files changed only" {
    # Call 1 (ACMR service): returns .md file
    # Call 2 (D service):    returns nothing
    # Call 3 (infra):        returns nothing
    create_sequenced_mock "git" \
        "services/compute/vm.md|0" \
        "|0" \
        "|0"

    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value service_changed)" = "true" ]
    [ "$(get_output_value service_deleted)" = "false" ]
    [ "$(get_output_value infra_changed)" = "false" ]
    [[ "$(get_output_heredoc all_changed_files)" == *"services/compute/vm.md"* ]]
    # Verify the correct pathspecs were passed to git diff
    call_log="$(cat "$MOCK_DIR/git_seq/call_log")"
    [[ "$call_log" == *"$SERVICES_ROOT/"* ]]
    [[ "$call_log" == *"$INFRA_PATHS"* ]] || [[ "$call_log" == *"skills/"* ]]
}

@test "infra files changed only" {
    # Call 1 (ACMR service): returns nothing
    # Call 2 (D service):    returns nothing
    # Call 3 (infra):        returns changed file
    create_sequenced_mock "git" \
        "|0" \
        "|0" \
        ".github/workflows/ci.yml|0"

    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value service_changed)" = "false" ]
    [ "$(get_output_value service_deleted)" = "false" ]
    [ "$(get_output_value infra_changed)" = "true" ]
}

@test "both service and infra changed" {
    # Call 1 (ACMR service): returns changed .md
    # Call 2 (D service):    returns nothing
    # Call 3 (infra):        returns changed infra file
    create_sequenced_mock "git" \
        "services/storage/blob.md|0" \
        "|0" \
        "tests/unit/test.ps1|0"

    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value service_changed)" = "true" ]
    [ "$(get_output_value service_deleted)" = "false" ]
    [ "$(get_output_value infra_changed)" = "true" ]
}

@test "no changes detected" {
    create_sequenced_mock "git" \
        "|0" \
        "|0" \
        "|0"

    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value service_changed)" = "false" ]
    [ "$(get_output_value service_deleted)" = "false" ]
    [ "$(get_output_value infra_changed)" = "false" ]
}

@test "non-markdown service files are filtered out" {
    # ACMR diff returns a .txt file; grep '\.md$' filters it out
    create_sequenced_mock "git" \
        "services/compute/notes.txt|0" \
        "|0" \
        "|0"

    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value service_changed)" = "false" ]
    [ "$(get_output_value service_deleted)" = "false" ]
}

@test "missing DIFF_BASE fails" {
    unset DIFF_BASE
    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"DIFF_BASE"* ]]
}

@test "missing DIFF_HEAD fails" {
    unset DIFF_HEAD
    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"DIFF_HEAD"* ]]
}

@test "missing SERVICES_ROOT fails" {
    unset SERVICES_ROOT
    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"SERVICES_ROOT"* ]]
}

@test "missing INFRA_PATHS fails" {
    unset INFRA_PATHS
    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"INFRA_PATHS"* ]]
}

@test "multiple service files are all captured in heredoc" {
    create_sequenced_mock "git" \
        "services/compute/vm.md
services/storage/blob.md
services/network/vnet.md|0" \
        "|0" \
        "|0"

    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value service_changed)" = "true" ]
    heredoc="$(get_output_heredoc all_changed_files)"
    [[ "$heredoc" == *"services/compute/vm.md"* ]]
    [[ "$heredoc" == *"services/storage/blob.md"* ]]
    [[ "$heredoc" == *"services/network/vnet.md"* ]]
}

@test "deletion-only PR sets service_deleted=true and service_changed=false" {
    # ACMR diff returns nothing (no adds/modifications)
    # D diff returns a deleted .md file
    # infra diff returns nothing
    create_sequenced_mock "git" \
        "|0" \
        "services/compute/vm.md|0" \
        "|0"

    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value service_changed)" = "false" ]
    [ "$(get_output_value service_deleted)" = "true" ]
    [ "$(get_output_value infra_changed)" = "false" ]
}

@test "deletion of non-markdown file does not set service_deleted" {
    # D diff returns a deleted non-.md file; grep filters it out
    create_sequenced_mock "git" \
        "|0" \
        "services/compute/notes.txt|0" \
        "|0"

    run bash "$CI_SCRIPTS_DIR/validate/detect-change-scope.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value service_changed)" = "false" ]
    [ "$(get_output_value service_deleted)" = "false" ]
}
