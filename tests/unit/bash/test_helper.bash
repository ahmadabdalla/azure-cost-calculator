# Shared helpers for bats unit tests.
#
# Source this file in setup() to get access to helper functions and the
# path to the scripts under test.
#
# Usage (in a .bats file):
#   setup() { source "$BATS_TEST_DIRNAME/../test_helper.bash"; }

# Absolute path to the skill scripts directory
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/skills/azure-cost-calculator/scripts"
LIB_DIR="$SCRIPTS_DIR/lib"

# Create a temporary directory for mock scripts. Cleaned up in teardown.
setup_mock_path() {
    MOCK_DIR="$(mktemp -d)"
    # Prepend mock dir to PATH so mock scripts shadow real commands
    PATH="$MOCK_DIR:$PATH"
    export PATH MOCK_DIR
}

# Clean up mock directory
teardown_mock_path() {
    if [[ -n "${MOCK_DIR:-}" && -d "$MOCK_DIR" ]]; then
        rm -rf "$MOCK_DIR"
    fi
}

# Create a mock executable that echoes the given output.
# Usage: create_mock "curl" '{"Items":[],"NextPageLink":null}'
create_mock() {
    local cmd_name="$1"
    local output="$2"
    local exit_code="${3:-0}"

    printf '%s' "$output" > "$MOCK_DIR/${cmd_name}_output"
    cat > "$MOCK_DIR/$cmd_name" <<'SCRIPT'
#!/usr/bin/env bash
cat "$(dirname "$0")/$(basename "$0")_output"
exit_code_file="$(dirname "$0")/$(basename "$0")_exit"
if [[ -f "$exit_code_file" ]]; then exit "$(cat "$exit_code_file")"; fi
SCRIPT
    printf '%s' "$exit_code" > "$MOCK_DIR/${cmd_name}_exit"
    chmod +x "$MOCK_DIR/$cmd_name"
}

# Create a mock that writes specific stdout and appends http_code on a new line
# (mimics curl -w '\n%{http_code}' behaviour).
# Usage: create_curl_mock '{"Items":[],"NextPageLink":null}' 200
create_curl_mock() {
    local body="$1"
    local http_code="${2:-200}"

    printf '%s' "$body" > "$MOCK_DIR/curl_body"
    printf '%s' "$http_code" > "$MOCK_DIR/curl_code"
    cat > "$MOCK_DIR/curl" <<'SCRIPT'
#!/usr/bin/env bash
dir="$(dirname "$0")"
printf '%s\n%s' "$(cat "$dir/curl_body")" "$(cat "$dir/curl_code")"
SCRIPT
    chmod +x "$MOCK_DIR/curl"
}
