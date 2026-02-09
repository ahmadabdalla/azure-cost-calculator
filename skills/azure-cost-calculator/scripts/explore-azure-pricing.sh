#!/usr/bin/env bash
set -euo pipefail

# Discovers available Azure pricing filter values for unknown or new resource types.
# Produces identical JSON output to Explore-AzurePricing.ps1 for the same inputs.
#
# Examples:
#   ./explore-azure-pricing.sh --service-name 'Azure Container Apps'
#   ./explore-azure-pricing.sh --search-term 'redis' --top 50
#   ./explore-azure-pricing.sh --service-name 'Azure Container Apps' --currency 'EUR'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check dependencies
for cmd in curl jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not found in PATH." >&2
        exit 1
    fi
done

# Source library functions
source "$SCRIPT_DIR/lib/build-odata-filter.sh"
source "$SCRIPT_DIR/lib/invoke-retail-prices-query.sh"

# ============================================================
# Defaults
# ============================================================
service_name=""
search_term=""
region="eastus"
currency="USD"
top=20
output_format="Json"

# ============================================================
# Argument parsing
# ============================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --service-name)   service_name="$2"; shift 2 ;;
        --search-term)    search_term="$2"; shift 2 ;;
        --region)         region="$2"; shift 2 ;;
        --currency)       currency="$2"; shift 2 ;;
        --top)            top="$2"; shift 2 ;;
        --output-format)  output_format="$2"; shift 2 ;;
        *)
            echo "Error: Unknown argument '$1'" >&2
            exit 1
            ;;
    esac
done

if [[ -z "$service_name" && -z "$search_term" ]]; then
    echo "Error: Provide either --service-name (exact match) or --search-term (fuzzy contains search)." >&2
    exit 1
fi

# ============================================================
# Build filter and query
# ============================================================
filter_args=("armRegionName=$region")

if [[ -n "$service_name" ]]; then
    filter_args+=("serviceName=$service_name")
fi

if [[ -n "$search_term" ]]; then
    filter_args+=("contains:productName=$search_term")
fi

filter_string=$(build_odata_filter "${filter_args[@]}")

max_items=$(( top * 5 ))
items=$(invoke_retail_prices_query "$filter_string" "$currency" "$max_items") || {
    echo "Warning: API request failed. Filter: $filter_string" >&2
    exit 1
}

item_count=$(echo "$items" | jq 'length')
if (( item_count == 0 )); then
    echo "Warning: No results found. Filter: $filter_string" >&2
    exit 0
fi

# Deduplicate to distinct combinations and take top N
distinct=$(echo "$items" | jq -c --argjson top "$top" '
    group_by("\(.serviceName)|\(.productName)|\(.skuName)|\(.meterName)|\(.armSkuName)|\(.unitOfMeasure)")
    | map(first)
    | [limit($top; .[])]
    | map({
        ServiceName: .serviceName,
        ProductName: .productName,
        SkuName: .skuName,
        MeterName: .meterName,
        ArmSkuName: .armSkuName,
        UnitOfMeasure: .unitOfMeasure,
        SamplePrice: .retailPrice
    })
')

# ============================================================
# Output
# ============================================================
case "$output_format" in
    Table)
        echo "$distinct" | jq -r '
            sort_by(.ServiceName, .ProductName, .SkuName)
            | ["ServiceName","ProductName","SkuName","MeterName","ArmSkuName","UnitOfMeasure","SamplePrice"],
              (.[] | [.ServiceName, .ProductName, .SkuName, .MeterName,
                      (.ArmSkuName // ""), .UnitOfMeasure,
                      (.SamplePrice | tostring)])
            | @tsv
        ' | column -t -s $'\t'
        ;;
    Json)
        echo "$distinct" | jq .
        ;;
    *)
        echo "Error: Invalid --output-format '$output_format'. Use Table or Json." >&2
        exit 1
        ;;
esac
