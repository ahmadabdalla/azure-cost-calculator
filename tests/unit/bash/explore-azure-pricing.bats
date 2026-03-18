#!/usr/bin/env bats

setup() {
    source "$BATS_TEST_DIRNAME/test_helper.bash"
    setup_mock_path
    create_curl_mock '{"Items":[{"serviceName":"Azure Container Apps","productName":"Azure Container Apps","skuName":"Standard","meterName":"vCPU Duration","armSkuName":"","armRegionName":"eastus","retailPrice":0.000024,"unitOfMeasure":"1 Second","currencyCode":"USD"}],"NextPageLink":null}' 200
}

teardown() { teardown_mock_path; }

@test "help flag exits 0" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"explore-azure-pricing.sh"* ]]
}

@test "no service-name or search-term exits non-zero with error" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"service-name"* ]] || [[ "$output" == *"search-term"* ]]
}

@test "service-name query returns JSON array with expected fields" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Azure Container Apps"
    [ "$status" -eq 0 ]
    sn=$(echo "$output" | jq -r '.[0].ServiceName')
    [ "$sn" = "Azure Container Apps" ]
    pn=$(echo "$output" | jq -r '.[0].ProductName')
    [ "$pn" = "Azure Container Apps" ]
    meter=$(echo "$output" | jq -r '.[0].MeterName')
    [ "$meter" = "vCPU Duration" ]
}

@test "search-term query succeeds" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --search-term "container"
    [ "$status" -eq 0 ]
    count=$(echo "$output" | jq 'length')
    [ "$count" -ge 1 ]
}

@test "top limit restricts output count" {
    create_curl_mock '{"Items":[{"serviceName":"S","productName":"P1","skuName":"A","meterName":"M1","armSkuName":"","armRegionName":"eastus","retailPrice":1,"unitOfMeasure":"1 Hour","currencyCode":"USD"},{"serviceName":"S","productName":"P2","skuName":"B","meterName":"M2","armSkuName":"","armRegionName":"eastus","retailPrice":2,"unitOfMeasure":"1 Hour","currencyCode":"USD"},{"serviceName":"S","productName":"P3","skuName":"C","meterName":"M3","armSkuName":"","armRegionName":"eastus","retailPrice":3,"unitOfMeasure":"1 Hour","currencyCode":"USD"}],"NextPageLink":null}' 200
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "S" --top 2
    [ "$status" -eq 0 ]
    count=$(echo "$output" | jq 'length')
    [ "$count" -eq 2 ]
}

@test "no results exits 0 with empty JSON array" {
    create_curl_mock '{"Items":[],"NextPageLink":null}' 200
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Nonexistent"
    [ "$status" -eq 0 ]
    json_output=$(echo "$output" | grep -v '^Warning:')
    count=$(echo "$json_output" | jq 'length')
    [ "$count" = "0" ]
}

@test "table output has TSV headers" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Azure Container Apps" --output-format Table
    [ "$status" -eq 0 ]
    [[ "$output" == *"ServiceName"* ]]
    [[ "$output" == *"ProductName"* ]]
    [[ "$output" == *"SamplePrice"* ]]
}

@test "API failure exits non-zero with error message" {
    create_mock "curl" "" 1
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Test"
    [ "$status" -ne 0 ]
    echo "$output" | grep -qi "error"
}

@test "--currency-code alias is accepted" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Azure Container Apps" --currency-code "EUR"
    [ "$status" -eq 0 ]
}

@test "unknown flag lists valid flags in error" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Test" --bogus-flag "x"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Valid flags"* ]]
    [[ "$output" == *"--currency"* ]]
}

# ============================================================
# --include-meter-id flag tests
# ============================================================

@test "default Json output excludes MeterId" {
    create_curl_mock '{"Items":[{"serviceName":"Azure Container Apps","productName":"Azure Container Apps","skuName":"Standard","meterName":"vCPU Duration","meterId":"00000000-0000-0000-0000-000000000002","armSkuName":"","armRegionName":"eastus","retailPrice":0.000024,"unitOfMeasure":"1 Second","currencyCode":"USD"}],"NextPageLink":null}' 200
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Azure Container Apps"
    [ "$status" -eq 0 ]
    has_meter_id=$(echo "$output" | jq '.[0] | has("MeterId")')
    [ "$has_meter_id" = "false" ]
}

@test "--include-meter-id includes MeterId in Json output" {
    create_curl_mock '{"Items":[{"serviceName":"Azure Container Apps","productName":"Azure Container Apps","skuName":"Standard","meterName":"vCPU Duration","meterId":"00000000-0000-0000-0000-000000000002","armSkuName":"","armRegionName":"eastus","retailPrice":0.000024,"unitOfMeasure":"1 Second","currencyCode":"USD"}],"NextPageLink":null}' 200
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Azure Container Apps" --include-meter-id
    [ "$status" -eq 0 ]
    meter_id=$(echo "$output" | jq -r '.[0].MeterId')
    [ "$meter_id" = "00000000-0000-0000-0000-000000000002" ]
}

@test "null meterId from API produces null MeterId when included" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Azure Container Apps" --include-meter-id
    [ "$status" -eq 0 ]
    has_meter_id=$(echo "$output" | jq '.[0] | has("MeterId")')
    [ "$has_meter_id" = "true" ]
    meter_id=$(echo "$output" | jq '.[0].MeterId')
    [ "$meter_id" = "null" ]
}

@test "invalid --output-format exits non-zero" {
    run bash "$SCRIPTS_DIR/explore-azure-pricing.sh" --service-name "Test" --output-format "CSV"
    [ "$status" -ne 0 ]
    [[ "$output" == *"must be"* ]]
}
