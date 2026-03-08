#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Error on line $LINENO" >&2' ERR

# Queries the Azure Retail Prices API and calculates estimated monthly costs.
# Produces identical JSON output to Get-AzurePricing.ps1 for the same inputs.
#
# Examples:
#   ./get-azure-pricing.sh --service-name 'Virtual Machines' --arm-sku-name 'Standard_D2s_v5'
#   ./get-azure-pricing.sh --service-name 'Virtual Machines' --arm-sku-name 'Standard_D2s_v5' \
#       --region 'eastus,westeurope' --output-format Table

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
source "$SCRIPT_DIR/lib/get-monthly-multiplier.sh"

validate_number() {
    local name="$1" value="$2"
    if ! [[ "$value" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        echo "Error: $name must be a number, got '$value'" >&2
        exit 1
    fi
}

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
region="eastus"
arm_sku_name=""
sku_name=""
product_name=""
meter_name=""
price_type="Consumption"
currency="USD"
quantity=0
hours_per_month=730
instance_count=1
output_format="Json"
verbose=false

# ============================================================
# Argument parsing
# ============================================================
while [[ $# -gt 0 ]]; do
    # Guard against missing value for flags that require one
    case "$1" in
        --verbose|-v|--help|-h) ;; # no value needed
        --*) [[ $# -lt 2 ]] && { echo "Error: $1 requires a value" >&2; exit 1; } ;;
    esac
    case "$1" in
        --service-name)   service_name="$2"; shift 2 ;;
        --region)         region="$2"; shift 2 ;;
        --arm-sku-name)   arm_sku_name="$2"; shift 2 ;;
        --sku-name)       sku_name="$2"; shift 2 ;;
        --product-name)   product_name="$2"; shift 2 ;;
        --meter-name)     meter_name="$2"; shift 2 ;;
        --price-type)     price_type="$2"; shift 2 ;;
        --currency|--currency-code) currency="$2"; shift 2 ;;
        --quantity)       quantity="$2"; shift 2 ;;
        --hours-per-month) hours_per_month="$2"; shift 2 ;;
        --instance-count) instance_count="$2"; shift 2 ;;
        --output-format)  output_format="$2"; shift 2 ;;
        --verbose|-v)     verbose=true; shift ;;
        --help|-h)
            cat <<'USAGE'
get-azure-pricing.sh - Query Azure Retail Prices API and calculate monthly costs.

Flags:
  --service-name NAME     Service name (required)
  --region REGION         Comma-separated regions (default: eastus)
  --arm-sku-name SKU      ARM SKU name filter
  --sku-name SKU          SKU name filter
  --product-name NAME     Product name filter
  --meter-name NAME       Meter name filter
  --price-type TYPE       Consumption|Reservation|DevTestConsumption (default: Consumption)
  --currency CODE         Currency code (default: USD)
  --quantity NUM          Quantity (default: 0)
  --hours-per-month NUM   Hours per month (default: 730)
  --instance-count NUM    Instance count (default: 1)
  --output-format FMT     Table|Json|Summary (default: Json)
  --verbose|-v            Emit OData filter to stderr
  --help|-h               Show this help
USAGE
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'. Valid flags: --service-name, --region, --arm-sku-name, --sku-name, --product-name, --meter-name, --price-type, --currency, --quantity, --hours-per-month, --instance-count, --output-format, --verbose, --help" >&2
            exit 1
            ;;
    esac
done

# Validate numeric arguments
validate_number "quantity" "$quantity"
validate_number "hours_per_month" "$hours_per_month"
validate_integer "instance_count" "$instance_count"

# Validate enum arguments
case "$output_format" in
    Table|Json|Summary) ;;
    *) echo "Error: --output-format must be Table, Json, or Summary, got '$output_format'" >&2; exit 1 ;;
esac
case "$price_type" in
    Consumption|Reservation|DevTestConsumption) ;;
    *) echo "Error: --price-type must be Consumption, Reservation, or DevTestConsumption, got '$price_type'" >&2; exit 1 ;;
esac

if [[ -z "$service_name" ]]; then
    echo "Error: --service-name is required." >&2
    exit 1
fi

# Split comma-separated regions into an array
IFS=',' read -ra regions <<< "$region"

# ============================================================
# Main logic
# ============================================================
all_results="[]"

for region_name in "${regions[@]}"; do
    # Build OData filter arguments
    filter_args=("serviceName=$service_name" "armRegionName=$region_name")
    [[ -n "$price_type" ]]   && filter_args+=("priceType=$price_type")
    [[ -n "$arm_sku_name" ]] && filter_args+=("armSkuName=$arm_sku_name")
    [[ -n "$sku_name" ]]     && filter_args+=("skuName=$sku_name")
    [[ -n "$product_name" ]] && filter_args+=("productName=$product_name")
    [[ -n "$meter_name" ]]   && filter_args+=("meterName=$meter_name")

    filter_string=$(build_odata_filter "${filter_args[@]}")
    [[ "$verbose" == true ]] && echo "Filter: $filter_string" >&2

    # Query API
    items=$(invoke_retail_prices_query "$filter_string" "$currency" 100) || {
        echo "Warning: API request failed for region '$region_name'. Filter: $filter_string" >&2
        continue
    }

    item_count=$(jq 'length' <<< "$items")
    if (( item_count == 0 )); then
        echo "Warning: No pricing data found for region '$region_name' with the specified filters." >&2
        echo "Warning: Filter used: $filter_string" >&2
        echo "Warning: Tip: Filter values are CASE-SENSITIVE. Verify exact serviceName, skuName, productName values." >&2
        continue
    fi

    # Deduplicate: group by meterName|skuName|productName|tierMinimumUnits|reservationTerm
    # Prefer isPrimaryMeterRegion=true; fall back to first item if no primary exists
    deduped=$(jq -c '
        group_by(
            "\(.meterName)|\(.skuName)|\(.productName)|\(.tierMinimumUnits)|\(.reservationTerm)"
        )
        | map(
            (map(select(.isPrimaryMeterRegion == true)) | first) //
            (first)
        )
    ' <<< "$items")

    # Calculate monthly costs and build result objects in a single jq call.
    # Reservation pricing: retailPrice is total prepaid — divide by term months.
    # Consumption pricing: hourly units use hours_per_month; daily units use 30; else 1.
    processed=$(jq -c --argjson qty "$quantity" \
        --argjson hpm "$hours_per_month" \
        --argjson ic "$instance_count" '
        [.[] |
            (.unitOfMeasure) as $uom |
            (if ($uom | startswith("1 Hour")) or $uom == "1/Hour" or $uom == "1 GiB Hour"
             then $hpm
             elif $uom == "1/Day" then 30
             else 1 end) as $multiplier |
            (.retailPrice) as $up |
            # Map reservationTerm to months: 1 Year=12, 3 Years=36, 5 Years=60
            (if .reservationTerm == "1 Year" then 12
             elif .reservationTerm == "3 Years" then 36
             elif .reservationTerm == "5 Years" then 60
             else null end) as $term_months |
            (if $term_months then
                # RI: retailPrice is total prepaid cost — divide by term months
                if $qty > 0 then ($up / $term_months) * $qty * $ic
                else ($up / $term_months) * $ic end
             elif (.reservationTerm // "" | length) > 0 then
                # Unknown reservation term — warn and fall back to consumption math
                (("WARNING: Unknown reservationTerm \u0027" + .reservationTerm + "\u0027 for \u0027" + .productName + "\u0027. MonthlyCost may be incorrect." | stderr) as $_ |
                if $qty > 0 then $up * $qty * $multiplier * $ic
                else $up * $multiplier * $ic end)
             else
                # Consumption: retailPrice is per-unit rate — multiply by monthly multiplier
                if $qty > 0 then $up * $qty * $multiplier * $ic
                else $up * $multiplier * $ic end
             end) as $raw_cost |
            (($raw_cost * 100 | round) / 100) as $mc |
            {
                Region: .armRegionName,
                ServiceName: .serviceName,
                ProductName: .productName,
                SkuName: .skuName,
                ArmSkuName: .armSkuName,
                MeterName: .meterName,
                UnitPrice: $up,
                UnitOfMeasure: $uom,
                Currency: .currencyCode,
                PriceType: .type,
                MonthlyCost: $mc,
                ReservationTerm: .reservationTerm,
                InstanceCount: $ic,
                Quantity: (if $qty > 0 then $qty else 1 end),
                QuantitySpecified: ($qty > 0),
                TierMinUnits: (.tierMinimumUnits // 0)
            }
        ]
    ' <<< "$deduped")

    all_results=$(jq -c -n --argjson a "$all_results" --argjson b "$processed" '$a + $b')
done

# ============================================================
# Output
# ============================================================
total_count=$(jq 'length' <<< "$all_results")

if (( total_count == 0 )); then
    echo "Warning: No results to display." >&2
    exit 2
fi

case "$output_format" in
    Table)
        jq -r '
            sort_by(.Region, .MonthlyCost)
            | ["Region","ProductName","SkuName","MeterName","UnitPrice","UnitOfMeasure","Monthly","Currency"],
              (.[] | [.Region, .ProductName, .SkuName, .MeterName,
                      (.UnitPrice | tostring), .UnitOfMeasure,
                      (.MonthlyCost | tostring), .Currency])
            | @tsv
        ' <<< "$all_results"
        ;;
    Json)
        # Build the regions JSON array
        regions_json=$(printf '%s\n' "${regions[@]}" | jq -R . | jq -s .)

        # Convert empty strings to null for filter values (match PowerShell output)
        jq -n \
            --arg sn "$service_name" \
            --argjson regions "$regions_json" \
            --arg cur "$currency" \
            --arg pt "$price_type" \
            --arg ask "$arm_sku_name" \
            --arg skn "$sku_name" \
            --arg pn "$product_name" \
            --arg mn "$meter_name" \
            --argjson results "$all_results" \
            --argjson total "$total_count" '{
                query: {
                    serviceName: $sn,
                    regions: $regions,
                    currency: $cur,
                    priceType: $pt,
                    filters: {
                        armSkuName: (if $ask == "" then null else $ask end),
                        skuName: (if $skn == "" then null else $skn end),
                        productName: (if $pn == "" then null else $pn end),
                        meterName: (if $mn == "" then null else $mn end)
                    }
                },
                results: $results,
                totalItems: $total,
                summary: {
                    minMonthlyCost: ($results | map(.MonthlyCost) | min),
                    maxMonthlyCost: ($results | map(.MonthlyCost) | max),
                    totalMonthlyCost: ($results | map(.MonthlyCost) | add)
                }
            }'
        ;;
    Summary)
        echo ""
        echo "=== Azure Pricing Estimate ==="
        echo "Service:  $service_name"
        echo "Region:   $(printf '%s, ' "${regions[@]}" | sed 's/, $//')"
        echo "Currency: $currency"
        echo "Type:     $price_type"
        if (( instance_count > 1 )); then
            echo "Instances: $instance_count"
        fi
        echo ""

        jq -r '
            sort_by(.Region, .MonthlyCost)[]
            | "  \(.Region) | \(if .MeterName != "" and .MeterName != null then .MeterName else .ProductName end) | \(.UnitPrice) \(.Currency)/\(.UnitOfMeasure) | Monthly: \(.Currency) \(.MonthlyCost | tostring)"
              + (if (.TierMinUnits // 0) > 0 then " (tier: above \(.TierMinUnits) units)" else "" end)
        ' <<< "$all_results"

        total_monthly=$(jq '[.[].MonthlyCost] | add' <<< "$all_results")
        echo ""
        echo "  ---"
        printf "  TOTAL ESTIMATED MONTHLY: %s %.2f\n" "$currency" "$total_monthly"
        echo ""
        ;;
    *)
        echo "Error: Invalid --output-format '$output_format'. Use Table, Json, or Summary." >&2
        exit 1
        ;;
esac
