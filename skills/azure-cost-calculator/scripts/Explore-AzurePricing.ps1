<#
.SYNOPSIS
    Discovers available Azure pricing filter values for unknown or new resource types.

.DESCRIPTION
    Queries the Azure Retail Prices API and returns distinct combinations of
    serviceName, productName, skuName, meterName, armSkuName, unitOfMeasure,
    and a sample retailPrice -- useful for finding the exact filter values needed
    by Get-AzurePricing.ps1.

.EXAMPLE
    # Find all pricing entries for "Container Apps" in australiaeast
    .\Explore-AzurePricing.ps1 -ServiceName 'Azure Container Apps'

.EXAMPLE
    # Fuzzy search for anything mentioning "redis"
    .\Explore-AzurePricing.ps1 -SearchTerm 'redis' -Top 50

.EXAMPLE
    # Discover pricing in EUR
    .\Explore-AzurePricing.ps1 -ServiceName 'Azure Container Apps' -Currency 'EUR'
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ServiceName,

    [Parameter()]
    [string]$SearchTerm,

    [Parameter()]
    [string]$Region = 'eastus',

    [Parameter()]
    [Alias('CurrencyCode')]
    [string]$Currency = 'USD',

    [Parameter()]
    [int]$Top = 20,

    [Parameter()]
    [ValidateSet('Json', 'Table')]
    [string]$OutputFormat = 'Json'
)

$ErrorActionPreference = 'Stop'

# Load shared library functions
. "$PSScriptRoot/lib/Build-ODataFilter.ps1"
. "$PSScriptRoot/lib/Invoke-RetailPricesQuery.ps1"

# Build filter
if (-not $ServiceName -and -not $SearchTerm) {
    Write-Warning 'Provide either -ServiceName (exact match) or -SearchTerm (fuzzy contains search).'
    return
}

$filters = [ordered]@{
    'armRegionName' = $Region
}

if ($ServiceName) {
    $filters['serviceName'] = $ServiceName
}

if ($SearchTerm) {
    $filters['contains'] = @(
        @{ Field = 'productName'; Value = $SearchTerm }
    )
}

$filterString = Build-ODataFilter -Filters $filters
Write-Verbose "Filter: $filterString"

# Query API
try {
    $items = Invoke-RetailPricesQuery -Filter $filterString -CurrencyCode $Currency -MaxItems ($Top * 5)
}
catch [System.Net.WebException] {
    Write-Warning "API request failed. Filter: $filterString"
    Write-Warning "Error: $($_.Exception.Message)"
    return
}
catch {
    $ex = $_.Exception
    $isHttpError = ($null -ne $ex.PSObject.Properties['Response']) -or
                   ($null -ne $ex.PSObject.Properties['StatusCode'])

    if ($isHttpError) {
        Write-Warning "API returned error. Filter: $filterString"
        Write-Warning "Error: $($ex.Message)"
        return
    }

    throw
}

if (-not $items -or $items.Count -eq 0) {
    Write-Warning "No results found. Filter: $filterString"
    return
}

# Deduplicate to distinct combinations
$grouped = $items | Group-Object -Property {
    "$($_.serviceName)|$($_.productName)|$($_.skuName)|$($_.meterName)|$($_.armSkuName)|$($_.unitOfMeasure)"
}

$distinct = [System.Collections.Generic.List[PSCustomObject]]::new()
foreach ($group in $grouped) {
    $sample = $group.Group | Select-Object -First 1
    $distinct.Add([PSCustomObject]@{
            ServiceName   = $sample.serviceName
            ProductName   = $sample.productName
            SkuName       = $sample.skuName
            MeterName     = $sample.meterName
            ArmSkuName    = $sample.armSkuName
            UnitOfMeasure = $sample.unitOfMeasure
            SamplePrice   = $sample.retailPrice
        })

    if ($distinct.Count -ge $Top) { break }
}

# Output
switch ($OutputFormat) {
    'Table' {
        $distinct | Sort-Object ServiceName, ProductName, SkuName |
        Format-Table ServiceName, ProductName, SkuName, MeterName, ArmSkuName, UnitOfMeasure,
        @{Label = 'SamplePrice'; Expression = { '{0:N4}' -f $_.SamplePrice }; Align = 'Right' } -AutoSize
    }
    'Json' {
        $distinct | ConvertTo-Json -Depth 3
    }
}
