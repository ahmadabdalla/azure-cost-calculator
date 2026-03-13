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
    # Create a curl mock that records its arguments and returns valid response
    cat > "$MOCK_DIR/curl" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$MOCK_DIR/curl_args"
printf '%s\n%s' '{"Items":[],"NextPageLink":null}' '200'
SCRIPT
    chmod +x "$MOCK_DIR/curl"

    run invoke_retail_prices_query "serviceName eq 'Test'"
    [ "$status" -eq 0 ]
    [ "$output" = "[]" ]
    # Verify default currency code was used in the request
    [[ "$(cat "$MOCK_DIR/curl_args")" == *"currencyCode=USD"* ]]
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

@test "large single page does not cause argument list errors" {
    # Regression test: $page_items was passed as --argjson b, which crashes on Linux
    # when a single API page exceeds MAX_ARG_STRLEN (~128 KiB). The fix pipes both
    # all_items and page_items via stdin using printf | jq -s '.[0] + .[1]'.
    #
    # 200 items × 750-byte padding ≈ 165 KiB for page_items — exceeds the limit,
    # so --argjson b would crash on the very first page without the fix.
    local page_items_json
    page_items_json=$(jq -cn '[range(200) | {
        "name": ("item" + tostring),
        "sku": "Standard_E2as_v5",
        "retailPrice": 0.096,
        "padding": ("a" * 750)
    }]')

    local page_file="$BATS_TEST_TMPDIR/large_single_page"
    printf '{"Items":%s,"NextPageLink":null}\n%s' "$page_items_json" '200' > "$page_file"

    cat > "$MOCK_DIR/curl" <<SCRIPT
#!/usr/bin/env bash
cat "$page_file"
SCRIPT
    chmod +x "$MOCK_DIR/curl"

    run invoke_retail_prices_query "serviceName eq 'Test'" "USD" 300
    [ "$status" -eq 0 ]
    local count
    count=$(jq 'length' <<< "$output")
    [ "$count" -eq 200 ]
}

@test "large accumulated results across pages do not cause argument list errors" {
    # Regression test: previously all_items was passed via --argjson (command-line
    # argument), which crashed with "Argument list too long" for large result sets.
    # The fix pipes all_items via stdin instead.
    #
    # Each page has 100 items with a 750-byte padding field (~82 KiB per page),
    # staying under the Linux MAX_ARG_STRLEN limit (~128 KiB) so --argjson b
    # works for each individual page. After two pages, all_items reaches ~164 KiB.
    # The third curl call returns an empty page, triggering the accumulation where
    # the old --argjson a "$all_items" would receive the 164 KiB value and crash.
    local page_items_json
    page_items_json=$(jq -cn '[range(100) | {
        "name": ("item" + tostring),
        "sku": "Standard_E2as_v5",
        "retailPrice": 0.096,
        "padding": ("a" * 750)
    }]')

    # Use BATS_TEST_TMPDIR (auto-cleaned by bats) so files are always removed
    # even if an assertion fails.
    local page1_file="$BATS_TEST_TMPDIR/page1"
    local page2_file="$BATS_TEST_TMPDIR/page2"
    printf '{"Items":%s,"NextPageLink":"https://prices.azure.com/Page2"}\n%s' "$page_items_json" '200' > "$page1_file"
    printf '{"Items":%s,"NextPageLink":"https://prices.azure.com/Page3"}\n%s' "$page_items_json" '200' > "$page2_file"

    cat > "$MOCK_DIR/curl" <<SCRIPT
#!/usr/bin/env bash
if [[ "\$*" == *"Page3"* ]]; then
    printf '%s\n%s' '{"Items":[],"NextPageLink":null}' '200'
elif [[ "\$*" == *"Page2"* ]]; then
    cat "$page2_file"
else
    cat "$page1_file"
fi
SCRIPT
    chmod +x "$MOCK_DIR/curl"

    run invoke_retail_prices_query "serviceName eq 'Test'" "USD" 300
    [ "$status" -eq 0 ]
    local count
    count=$(jq 'length' <<< "$output")
    [ "$count" -eq 200 ]
}
