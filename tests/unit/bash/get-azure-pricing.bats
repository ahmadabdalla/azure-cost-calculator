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

@test "no results exits with code 2" {
    create_curl_mock '{"Items":[],"NextPageLink":null}' 200
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Nonexistent"
    [ "$status" -eq 2 ]
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

@test "malformed JSON response exits non-zero" {
    create_curl_mock 'not-valid-json' 200
    run bash "$SCRIPTS_DIR/get-azure-pricing.sh" --service-name "Virtual Machines"
    [ "$status" -ne 0 ]
}
