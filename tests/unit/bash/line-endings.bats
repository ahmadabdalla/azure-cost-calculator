#!/usr/bin/env bats
# Regression test: ensure shell scripts never have CRLF line endings.
# CRLF causes bash to crash with "set: pipefail: invalid option name"
# on Linux/macOS. The .gitattributes rules enforce LF on checkout, but
# this test catches mistakes before they reach CI.

setup() {
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
}

# Assert no files matching the given extension contain CRLF.
# Usage: assert_no_crlf "*.sh"
assert_no_crlf() {
    local pattern="$1"
    local bad=()
    while IFS= read -r -d '' f; do
        if grep -qP '\r$' "$f"; then
            bad+=("$f")
        fi
    done < <(find "$REPO_ROOT" -name "$pattern" -not -path '*/node_modules/*' -print0)

    if (( ${#bad[@]} > 0 )); then
        printf 'CRLF found in:\n'
        printf '  %s\n' "${bad[@]}"
        return 1
    fi
}

@test "no .sh files contain CRLF line endings" {
    assert_no_crlf '*.sh'
}

@test "no .bash files contain CRLF line endings" {
    assert_no_crlf '*.bash'
}

@test "no .bats files contain CRLF line endings" {
    assert_no_crlf '*.bats'
}
