#!/usr/bin/env bash
# Maps a unitOfMeasure string to a monthly multiplier.
# Hourly units return $hours_month; daily units return 30; everything else returns 1.
#
# Usage: get_monthly_multiplier "1 Hour" [hours_month]

get_monthly_multiplier() {
    local unit_of_measure="$1"
    local hours_month="${2:-730}"

    case "$unit_of_measure" in
        1\ Hour*)
            echo "$hours_month"
            ;;
        "1/Hour")
            echo "$hours_month"
            ;;
        "1 GiB Hour")
            echo "$hours_month"
            ;;
        "1/Day")
            echo 30
            ;;
        *)
            echo 1
            ;;
    esac
}
