#!/usr/bin/env bats

setup() {
    source "$BATS_TEST_DIRNAME/../test_helper.bash"
    source "$LIB_DIR/build-odata-filter.sh"
}

@test "no arguments returns empty string" {
    run build_odata_filter
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "single equality filter" {
    run build_odata_filter "serviceName=Virtual Machines"
    [ "$status" -eq 0 ]
    [ "$output" = "serviceName eq 'Virtual Machines'" ]
}

@test "multiple equality filters joined with and" {
    run build_odata_filter "serviceName=Virtual Machines" "armRegionName=eastus"
    [ "$status" -eq 0 ]
    [ "$output" = "serviceName eq 'Virtual Machines' and armRegionName eq 'eastus'" ]
}

@test "single contains filter" {
    run build_odata_filter "contains:productName=Redis"
    [ "$status" -eq 0 ]
    [ "$output" = "contains(productName, 'Redis')" ]
}

@test "multiple contains filters joined with and" {
    run build_odata_filter "contains:productName=Redis" "contains:skuName=Standard"
    [ "$status" -eq 0 ]
    [ "$output" = "contains(productName, 'Redis') and contains(skuName, 'Standard')" ]
}

@test "mixed equality and contains filters" {
    run build_odata_filter "serviceName=Cache" "contains:productName=Redis" "armRegionName=eastus"
    [ "$status" -eq 0 ]
    [ "$output" = "serviceName eq 'Cache' and contains(productName, 'Redis') and armRegionName eq 'eastus'" ]
}

@test "empty value in equality filter is skipped" {
    run build_odata_filter "serviceName="
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "empty value equality filter mixed with valid filter" {
    run build_odata_filter "serviceName=" "armRegionName=eastus"
    [ "$status" -eq 0 ]
    [ "$output" = "armRegionName eq 'eastus'" ]
}

@test "single quote in equality value is escaped" {
    run build_odata_filter "serviceName=App Service's Plan"
    [ "$status" -eq 0 ]
    [ "$output" = "serviceName eq 'App Service''s Plan'" ]
}

@test "single quote in contains value is escaped" {
    run build_odata_filter "contains:productName=Azure's Redis"
    [ "$status" -eq 0 ]
    [ "$output" = "contains(productName, 'Azure''s Redis')" ]
}

@test "multiple single quotes are all escaped" {
    run build_odata_filter "serviceName=it's a 'test'"
    [ "$status" -eq 0 ]
    [ "$output" = "serviceName eq 'it''s a ''test'''" ]
}

@test "value containing equals sign preserves everything after first equals" {
    run build_odata_filter "field=val=ue"
    [ "$status" -eq 0 ]
    [ "$output" = "field eq 'val=ue'" ]
}

@test "contains value with equals sign preserves everything after first equals" {
    run build_odata_filter "contains:field=val=ue"
    [ "$status" -eq 0 ]
    [ "$output" = "contains(field, 'val=ue')" ]
}

@test "three equality filters joined correctly" {
    run build_odata_filter "a=1" "b=2" "c=3"
    [ "$status" -eq 0 ]
    [ "$output" = "a eq '1' and b eq '2' and c eq '3'" ]
}

@test "contains filter with empty value still produces output" {
    run build_odata_filter "contains:field="
    [ "$status" -eq 0 ]
    [ "$output" = "contains(field, '')" ]
}
