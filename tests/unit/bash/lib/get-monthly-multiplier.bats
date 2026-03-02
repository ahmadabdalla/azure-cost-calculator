#!/usr/bin/env bats

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$LIB_DIR/get-monthly-multiplier.sh"
}

@test "1 Hour returns default 730" {
    run get_monthly_multiplier "1 Hour"
    [ "$status" -eq 0 ]
    [ "$output" = "730" ]
}

@test "1/Hour returns default 730" {
    run get_monthly_multiplier "1/Hour"
    [ "$status" -eq 0 ]
    [ "$output" = "730" ]
}

@test "1 GiB Hour returns default 730" {
    run get_monthly_multiplier "1 GiB Hour"
    [ "$status" -eq 0 ]
    [ "$output" = "730" ]
}

@test "1/Day returns 30" {
    run get_monthly_multiplier "1/Day"
    [ "$status" -eq 0 ]
    [ "$output" = "30" ]
}

@test "unknown unit returns 1" {
    run get_monthly_multiplier "1 GB"
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
}

@test "empty string returns 1 via wildcard" {
    run get_monthly_multiplier ""
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
}

@test "1 Hour with custom hours_month" {
    run get_monthly_multiplier "1 Hour" "744"
    [ "$status" -eq 0 ]
    [ "$output" = "744" ]
}

@test "1/Hour with custom hours_month" {
    run get_monthly_multiplier "1/Hour" "744"
    [ "$status" -eq 0 ]
    [ "$output" = "744" ]
}

@test "1 GiB Hour with custom hours_month" {
    run get_monthly_multiplier "1 GiB Hour" "744"
    [ "$status" -eq 0 ]
    [ "$output" = "744" ]
}

@test "1/Day ignores custom hours_month" {
    run get_monthly_multiplier "1/Day" "744"
    [ "$status" -eq 0 ]
    [ "$output" = "30" ]
}

@test "wildcard ignores custom hours_month" {
    run get_monthly_multiplier "1 Month" "744"
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
}

@test "1 Hour prefix with extra text matches wildcard pattern" {
    run get_monthly_multiplier "1 Hours of compute"
    [ "$status" -eq 0 ]
    [ "$output" = "730" ]
}

@test "1 Hour followed by suffix still matches" {
    run get_monthly_multiplier "1 Hour(s)"
    [ "$status" -eq 0 ]
    [ "$output" = "730" ]
}
