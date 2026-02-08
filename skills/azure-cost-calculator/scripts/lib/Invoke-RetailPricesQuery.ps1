<#
.SYNOPSIS
    Queries the Azure Retail Prices API with OData filter, handling pagination.
    Returns an array of pricing items.
#>
function Invoke-RetailPricesQuery {
    param(
        [Parameter(Mandatory)]
        [string]$Filter,

        [Parameter()]
        [string]$CurrencyCode = 'USD',

        [Parameter()]
        [int]$MaxItems = 100
    )

    $baseUri = 'https://prices.azure.com/api/retail/prices'
    $allItems = [System.Collections.Generic.List[PSCustomObject]]::new()
    $encodedFilter = [System.Uri]::EscapeDataString($Filter)
    $uri = "${baseUri}?`$filter=${encodedFilter}&currencyCode=${CurrencyCode}"

    do {
        $response = Invoke-RestMethod -Uri $uri -ErrorAction Stop
        if ($response.Items) {
            $allItems.AddRange([PSCustomObject[]]$response.Items)
        }
        $uri = $response.NextPageLink

        if ($allItems.Count -ge $MaxItems) {
            break
        }
    } while ($uri)

    return $allItems
}
