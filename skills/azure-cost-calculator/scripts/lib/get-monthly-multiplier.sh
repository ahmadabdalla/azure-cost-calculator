#!/usr/bin/env bash
# Maps a unitOfMeasure string to a monthly multiplier.
# Hourly units return hours_per_month; everything else returns 1.
#
# Usage (sourced):
#   source lib/get-monthly-multiplier.sh
#   multiplier=$(get_monthly_multiplier "1 Hour" 730)

get_monthly_multiplier() {
    local unit_of_measure="$1"
    local hours_per_month="${2:-730}"

    case "$unit_of_measure" in
        "1 Hour"*|"1/Hour"|"1 GiB Hour")
            echo "$hours_per_month"
            ;;
        *)
            echo "1"
            ;;
    esac
}
