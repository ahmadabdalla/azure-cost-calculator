#!/usr/bin/env bash
# Maps a reservationTerm string to the number of months in the term.
# Returns the month count on stdout, or nothing for null/empty/unrecognized inputs.
# Always exits 0 (safe for set -e callers).
#
# Usage: term_months=$(get_reservation_term_months "1 Year")

get_reservation_term_months() {
    local reservation_term="$1"

    case "$reservation_term" in
        "1 Year")   echo 12 ;;
        "3 Years")  echo 36 ;;
        "5 Years")  echo 60 ;;
        *)          ;;
    esac
}
