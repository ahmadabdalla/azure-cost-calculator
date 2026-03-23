# shellcheck shell=bash
# Queries the Azure Retail Prices API with OData filter, handling pagination.
# Returns a JSON array of pricing items on stdout.
#
# Usage (sourced):
#   source lib/invoke-retail-prices-query.sh
#   invoke_retail_prices_query "$filter_string" "USD" 100
#
# Optional env vars:
#   RETAIL_API_MAX_ATTEMPTS  : max total attempts per request (default: 3)
#   RETAIL_API_BASE_DELAY    : base delay in seconds for exponential backoff (default: 2)

invoke_retail_prices_query() {
    local filter="$1"
    local currency_code="${2:-USD}"
    local max_items="${3:-100}"
    local max_attempts="${RETAIL_API_MAX_ATTEMPTS:-3}"
    local base_delay="${RETAIL_API_BASE_DELAY:-2}"

    if ! [[ "$max_attempts" =~ ^[0-9]+$ ]] || (( max_attempts < 1 )); then
        echo "Error: RETAIL_API_MAX_ATTEMPTS must be a positive integer, got: '$max_attempts'" >&2
        return 1
    fi
    if ! [[ "$base_delay" =~ ^[0-9]+$ ]] || (( base_delay < 1 )); then
        echo "Error: RETAIL_API_BASE_DELAY must be a positive integer, got: '$base_delay'" >&2
        return 1
    fi

    local -r base_uri="https://prices.azure.com/api/retail/prices"
    local encoded_filter
    encoded_filter=$(jq -rn --arg f "$filter" '$f | @uri')
    local encoded_currency
    encoded_currency=$(jq -rn --arg c "$currency_code" '$c | @uri')

    local uri="${base_uri}?\$filter=${encoded_filter}&currencyCode=${encoded_currency}"
    local all_items="[]"
    local count=0

    while [[ -n "$uri" ]]; do
        local raw_output=""
        local http_code=""
        local response=""
        local attempt

        for (( attempt = 1; attempt <= max_attempts; attempt++ )); do
            raw_output=$(curl -s --connect-timeout 10 --max-time 30 -w '\n%{http_code}' "$uri") || {
                if (( attempt == max_attempts )); then
                    echo "Error: API request failed (curl error) for URI: $uri" >&2
                    return 1
                fi
                local delay=$(( base_delay * (1 << (attempt - 1)) ))
                echo "Warning: API request failed (attempt $attempt/$max_attempts). Retrying in ${delay}s..." >&2
                sleep "$delay"
                continue
            }
            http_code=$(tail -n1 <<< "$raw_output")
            response=$(sed '$d' <<< "$raw_output")

            if [[ "$http_code" -eq 429 || "$http_code" -ge 500 ]]; then
                if (( attempt == max_attempts )); then
                    echo "Error: API request failed with HTTP $http_code for URI: $uri" >&2
                    return 1
                fi
                local delay=$(( base_delay * (1 << (attempt - 1)) ))
                echo "Warning: HTTP $http_code (attempt $attempt/$max_attempts). Retrying in ${delay}s..." >&2
                sleep "$delay"
                continue
            fi

            if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
                echo "Error: API request failed with HTTP $http_code for URI: $uri" >&2
                return 1
            fi

            # Success: break out of retry loop
            break
        done

        local page_items
        page_items=$(jq -c '.Items // []' <<< "$response") || {
            echo "Error: Invalid JSON response from API" >&2
            return 1
        }
        all_items=$(printf '%s\n%s' "$all_items" "$page_items" | jq -c -s '.[0] + .[1]')
        count=$(jq 'length' <<< "$all_items")

        if (( count >= max_items )); then
            break
        fi

        uri=$(jq -r '.NextPageLink // empty' <<< "$response")
    done

    echo "$all_items"
}
