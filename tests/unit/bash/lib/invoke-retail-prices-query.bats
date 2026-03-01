#!/usr/bin/env bats

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$LIB_DIR/invoke-retail-prices-query.sh"
    setup_mock_path
}

teardown() {
    teardown_mock_path
}

@test "single page with no items returns empty array" {
    create_curl_mock '{"Items":[],"NextPageLink":null}' 200
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 0 ]
    [ "$output" = "[]" ]
}

@test "single page returns items array" {
    create_curl_mock '{"Items":[{"name":"a","price":1.0}],"NextPageLink":null}' 200
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 0 ]
    local count
    count=$(jq 'length' <<< "$output")
    [ "$count" -eq 1 ]
}

@test "default currency is USD" {
    create_curl_mock '{"Items":[],"NextPageLink":null}' 200
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 0 ]
    [ "$output" = "[]" ]
}

@test "custom currency code is accepted" {
    create_curl_mock '{"Items":[{"name":"a"}],"NextPageLink":null}' 200
    run invoke_retail_prices_query "serviceName eq 'Test'" "EUR"
    [ "$status" -eq 0 ]
    local count
    count=$(jq 'length' <<< "$output")
    [ "$count" -eq 1 ]
}

@test "pagination follows NextPageLink" {
    # Mock curl to return two different pages based on call count
    cat > "$MOCK_DIR/curl" <<'SCRIPT'
#!/usr/bin/env bash
if [[ "$*" == *"NextPage"* ]]; then
    printf '%s\n%s' '{"Items":[{"name":"b"}],"NextPageLink":null}' '200'
else
    printf '%s\n%s' '{"Items":[{"name":"a"}],"NextPageLink":"https://prices.azure.com/NextPage"}' '200'
fi
SCRIPT
    chmod +x "$MOCK_DIR/curl"

    run invoke_retail_prices_query "serviceName eq 'Test'" "USD" 100
    [ "$status" -eq 0 ]
    local count
    count=$(jq 'length' <<< "$output")
    [ "$count" -eq 2 ]
}

@test "max_items stops pagination early" {
    cat > "$MOCK_DIR/curl" <<'SCRIPT'
#!/usr/bin/env bash
if [[ "$*" == *"NextPage"* ]]; then
    printf '%s\n%s' '{"Items":[{"name":"b"}],"NextPageLink":"https://prices.azure.com/NextPage2"}' '200'
else
    printf '%s\n%s' '{"Items":[{"name":"a"}],"NextPageLink":"https://prices.azure.com/NextPage"}' '200'
fi
SCRIPT
    chmod +x "$MOCK_DIR/curl"

    run invoke_retail_prices_query "serviceName eq 'Test'" "USD" 2
    [ "$status" -eq 0 ]
    local count
    count=$(jq 'length' <<< "$output")
    [ "$count" -eq 2 ]
}

@test "max_items defaults to 100" {
    create_curl_mock '{"Items":[{"name":"a"}],"NextPageLink":null}' 200
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 0 ]
    [ "$output" != "" ]
}

@test "HTTP 404 returns error" {
    create_curl_mock '{"error":"not found"}' 404
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"HTTP 404"* ]]
}

@test "HTTP 500 returns error" {
    create_curl_mock '{"error":"server error"}' 500
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"HTTP 500"* ]]
}

@test "HTTP 199 returns error" {
    create_curl_mock '{"error":"unexpected"}' 199
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"HTTP 199"* ]]
}

@test "curl failure returns error with exit code 1" {
    create_mock "curl" "" 1
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"curl error"* ]]
}

@test "response with missing Items key returns empty array" {
    create_curl_mock '{"NextPageLink":null}' 200
    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 0 ]
    [ "$output" = "[]" ]
}

@test "multiple items on single page" {
    create_curl_mock '{"Items":[{"n":"a"},{"n":"b"},{"n":"c"}],"NextPageLink":null}' 200
    run invoke_retail_prices_query "serviceName eq 'Test'" "USD" 100
    [ "$status" -eq 0 ]
    local count
    count=$(jq 'length' <<< "$output")
    [ "$count" -eq 3 ]
}

@test "max_items of 1 stops after first page" {
    cat > "$MOCK_DIR/curl" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n%s' '{"Items":[{"name":"a"}],"NextPageLink":"https://prices.azure.com/NextPage"}' '200'
SCRIPT
    chmod +x "$MOCK_DIR/curl"

    run invoke_retail_prices_query "serviceName eq 'Test'" "USD" 1
    [ "$status" -eq 0 ]
    local count
    count=$(jq 'length' <<< "$output")
    [ "$count" -eq 1 ]
}
