# Shared helpers for bats tests of CI scripts (.github/scripts/).
#
# Source this after test_helper.bash in setup() to get CI-specific
# mock utilities (GITHUB_OUTPUT, git dispatch, gh CLI dispatch, etc.).
#
# Usage (in a .bats file):
#   setup() {
#       source "$BATS_TEST_DIRNAME/../test_helper.bash"
#       source "$BATS_TEST_DIRNAME/ci_test_helper.bash"
#   }

# Absolute path to .github/scripts/
CI_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)/.github/scripts"

# Re-source the base helper so callers can source this file alone if needed
source "$(dirname "${BASH_SOURCE[0]}")/../test_helper.bash"

# ---------------------------------------------------------------------------
# GITHUB_OUTPUT mocking
# ---------------------------------------------------------------------------

# Create a temp file to stand in for $GITHUB_OUTPUT.
setup_github_output() {
    GITHUB_OUTPUT="$(mktemp)"
    export GITHUB_OUTPUT
}

# Remove the temp GITHUB_OUTPUT file.
teardown_github_output() {
    if [[ -n "${GITHUB_OUTPUT:-}" && -f "$GITHUB_OUTPUT" ]]; then
        rm -f "$GITHUB_OUTPUT"
    fi
}

# Read a simple key=value line from GITHUB_OUTPUT.
# Usage: get_output_value "infra_changed"
get_output_value() {
    local key="$1"
    grep "^${key}=" "$GITHUB_OUTPUT" | head -1 | cut -d= -f2-
}

# Read a heredoc-style value from GITHUB_OUTPUT.
# Format written by Actions:
#   key<<DELIMITER
#   ...value lines...
#   DELIMITER
get_output_heredoc() {
    local key="$1"
    awk -v key="$key" '
        BEGIN { found=0; delim="" }
        !found && $0 ~ "^" key "<<" {
            delim = substr($0, length(key) + 3)
            found = 1
            next
        }
        found && $0 == delim { exit }
        found { print }
    ' "$GITHUB_OUTPUT"
}

# ---------------------------------------------------------------------------
# Git dispatch mock: routes by subcommand
# ---------------------------------------------------------------------------

# Creates a mock git executable that dispatches based on the first
# non-flag argument (e.g. "diff", "rev-parse"). Per-subcommand responses
# are stored in $MOCK_DIR/git_state/.
create_git_dispatch_mock() {
    mkdir -p "$MOCK_DIR/git_state"
    cat > "$MOCK_DIR/git" <<'SCRIPT'
#!/usr/bin/env bash
dir="$(dirname "$0")/git_state"
# Log every call with shell-escaped args so tests can verify arguments
printf '%q ' "$@" >> "$dir/call_log"
printf '\n' >> "$dir/call_log"
# Find the first non-flag argument (subcommand)
subcmd=""
for arg in "$@"; do
    case "$arg" in
        -*) continue ;;
        *)  subcmd="$arg"; break ;;
    esac
done
if [[ -z "$subcmd" ]]; then subcmd="_default"; fi
out_file="$dir/${subcmd}_output"
exit_file="$dir/${subcmd}_exit"
if [[ -f "$out_file" ]]; then cat "$out_file"; fi
if [[ -f "$exit_file" ]]; then exit "$(cat "$exit_file")"; fi
SCRIPT
    chmod +x "$MOCK_DIR/git"
}

# Configure the response for a git subcommand.
# Usage: set_git_response "rev-parse" "" 128
set_git_response() {
    local subcmd="$1" output="$2" exit_code="${3:-0}"
    printf '%s' "$output" > "$MOCK_DIR/git_state/${subcmd}_output"
    printf '%s' "$exit_code" > "$MOCK_DIR/git_state/${subcmd}_exit"
}

# ---------------------------------------------------------------------------
# Sequenced mock: different output per invocation
# ---------------------------------------------------------------------------

# Create a mock that returns different output on each successive call.
# Usage: create_sequenced_mock "git" "line1|0" "line2|0" "line3|1"
#   Each argument after the command name is "output|exit_code".
create_sequenced_mock() {
    local cmd_name="$1"; shift
    local state_dir="$MOCK_DIR/${cmd_name}_seq"
    mkdir -p "$state_dir"

    local idx=0
    for spec in "$@"; do
        local out="${spec%|*}"
        local ec="${spec##*|}"
        printf '%s' "$out" > "$state_dir/out_${idx}"
        printf '%s' "$ec"  > "$state_dir/ec_${idx}"
        idx=$((idx + 1))
    done
    printf '0' > "$state_dir/counter"

    cat > "$MOCK_DIR/$cmd_name" <<SCRIPT
#!/usr/bin/env bash
state_dir="$state_dir"
# Log every call with shell-escaped args so tests can verify arguments
printf '%q ' "\$@" >> "\$state_dir/call_log"
printf '\n' >> "\$state_dir/call_log"
counter=\$(cat "\$state_dir/counter")
out_file="\$state_dir/out_\${counter}"
ec_file="\$state_dir/ec_\${counter}"
# Advance counter for next call
echo \$((counter + 1)) > "\$state_dir/counter"
if [[ -f "\$out_file" ]]; then cat "\$out_file"; fi
ec=0
if [[ -f "\$ec_file" ]]; then ec=\$(cat "\$ec_file"); fi
exit "\$ec"
SCRIPT
    chmod +x "$MOCK_DIR/$cmd_name"
}

# ---------------------------------------------------------------------------
# gh CLI dispatch mock: routes by "$1_$2" key (e.g. "pr_list")
# ---------------------------------------------------------------------------

# Creates a mock gh executable that dispatches on the first two positional
# args joined by underscore. All invocations are logged to call_log.
create_gh_dispatch_mock() {
    mkdir -p "$MOCK_DIR/gh_state"
    cat > "$MOCK_DIR/gh" <<'SCRIPT'
#!/usr/bin/env bash
dir="$(dirname "$0")/gh_state"
key="${1:-_}_${2:-_}"
# Log every call for assertions
echo "$*" >> "$dir/call_log"
out_file="$dir/${key}_output"
exit_file="$dir/${key}_exit"
if [[ -f "$out_file" ]]; then cat "$out_file"; fi
if [[ -f "$exit_file" ]]; then exit "$(cat "$exit_file")"; fi
SCRIPT
    chmod +x "$MOCK_DIR/gh"
}

# Configure the response for a gh subcommand pair.
# Usage: set_gh_response "pr_list" '[]' 0
set_gh_response() {
    local key="$1" output="$2" exit_code="${3:-0}"
    printf '%s' "$output" > "$MOCK_DIR/gh_state/${key}_output"
    printf '%s' "$exit_code" > "$MOCK_DIR/gh_state/${key}_exit"
}
