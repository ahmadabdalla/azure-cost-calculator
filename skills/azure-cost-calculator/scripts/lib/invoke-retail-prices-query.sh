# Queries the Azure Retail Prices API with OData filter, handling pagination.
# Returns a JSON array of pricing items on stdout.
#
# Usage (sourced):
#   source lib/invoke-retail-prices-query.sh
#   invoke_retail_prices_query "$filter_string" "USD" 100

invoke_retail_prices_query() {
    local filter="$1"
    local currency_code="${2:-USD}"
    local max_items="${3:-100}"

    local -r base_uri="https://prices.azure.com/api/retail/prices"
    local encoded_filter
    encoded_filter=$(jq -rn --arg f "$filter" '$f | @uri')

    local uri="${base_uri}?\$filter=${encoded_filter}&currencyCode=${currency_code}"
    local all_items="[]"
    local count=0

    while [[ -n "$uri" ]]; do
        local raw_output
        raw_output=$(curl -s --connect-timeout 10 --max-time 30 -w '\n%{http_code}' "$uri") || {
            echo "Error: API request failed (curl error) for URI: $uri" >&2
            return 1
        }
        local http_code
        http_code=$(tail -n1 <<< "$raw_output")
        local response
        response=$(sed '$d' <<< "$raw_output")

        if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
            echo "Error: API request failed with HTTP $http_code for URI: $uri" >&2
            return 1
        fi

        local page_items
        page_items=$(jq -c '.Items // []' <<< "$response")
        all_items=$(jq -c -n --argjson a "$all_items" --argjson b "$page_items" '$a + $b')
        count=$(jq 'length' <<< "$all_items")

        if (( count >= max_items )); then
            break
        fi

        uri=$(jq -r '.NextPageLink // empty' <<< "$response")
    done

    echo "$all_items"
}
