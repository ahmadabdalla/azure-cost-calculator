#!/usr/bin/env bats

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$LIB_DIR/get-reservation-term-months.sh"
}

@test "1 Year returns 12" {
    run get_reservation_term_months "1 Year"
    [ "$status" -eq 0 ]
    [ "$output" = "12" ]
}

@test "3 Years returns 36" {
    run get_reservation_term_months "3 Years"
    [ "$status" -eq 0 ]
    [ "$output" = "36" ]
}

@test "5 Years returns 60" {
    run get_reservation_term_months "5 Years"
    [ "$status" -eq 0 ]
    [ "$output" = "60" ]
}

@test "unknown term produces no output" {
    run get_reservation_term_months "2 Years"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "empty input produces no output" {
    run get_reservation_term_months ""
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "no arguments produces no output" {
    run get_reservation_term_months
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "case sensitive - lowercase does not match" {
    run get_reservation_term_months "1 year"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "extra whitespace does not match" {
    run get_reservation_term_months "1  Year"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
