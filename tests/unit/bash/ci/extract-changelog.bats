#!/usr/bin/env bats
# Tests for .github/scripts/release/extract-changelog.sh

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$BATS_TEST_DIRNAME/ci_test_helper.bash"

    TEST_DIR="$(mktemp -d)"
    CHANGELOG="$TEST_DIR/CHANGELOG.md"
    OUTPUT_FILE="$TEST_DIR/release-body.md"

    # Multi-version changelog fixture
    cat > "$CHANGELOG" <<'EOF'
# Changelog

## [2.0.0] - 2025-01-15

### Added
- New billing API integration
- Multi-region support

### Fixed
- Currency rounding errors

## [1.0.0] - 2024-12-01

### Added
- Initial release
- Basic pricing queries

## [1.0.0-rc.1] - 2024-11-15

### Added
- Release candidate with core features
EOF
}

teardown() {
    if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

@test "extracts existing version section" {
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "2.0.0" "$CHANGELOG" "$OUTPUT_FILE"
    [ "$status" -eq 0 ]
    [ -f "$OUTPUT_FILE" ]
    body="$(cat "$OUTPUT_FILE")"
    [[ "$body" == *"New billing API integration"* ]]
    [[ "$body" == *"Currency rounding errors"* ]]
}

@test "extracts older version from multi-version changelog" {
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "1.0.0" "$CHANGELOG" "$OUTPUT_FILE"
    [ "$status" -eq 0 ]
    body="$(cat "$OUTPUT_FILE")"
    [[ "$body" == *"Initial release"* ]]
    [[ "$body" == *"Basic pricing queries"* ]]
    # Must not include content from other versions
    [[ "$body" != *"New billing API integration"* ]]
    [[ "$body" != *"Release candidate"* ]]
}

@test "version not in changelog fails" {
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "9.9.9" "$CHANGELOG" "$OUTPUT_FILE"
    [ "$status" -eq 1 ]
    [[ "$output" == *"No changelog section"* ]]
}

@test "missing version argument fails" {
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh"
    [ "$status" -ne 0 ]
}

@test "changelog file does not exist fails" {
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "1.0.0" "$TEST_DIR/nonexistent.md" "$OUTPUT_FILE"
    [ "$status" -ne 0 ]
}

@test "empty section fails" {
    cat > "$CHANGELOG" <<'EOF'
# Changelog

## [3.0.0] - 2025-06-01

## [2.0.0] - 2025-01-15

### Added
- Something
EOF
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "3.0.0" "$CHANGELOG" "$OUTPUT_FILE"
    [ "$status" -eq 1 ]
    [[ "$output" == *"No changelog section"* ]]
}

@test "section with special characters is preserved" {
    cat > "$CHANGELOG" <<'EOF'
# Changelog

## [4.0.0] - 2025-06-01

### Changed
- Updated `Get-AzurePricing` to handle [brackets] correctly
- See [docs](https://example.com) for details
- Prices like $10.00 & €9.50 are supported
EOF
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "4.0.0" "$CHANGELOG" "$OUTPUT_FILE"
    [ "$status" -eq 0 ]
    body="$(cat "$OUTPUT_FILE")"
    [[ "$body" == *'`Get-AzurePricing`'* ]]
    [[ "$body" == *"[brackets]"* ]]
    [[ "$body" == *"[docs](https://example.com)"* ]]
}

@test "custom output file path is used" {
    custom_output="$TEST_DIR/custom-output.md"
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "2.0.0" "$CHANGELOG" "$custom_output"
    [ "$status" -eq 0 ]
    [ -f "$custom_output" ]
    body="$(cat "$custom_output")"
    [[ "$body" == *"New billing API integration"* ]]
}

@test "version with prerelease tag is extracted" {
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "1.0.0-rc.1" "$CHANGELOG" "$OUTPUT_FILE"
    [ "$status" -eq 0 ]
    body="$(cat "$OUTPUT_FILE")"
    [[ "$body" == *"Release candidate with core features"* ]]
}

@test "version with build metadata is extracted" {
    cat > "$CHANGELOG" <<'EOF'
# Changelog

## [1.0.0+build.123] - 2025-07-01

### Added
- Build metadata version support
EOF
    run bash "$CI_SCRIPTS_DIR/release/extract-changelog.sh" "1.0.0+build.123" "$CHANGELOG" "$OUTPUT_FILE"
    [ "$status" -eq 0 ]
    body="$(cat "$OUTPUT_FILE")"
    [[ "$body" == *"Build metadata version support"* ]]
}
