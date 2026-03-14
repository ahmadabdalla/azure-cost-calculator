#!/usr/bin/env bats

setup() {
    source "$BATS_TEST_DIRNAME/test_helper.bash"
    setup_mock_path
    create_curl_mock '{"Items":[{"serviceName":"Virtual Machines","productName":"Virtual Machines Dv5 Series","skuName":"D2s v5","armSkuName":"Standard_D2s_v5","meterName":"D2s v5","armRegionName":"eastus","retailPrice":0.096,"unitOfMeasure":"1 Hour","currencyCode":"USD","type":"Consumption","isPrimaryMeterRegion":true,"tierMinimumUnits":0,"reservationTerm":null}],"NextPageLink":null}' 200
}

teardown() { teardown_mock_path; }

@test "help flag exits 0 and shows script name" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"get-azure-pricing.sh"* ]]
}

@test "missing --service-name exits non-zero with required message" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"required"* ]]
}

@test "invalid --output-format exits non-zero with must be message" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --output-format "CSV"
    [ "$status" -ne 0 ]
    [[ "$output" == *"must be"* ]]
}

@test "invalid --price-type exits non-zero" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --price-type "Invalid"
    [ "$status" -ne 0 ]
}

@test "single region Json output has query, results, and summary" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines"
    [ "$status" -eq 0 ]
    result_sn=$(echo "$output" | jq -r '.query.serviceName')
    [ "$result_sn" = "Virtual Machines" ]
    result_count=$(echo "$output" | jq '.results | length')
    [ "$result_count" -ge 1 ]
    summary_min=$(echo "$output" | jq '.summary.minMonthlyCost')
    [ "$summary_min" != "null" ]
}

@test "monthly cost calculation: 0.096 x 730 = 70.08" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines"
    [ "$status" -eq 0 ]
    monthly=$(echo "$output" | jq '.results[0].MonthlyCost')
    [ "$monthly" = "70.08" ]
}

@test "reservation pricing: 600 / 12 = 50 monthly" {
    create_curl_mock '{"Items":[{"serviceName":"Virtual Machines","productName":"Virtual Machines Dv5 Series","skuName":"D2s v5","armSkuName":"Standard_D2s_v5","meterName":"D2s v5","armRegionName":"eastus","retailPrice":600,"unitOfMeasure":"1 Hour","currencyCode":"USD","type":"Reservation","isPrimaryMeterRegion":true,"tierMinimumUnits":0,"reservationTerm":"1 Year"}],"NextPageLink":null}' 200
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --price-type "Reservation"
    [ "$status" -eq 0 ]
    monthly=$(echo "$output" | jq '.results[0].MonthlyCost')
    [ "$monthly" = "50" ]
}

@test "quantity parameter multiplied into cost" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --quantity 10
    [ "$status" -eq 0 ]
    monthly=$(echo "$output" | jq '.results[0].MonthlyCost')
    [ "$monthly" = "700.8" ]
}

@test "instance count multiplied into cost" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --instance-count 3
    [ "$status" -eq 0 ]
    monthly=$(echo "$output" | jq '.results[0].MonthlyCost')
    [ "$monthly" = "210.24" ]
}

@test "no results exits 0 with empty JSON envelope" {
    create_curl_mock '{"Items":[],"NextPageLink":null}' 200
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Nonexistent"
    [ "$status" -eq 0 ]
    json_output=$(echo "$output" | grep -v '^Warning:')
    total=$(echo "$json_output" | jq '.totalItems')
    [ "$total" = "0" ]
    results=$(echo "$json_output" | jq '.results | length')
    [ "$results" = "0" ]
}

@test "table output has TSV headers" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --output-format Table
    [ "$status" -eq 0 ]
    [[ "$output" == *"Region"* ]]
    [[ "$output" == *"ProductName"* ]]
    [[ "$output" == *"UnitPrice"* ]]
}

@test "summary output shows Azure Pricing Estimate and total" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --output-format Summary
    [ "$status" -eq 0 ]
    [[ "$output" == *"Azure Pricing Estimate"* ]]
    [[ "$output" == *"TOTAL ESTIMATED MONTHLY"* ]]
}

@test "API failure exits non-zero with error message" {
    create_mock "curl" "" 1
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines"
    [ "$status" -ne 0 ]
    echo "$output" | grep -qi "error"
}

@test "--currency-code alias is accepted" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --currency-code "AUD"
    [ "$status" -eq 0 ]
    currency=$(echo "$output" | jq -r '.query.currency')
    [ "$currency" = "AUD" ]
}

@test "unknown flag lists valid flags in error" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --bogus-flag "x"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Valid flags"* ]]
    [[ "$output" == *"--currency"* ]]
}

@test "malformed JSON response exits non-zero" {
    create_curl_mock 'not-valid-json' 200
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines"
    [ "$status" -ne 0 ]
    echo "$output" | grep -Eqi "error|json|parse|invalid"
}

@test "large single-region processed result does not cause argument list errors" {
    # Regression: $processed JSON for a single region was appended via --argjson b,
    # which crashes on Linux when $processed exceeds MAX_ARG_STRLEN (~128 KiB).
    # The fix pipes both values via stdin using printf | jq -s '.[0] + .[1]'.
    #
    # 200 items × 200-char field values ≈ 200+ KiB for processed — exceeds the limit
    # so --argjson b would crash on the first region without the fix.
    local items_json
    items_json=$(jq -cn '[range(200) | {
        serviceName: "Virtual Machines",
        productName: ("Dv5 Series " + ("x" * 200) + " " + tostring),
        skuName: ("D2s v5 " + ("x" * 200) + " " + tostring),
        armSkuName: ("Standard_D2s_v5_" + ("x" * 200) + "_" + tostring),
        meterName: ("D2s v5 " + ("x" * 200) + " " + tostring),
        armRegionName: "eastus",
        retailPrice: 0.096,
        unitOfMeasure: "1 Hour",
        currencyCode: "USD",
        type: "Consumption",
        isPrimaryMeterRegion: true,
        tierMinimumUnits: 0,
        reservationTerm: null
    }]')

    local page_file="$BATS_TEST_TMPDIR/large_single_region_page"
    printf '{"Items":%s,"NextPageLink":null}\n%s' "$items_json" '200' > "$page_file"

    cat > "$MOCK_DIR/curl" <<SCRIPT
#!/usr/bin/env bash
cat "$page_file"
SCRIPT
    chmod +x "$MOCK_DIR/curl"

    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --region "eastus"
    [ "$status" -eq 0 ]
    local count
    count=$(echo "$output" | jq '.results | length')
    [ "$count" -eq 200 ]
}

@test "multi-region accumulation does not cause argument list errors" {
    # Regression: all_results was accumulated across regions via --argjson, which
    # crashes on Linux when the accumulated JSON exceeds the per-argument size limit.
    # The fix pipes all_results via stdin instead. This test exercises both the
    # accumulation loop and the Json output block.
    #
    # Each item uses 150-char string fields so the processed output per region is
    # ~100 KiB (under MAX_ARG_STRLEN, keeping --argjson b valid). After two regions,
    # all_results reaches ~200 KiB. The third region accumulation is where the old
    # --argjson a "$all_results" would receive that 200 KiB value and crash on Linux.
    local items_json
    items_json=$(jq -cn '[range(100) | {
        serviceName: "Virtual Machines",
        productName: ("Dv5 Series " + ("x" * 150) + " " + tostring),
        skuName: ("D2s v5 " + ("x" * 150) + " " + tostring),
        armSkuName: ("Standard_D2s_v5_" + ("x" * 150) + "_" + tostring),
        meterName: ("D2s v5 " + ("x" * 150) + " " + tostring),
        armRegionName: "eastus",
        retailPrice: 0.096,
        unitOfMeasure: "1 Hour",
        currencyCode: "USD",
        type: "Consumption",
        isPrimaryMeterRegion: true,
        tierMinimumUnits: 0,
        reservationTerm: null
    }]')

    # Use BATS_TEST_TMPDIR (auto-cleaned by bats) so the file is always removed
    # even if an assertion fails.
    local page_file="$BATS_TEST_TMPDIR/page_response"
    printf '{"Items":%s,"NextPageLink":null}\n%s' "$items_json" '200' > "$page_file"

    cat > "$MOCK_DIR/curl" <<SCRIPT
#!/usr/bin/env bash
cat "$page_file"
SCRIPT
    chmod +x "$MOCK_DIR/curl"

    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --region "eastus,westeurope,uksouth"
    [ "$status" -eq 0 ]
    local count
    count=$(echo "$output" | jq '.results | length')
    [ "$count" -eq 300 ]
}

@test "compact output has results but no query or summary" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --output-format Compact
    [ "$status" -eq 0 ]
    has_results=$(echo "$output" | jq 'has("results")')
    [ "$has_results" = "true" ]
    has_query=$(echo "$output" | jq 'has("query")')
    [ "$has_query" = "false" ]
    has_summary=$(echo "$output" | jq 'has("summary")')
    [ "$has_summary" = "false" ]
    has_total=$(echo "$output" | jq 'has("totalItems")')
    [ "$has_total" = "false" ]
}

@test "compact output contains only 9 fields per result" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --output-format Compact
    [ "$status" -eq 0 ]
    field_count=$(echo "$output" | jq '.results[0] | keys | length')
    [ "$field_count" -eq 9 ]
    # Verify specific fields exist
    echo "$output" | jq -e '.results[0] | has("MeterName", "ProductName", "SkuName", "UnitPrice", "UnitOfMeasure", "MonthlyCost", "Currency", "ReservationTerm", "TierMinUnits")'
}

@test "compact output calculates correct MonthlyCost" {
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines" --output-format Compact
    [ "$status" -eq 0 ]
    monthly=$(echo "$output" | jq '.results[0].MonthlyCost')
    [ "$monthly" = "70.08" ]
}

@test "compact output with empty results returns empty results array" {
    create_curl_mock '{"Items":[],"NextPageLink":null}' 200
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Nonexistent" --output-format Compact
    [ "$status" -eq 0 ]
    json_output=$(echo "$output" | grep -v '^Warning:')
    results=$(echo "$json_output" | jq '.results | length')
    [ "$results" = "0" ]
    has_query=$(echo "$json_output" | jq 'has("query")')
    [ "$has_query" = "false" ]
    has_summary=$(echo "$json_output" | jq 'has("summary")')
    [ "$has_summary" = "false" ]
}
