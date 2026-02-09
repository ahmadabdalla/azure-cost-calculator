#!/usr/bin/env bash
set -euo pipefail

# Queries the Azure Retail Prices API and calculates estimated monthly costs.
# Produces identical JSON output to Get-AzurePricing.ps1 for the same inputs.
#
# Examples:
#   ./get-azure-pricing.sh --service-name 'Virtual Machines' --arm-sku-name 'Standard_D2s_v5'
#   ./get-azure-pricing.sh --service-name 'Virtual Machines' --arm-sku-name 'Standard_D2s_v5' \
#       --region 'eastus,westeurope' --output-format Table

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
# Note: monthly multiplier logic is embedded in the jq processing below

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

# ============================================================
# Argument parsing
# ============================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --service-name)   service_name="$2"; shift 2 ;;
        --region)         region="$2"; shift 2 ;;
        --arm-sku-name)   arm_sku_name="$2"; shift 2 ;;
        --sku-name)       sku_name="$2"; shift 2 ;;
        --product-name)   product_name="$2"; shift 2 ;;
        --meter-name)     meter_name="$2"; shift 2 ;;
        --price-type)     price_type="$2"; shift 2 ;;
        --currency)       currency="$2"; shift 2 ;;
        --quantity)       quantity="$2"; shift 2 ;;
        --hours-per-month) hours_per_month="$2"; shift 2 ;;
        --instance-count) instance_count="$2"; shift 2 ;;
        --output-format)  output_format="$2"; shift 2 ;;
        *)
            echo "Error: Unknown argument '$1'" >&2
            exit 1
            ;;
    esac
done

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

    # Query API
    items=$(invoke_retail_prices_query "$filter_string" "$currency" 100) || {
        echo "Warning: API request failed for region '$region_name'. Filter: $filter_string" >&2
        continue
    }

    item_count=$(echo "$items" | jq 'length')
    if (( item_count == 0 )); then
        echo "Warning: No pricing data found for region '$region_name' with the specified filters." >&2
        echo "Warning: Filter used: $filter_string" >&2
        echo "Warning: Tip: Filter values are CASE-SENSITIVE. Verify exact serviceName, skuName, productName values." >&2
        continue
    fi

    # Deduplicate: group by meterName|skuName|productName|tierMinimumUnits|reservationTerm
    # Prefer isPrimaryMeterRegion=true; fall back to first item if no primary exists
    deduped=$(echo "$items" | jq -c '
        group_by(
            "\(.meterName)|\(.skuName)|\(.productName)|\(.tierMinimumUnits)|\(.reservationTerm)"
        )
        | map(
            (map(select(.isPrimaryMeterRegion == true)) | first) //
            (first)
        )
    ')

    # Calculate monthly costs and build result objects in a single jq call.
    # Monthly multiplier: hourly units (1 Hour*, 1/Hour, 1 GiB Hour) use hours_per_month; else 1.
    processed=$(echo "$deduped" | jq -c --argjson qty "$quantity" \
        --argjson hpm "$hours_per_month" \
        --argjson ic "$instance_count" '
        [.[] |
            (.unitOfMeasure) as $uom |
            (if ($uom | startswith("1 Hour")) or $uom == "1/Hour" or $uom == "1 GiB Hour"
             then $hpm else 1 end) as $multiplier |
            (.retailPrice) as $up |
            (if $qty > 0 then $up * $qty * $multiplier * $ic
             else $up * $multiplier * $ic end) as $raw_cost |
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
    ')

    all_results=$(jq -c -n --argjson a "$all_results" --argjson b "$processed" '$a + $b')
done

# ============================================================
# Output
# ============================================================
total_count=$(echo "$all_results" | jq 'length')

if (( total_count == 0 )); then
    echo "Warning: No results to display." >&2
    exit 0
fi

case "$output_format" in
    Table)
        echo "$all_results" | jq -r '
            sort_by(.Region, .MonthlyCost)
            | ["Region","ProductName","SkuName","MeterName","UnitPrice","UnitOfMeasure","Monthly","Currency"],
              (.[] | [.Region, .ProductName, .SkuName, .MeterName,
                      (.UnitPrice | tostring), .UnitOfMeasure,
                      (.MonthlyCost | tostring), .Currency])
            | @tsv
        ' | column -t -s $'\t'
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
        echo "Region:   $(IFS=', '; echo "${regions[*]}")"
        echo "Currency: $currency"
        echo "Type:     $price_type"
        if (( instance_count > 1 )); then
            echo "Instances: $instance_count"
        fi
        echo ""

        echo "$all_results" | jq -r '
            sort_by(.Region, .MonthlyCost)[]
            | "  \(.Region) | \(if .MeterName != "" and .MeterName != null then .MeterName else .ProductName end) | \(.UnitPrice) \(.Currency)/\(.UnitOfMeasure) | Monthly: \(.Currency) \(.MonthlyCost | tostring)"
              + (if (.TierMinUnits // 0) > 0 then " (tier: above \(.TierMinUnits) units)" else "" end)
        '

        total_monthly=$(echo "$all_results" | jq '[.[].MonthlyCost] | add')
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
