# Builds an OData $filter string from field=value pairs.
# Supports equality filters and contains() operators.
#
# Usage (sourced):
#   source lib/build-odata-filter.sh
#   build_odata_filter "serviceName=Virtual Machines" "armRegionName=eastus" "contains:productName=redis"

build_odata_filter() {
    local parts=()
    local arg
    local rest field value sq="'"
    for arg in "$@"; do
        if [[ "$arg" == contains:* ]]; then
            # contains:field=value -> contains(field, 'value')
            rest="${arg#contains:}"
            field="${rest%%=*}"
            value="${rest#*=}"
            value="${value//$sq/$sq$sq}"
            local lower_value
            lower_value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
            parts+=("contains(tolower($field), '$lower_value')")
        else
            field="${arg%%=*}"
            value="${arg#*=}"
            value="${value//$sq/$sq$sq}"
            if [[ -n "$value" ]]; then
                parts+=("$field eq '$value'")
            fi
        fi
    done

    if (( ${#parts[@]} == 0 )); then
        echo ""
        return
    fi
    local result="${parts[0]}"
    local i
    for (( i=1; i<${#parts[@]}; i++ )); do
        result+=" and ${parts[$i]}"
    done
    echo "$result"
}
