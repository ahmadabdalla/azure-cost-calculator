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
        [int]$MaxItems = 100,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$MaxAttempts = 3,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$BaseDelaySeconds = 2
    )

    $baseUri = 'https://prices.azure.com/api/retail/prices'
    $allItems = [System.Collections.Generic.List[PSCustomObject]]::new()
    $encodedFilter = [System.Uri]::EscapeDataString($Filter)
    if ([string]::IsNullOrWhiteSpace($CurrencyCode)) { $CurrencyCode = 'USD' }
    $encodedCurrency = [System.Uri]::EscapeDataString($CurrencyCode)
    $uri = "${baseUri}?`$filter=${encodedFilter}&currencyCode=${encodedCurrency}"

    do {
        $response = $null
        for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
            try {
                $response = Invoke-RestMethod -Uri $uri -ErrorAction Stop
                break
            }
            catch {
                $isRetryable = $false
                $statusCode = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
                $exTypeName = $_.Exception.GetType().FullName
                $isNetworkError = -not $_.Exception.Response -and (
                    $_.Exception -is [System.Net.WebException] -or
                    $_.Exception -is [System.OperationCanceledException] -or
                    $exTypeName -eq 'System.Net.Http.HttpRequestException'
                )
                if ($statusCode -eq 429 -or $statusCode -ge 500 -or $isNetworkError) {
                    $isRetryable = $true
                }
                if (-not $isRetryable -or $attempt -eq $MaxAttempts) {
                    throw
                }
                $delay = $BaseDelaySeconds * [math]::Pow(2, $attempt - 1)
                Write-Warning "API request failed (attempt $attempt/$MaxAttempts). Retrying in ${delay}s..."
                Start-Sleep -Seconds $delay
            }
        }
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
