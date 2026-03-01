#!/usr/bin/env bash
set -euo pipefail

# Runs bats-core unit tests for the skill's Bash scripts.
#
# Prerequisites: bats-core must be installed.
#   macOS:  brew install bats-core
#   Ubuntu: sudo apt-get install bats
#   npm:    npm install -g bats
#
# Usage:
#   bash tests/unit/run-bats-tests.sh             # run all bash tests
#   bash tests/unit/run-bats-tests.sh --tap        # TAP output for CI
#   bash tests/unit/run-bats-tests.sh path.bats    # run specific file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASH_TEST_DIR="$SCRIPT_DIR/bash"

# Check bats-core is installed
if ! command -v bats &>/dev/null; then
    echo "Error: bats-core is not installed." >&2
    echo "" >&2
    echo "Install it via one of:" >&2
    echo "  macOS:  brew install bats-core" >&2
    echo "  Ubuntu: sudo apt-get install bats" >&2
    echo "  npm:    npm install -g bats" >&2
    exit 1
fi

# Parse arguments
bats_args=()
test_files=()
for arg in "$@"; do
    case "$arg" in
        --tap|--pretty|--junit|--verbose-run)
            bats_args+=("$arg")
            ;;
        *.bats)
            test_files+=("$arg")
            ;;
        *)
            bats_args+=("$arg")
            ;;
    esac
done

# Default: run all .bats files recursively
if (( ${#test_files[@]} == 0 )); then
    while IFS= read -r -d '' f; do
        test_files+=("$f")
    done < <(find "$BASH_TEST_DIR" -name '*.bats' -print0 | sort -z)
fi

if (( ${#test_files[@]} == 0 )); then
    echo "No .bats test files found in $BASH_TEST_DIR" >&2
    exit 1
fi

echo "Running ${#test_files[@]} bats test file(s)..."
if (( ${#bats_args[@]} > 0 )); then
    bats "${bats_args[@]}" "${test_files[@]}"
else
    bats "${test_files[@]}"
fi
