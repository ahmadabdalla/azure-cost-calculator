#!/usr/bin/env bash
# Builds an OData $filter string from field=value pairs.
# Supports equality filters and contains() operators.
#
# Usage (sourced):
#   source lib/build-odata-filter.sh
#   build_odata_filter "serviceName=Virtual Machines" "armRegionName=eastus" "contains:productName=redis"

build_odata_filter() {
    local parts=()
    for arg in "$@"; do
        if [[ "$arg" == contains:* ]]; then
            # contains:field=value -> contains(field, 'value')
            local rest="${arg#contains:}"
            local field="${rest%%=*}"
            local value="${rest#*=}"
            parts+=("contains($field, '$value')")
        else
            local field="${arg%%=*}"
            local value="${arg#*=}"
            if [[ -n "$value" ]]; then
                parts+=("$field eq '$value'")
            fi
        fi
    done

    local result=""
    for (( i=0; i<${#parts[@]}; i++ )); do
        if (( i > 0 )); then
            result+=" and "
        fi
        result+="${parts[$i]}"
    done
    echo "$result"
}
