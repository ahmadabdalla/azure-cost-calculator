#!/usr/bin/env bash
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

    local base_uri="https://prices.azure.com/api/retail/prices"
    local encoded_filter
    encoded_filter=$(jq -rn --arg f "$filter" '$f | @uri')

    local uri="${base_uri}?\$filter=${encoded_filter}&currencyCode=${currency_code}"
    local all_items="[]"
    local count=0

    while [[ -n "$uri" ]]; do
        local response
        response=$(curl -s -f "$uri") || {
            echo "Error: API request failed for URI: $uri" >&2
            return 1
        }

        local page_items
        page_items=$(echo "$response" | jq -c '.Items // []')
        all_items=$(jq -c -n --argjson a "$all_items" --argjson b "$page_items" '$a + $b')
        count=$(echo "$all_items" | jq 'length')

        if (( count >= max_items )); then
            break
        fi

        uri=$(echo "$response" | jq -r '.NextPageLink // empty')
    done

    echo "$all_items"
}
