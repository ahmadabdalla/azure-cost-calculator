#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Error on line $LINENO" >&2' ERR

# Discovers available Azure pricing filter values for unknown or new resource types.
# Produces identical JSON output to Explore-AzurePricing.ps1 for the same inputs.
#
# Examples:
#   ./explore-azure-pricing.sh --service-name 'Azure Container Apps'
#   ./explore-azure-pricing.sh --search-term 'redis' --top 50
#   ./explore-azure-pricing.sh --service-name 'Azure Container Apps' --currency 'EUR'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

validate_integer() {
    local name="$1" value="$2"
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "Error: $name must be an integer, got '$value'" >&2
        exit 1
    fi
}

# ============================================================
# Defaults
# ============================================================
service_name=""
search_term=""
region="eastus"
currency="USD"
top=20
output_format="Json"
verbose=false

# ============================================================
# Argument parsing
# ============================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v|--help|-h) ;;
        --*) [[ $# -lt 2 ]] && { echo "Error: $1 requires a value" >&2; exit 1; } ;;
    esac
    case "$1" in
        --service-name)   service_name="$2"; shift 2 ;;
        --search-term)    search_term="$2"; shift 2 ;;
        --region)         region="$2"; shift 2 ;;
        --currency|--currency-code) currency="$2"; shift 2 ;;
        --top)            top="$2"; shift 2 ;;
        --output-format)  output_format="$2"; shift 2 ;;
        --verbose|-v)     verbose=true; shift ;;
        --help|-h)
            cat <<'USAGE'
explore-azure-pricing.sh - Discover available Azure pricing filter values.

Flags:
  --service-name NAME     Service name (exact match)
  --search-term TERM      Fuzzy contains search on productName
  --region REGION         Region filter (default: eastus)
  --currency CODE         Currency code (default: USD)
  --top N                 Number of distinct results (default: 20)
  --output-format FMT     Table|Json (default: Json)
  --verbose|-v            Emit OData filter to stderr
  --help|-h               Show this help
USAGE
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'. Valid flags: --service-name, --search-term, --region, --currency, --top, --output-format, --verbose, --help" >&2
            exit 1
            ;;
    esac
done

# Validate numeric arguments
validate_integer "top" "$top"

# Validate enum arguments
case "$output_format" in
    Table|Json) ;;
    *) echo "Error: --output-format must be Table or Json, got '$output_format'" >&2; exit 1 ;;
esac

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
[[ "$verbose" == true ]] && echo "Filter: $filter_string" >&2

max_items=$(( top * 5 ))
items=$(invoke_retail_prices_query "$filter_string" "$currency" "$max_items") || {
    echo "Warning: API request failed. Filter: $filter_string" >&2
    exit 1
}

item_count=$(jq 'length' <<< "$items")
if (( item_count == 0 )); then
    echo "Warning: No results found. Filter: $filter_string" >&2
    exit 2
fi

# Deduplicate to distinct combinations and take top N
distinct=$(jq -c --argjson top "$top" '
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
' <<< "$items")

# ============================================================
# Output
# ============================================================
case "$output_format" in
    Table)
        jq -r '
            sort_by(.ServiceName, .ProductName, .SkuName)
            | ["ServiceName","ProductName","SkuName","MeterName","ArmSkuName","UnitOfMeasure","SamplePrice"],
              (.[] | [.ServiceName, .ProductName, .SkuName, .MeterName,
                      (.ArmSkuName // ""), .UnitOfMeasure,
                      (.SamplePrice | tostring)])
            | @tsv
        ' <<< "$distinct"
        ;;
    Json)
        jq 'if type == "array" then . else [.] end' <<< "$distinct"
        ;;
    *)
        echo "Error: Invalid --output-format '$output_format'. Use Table or Json." >&2
        exit 1
        ;;
esac
