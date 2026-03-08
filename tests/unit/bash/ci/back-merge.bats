#!/usr/bin/env bats
# Tests for .github/scripts/release/back-merge.sh
#
# The back-merge script calls git many times with different subcommands, so we
# use a custom case-based mock instead of the standard dispatch mock.

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
    setup_mock_path
    setup_github_output
}

teardown() {
    teardown_github_output
    teardown_mock_path
}

# Configurable git mock with per-operation exit codes.
# Args: fetch_rc merge_rc theirs_merge_rc push_rc
setup_git_mock() {
    local fetch_rc="${1:-0}" merge_rc="${2:-0}" theirs_rc="${3:-0}" push_rc="${4:-0}"
    cat > "$MOCK_DIR/git" <<MOCK
#!/usr/bin/env bash
case "\$*" in
    *config*)          exit 0 ;;
    *reset*)           exit 0 ;;
    *fetch*)           exit $fetch_rc ;;
    *"merge --abort"*) exit 0 ;;
    *merge*theirs*)    exit $theirs_rc ;;
    *merge*)           exit $merge_rc ;;
    *push*)            exit $push_rc ;;
    *)                 exit 0 ;;
esac
MOCK
    chmod +x "$MOCK_DIR/git"
}

# Stateful git mock: first push fails, second succeeds (simulates push race).
setup_push_race_then_success_mock() {
    mkdir -p "$MOCK_DIR/git_counters"
    echo "0" > "$MOCK_DIR/git_counters/push"
    cat > "$MOCK_DIR/git" <<'MOCK'
#!/usr/bin/env bash
case "$*" in
    *config*|*reset*|*fetch*|*"merge --abort"*) exit 0 ;;
    *merge*) exit 0 ;;
    *push*)
        dir="$(dirname "$0")/git_counters"
        n=$(cat "$dir/push")
        echo $((n+1)) > "$dir/push"
        if [ "$n" -eq 0 ]; then exit 1; fi
        exit 0
        ;;
    *) exit 0 ;;
esac
MOCK
    chmod +x "$MOCK_DIR/git"
}

@test "clean merge succeeds on first attempt" {
    setup_git_mock 0 0 0 0
    run bash "$CI_SCRIPTS_DIR/release/back-merge.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value result)" = "success" ]
    [ "$(get_output_value fallback_reason)" = "none" ]
}

@test "normal merge conflicts then theirs strategy succeeds" {
    setup_git_mock 0 10 0 0
    run bash "$CI_SCRIPTS_DIR/release/back-merge.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value result)" = "success" ]
    [ "$(get_output_value fallback_reason)" = "none" ]
}

@test "push race on first attempt then succeeds on retry" {
    setup_push_race_then_success_mock
    run bash "$CI_SCRIPTS_DIR/release/back-merge.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value result)" = "success" ]
    [ "$(get_output_value fallback_reason)" = "none" ]
}

@test "unresolvable conflict when both merge strategies fail" {
    setup_git_mock 0 10 10 0
    run bash "$CI_SCRIPTS_DIR/release/back-merge.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value result)" = "conflict" ]
    [ "$(get_output_value fallback_reason)" = "unresolved_conflict" ]
}

@test "fetch failure on all attempts" {
    setup_git_mock 128 0 0 0
    run bash "$CI_SCRIPTS_DIR/release/back-merge.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value result)" = "conflict" ]
    [ "$(get_output_value fallback_reason)" = "fetch_failure" ]
}

@test "push race on all attempts exhausts retries" {
    setup_git_mock 0 0 0 1
    run bash "$CI_SCRIPTS_DIR/release/back-merge.sh"
    [ "$status" -eq 0 ]
    [ "$(get_output_value result)" = "conflict" ]
    [ "$(get_output_value fallback_reason)" = "push_race" ]
}
