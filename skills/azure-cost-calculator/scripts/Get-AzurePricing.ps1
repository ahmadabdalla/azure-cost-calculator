<#
.SYNOPSIS
    Queries the Azure Retail Prices API and calculates estimated monthly costs.

.DESCRIPTION
    Deterministic pricing script for Azure cost estimation. Queries the public
    Azure Retail Prices REST API (no auth required) with OData filters and returns
    structured pricing data or calculated monthly cost estimates.

.EXAMPLE
    # VM monthly cost
    .\Get-AzurePricing.ps1 -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D2s_v5'

.EXAMPLE
    # Compare regions
    .\Get-AzurePricing.ps1 -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D2s_v5' -Region 'eastus','australiaeast','westeurope' -OutputFormat Table
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ServiceName,

    [Parameter()]
    [string[]]$Region = @('eastus'),

    [Parameter()]
    [string]$ArmSkuName,

    [Parameter()]
    [string]$SkuName,

    [Parameter()]
    [string]$ProductName,

    [Parameter()]
    [string]$MeterName,

    [Parameter()]
    [ValidateSet('Consumption', 'Reservation', 'DevTestConsumption')]
    [string]$PriceType = 'Consumption',

    [Parameter()]
    [Alias('CurrencyCode')]
    [string]$Currency = 'USD',

    [Parameter()]
    [double]$Quantity,

    [Parameter()]
    [double]$HoursPerMonth = 730,

    [Parameter()]
    [int]$InstanceCount = 1,

    [Parameter()]
    [ValidateSet('Table', 'Json', 'Summary')]
    [string]$OutputFormat = 'Json'
)

$ErrorActionPreference = 'Stop'

# Load shared library functions
. "$PSScriptRoot/lib/Build-ODataFilter.ps1"
. "$PSScriptRoot/lib/Invoke-RetailPricesQuery.ps1"
. "$PSScriptRoot/lib/Get-MonthlyMultiplier.ps1"
. "$PSScriptRoot/lib/Get-ReservationTermMonths.ps1"

# ============================================================
# Main logic
# ============================================================

$allResults = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($regionName in $Region) {
    # Build filter
    $filters = [ordered]@{
        'serviceName'   = $ServiceName
        'armRegionName' = $regionName
    }

    if ($PriceType) {
        $filters['priceType'] = $PriceType
    }
    if ($ArmSkuName) {
        $filters['armSkuName'] = $ArmSkuName
    }
    if ($SkuName) {
        $filters['skuName'] = $SkuName
    }
    if ($ProductName) {
        $filters['productName'] = $ProductName
    }
    if ($MeterName) {
        $filters['meterName'] = $MeterName
    }

    $filterString = Build-ODataFilter -Filters $filters
    Write-Verbose "Filter: $filterString"

    # Query API
    try {
        $items = Invoke-RetailPricesQuery -Filter $filterString -CurrencyCode $Currency
    }
    catch [System.Net.WebException] {
        Write-Warning "API request failed for region '$regionName'. Filter: $filterString"
        Write-Warning "Error: $($_.Exception.Message)"
        continue
    }
    catch {
        $ex = $_.Exception
        $isHttpError = ($null -ne $ex.PSObject.Properties['Response']) -or
                       ($null -ne $ex.PSObject.Properties['StatusCode'])

        if ($isHttpError) {
            Write-Warning "API returned error for region '$regionName'. Filter: $filterString"
            Write-Warning "Error: $($ex.Message)"
            continue
        }

        throw
    }

    if ($items.Count -eq 0) {
        Write-Warning "No pricing data found for region '$regionName' with the specified filters."
        Write-Warning "Filter used: $filterString"
        Write-Warning "Tip: Filter values are CASE-SENSITIVE. Verify exact serviceName, skuName, productName values."
        continue
    }

    # Deduplicate: when isPrimaryMeterRegion is available, prefer primary items
    # per unique (meterName + skuName + productName + reservationTerm) combo. But keep non-primary
    # items when no primary exists for that combo (e.g., Key Vault Operations in AU).
    # NOTE: reservationTerm MUST be in the grouping key — without it, 1-Year and 3-Year
    # Reservation items collapse into one group. When both are isPrimaryMeterRegion=true,
    # $primary becomes an array, causing downstream type errors (unitOfMeasure becomes
    # an array instead of a string, failing Get-MonthlyMultiplier's [string] parameter).
    $grouped = $items | Group-Object -Property { "$($_.meterName)|$($_.skuName)|$($_.productName)|$($_.tierMinimumUnits)|$($_.reservationTerm)" }
    $deduped = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($group in $grouped) {
        $primary = $group.Group | Where-Object { $_.isPrimaryMeterRegion -eq $true }
        if ($primary) {
            $deduped.Add(($primary | Select-Object -First 1))
        }
        else {
            $deduped.Add(($group.Group | Select-Object -First 1))
        }
    }
    $items = $deduped

    foreach ($item in $items) {
        $multiplier = Get-MonthlyMultiplier -UnitOfMeasure $item.unitOfMeasure -HoursMonth $HoursPerMonth
        $unitPrice = [double]$item.retailPrice

        # Calculate monthly cost
        $termMonths = Get-ReservationTermMonths -ReservationTerm $item.reservationTerm
        if ($termMonths) {
            # RI: retailPrice is total prepaid cost — divide by term months
            $monthlyCost = ($unitPrice / $termMonths) * $InstanceCount
            if ($Quantity -gt 0) {
                $monthlyCost = $monthlyCost * $Quantity
            }
        }
        elseif (-not [string]::IsNullOrEmpty($item.reservationTerm)) {
            # Unknown reservation term — warn instead of silently using consumption math
            Write-Warning "Unknown reservationTerm '$($item.reservationTerm)' for '$($item.productName)'. MonthlyCost may be incorrect."
            if ($Quantity -gt 0) {
                $monthlyCost = $unitPrice * $Quantity * $multiplier * $InstanceCount
            }
            else {
                $monthlyCost = $unitPrice * $multiplier * $InstanceCount
            }
        }
        else {
            # Consumption: retailPrice is per-unit rate — multiply by monthly multiplier
            if ($Quantity -gt 0) {
                $monthlyCost = $unitPrice * $Quantity * $multiplier * $InstanceCount
            }
            else {
                $monthlyCost = $unitPrice * $multiplier * $InstanceCount
            }
        }

        $allResults.Add([PSCustomObject]@{
                Region            = $item.armRegionName
                ServiceName       = $item.serviceName
                ProductName       = $item.productName
                SkuName           = $item.skuName
                ArmSkuName        = $item.armSkuName
                MeterName         = $item.meterName
                UnitPrice         = $unitPrice
                UnitOfMeasure     = $item.unitOfMeasure
                Currency          = $item.currencyCode
                PriceType         = $item.type
                MonthlyCost       = [math]::Round($monthlyCost, 2)
                ReservationTerm   = $item.reservationTerm
                InstanceCount     = $InstanceCount
                Quantity          = if ($Quantity -gt 0) { $Quantity } else { 1 }
                QuantitySpecified = ($Quantity -gt 0)
                TierMinUnits      = $item.tierMinimumUnits
            })
    }
}

# ============================================================
# Output
# ============================================================

if ($allResults.Count -eq 0) {
    Write-Warning 'No results to display.'
    return
}

switch ($OutputFormat) {
    'Table' {
        $allResults |
        Sort-Object Region, MonthlyCost |
        Format-Table Region, ProductName, SkuName, MeterName,
        @{Label = 'UnitPrice'; Expression = { '{0:N4}' -f $_.UnitPrice }; Align = 'Right' },
        UnitOfMeasure,
        @{Label = 'Monthly'; Expression = { '{0:N2}' -f $_.MonthlyCost }; Align = 'Right' },
        Currency -AutoSize
    }
    'Json' {
        $output = @{
            query      = @{
                serviceName = $ServiceName
                regions     = $Region
                currency    = $Currency
                priceType   = $PriceType
                filters     = @{
                    armSkuName  = $ArmSkuName
                    skuName     = $SkuName
                    productName = $ProductName
                    meterName   = $MeterName
                }
            }
            results    = $allResults
            totalItems = $allResults.Count
            summary    = @{
                minMonthlyCost   = ($allResults | Measure-Object -Property MonthlyCost -Minimum).Minimum
                maxMonthlyCost   = ($allResults | Measure-Object -Property MonthlyCost -Maximum).Maximum
                totalMonthlyCost = ($allResults | Measure-Object -Property MonthlyCost -Sum).Sum
            }
        }
        $output | ConvertTo-Json -Depth 5
    }
    'Summary' {
        $summaryLines = [System.Collections.Generic.List[string]]::new()
        $summaryLines.Add('')
        $summaryLines.Add('=== Azure Pricing Estimate ===')
        $summaryLines.Add("Service:  $ServiceName")
        $summaryLines.Add("Region:   $($Region -join ', ')")
        $summaryLines.Add("Currency: $Currency")
        $summaryLines.Add("Type:     $PriceType")
        if ($InstanceCount -gt 1) {
            $summaryLines.Add("Instances: $InstanceCount")
        }
        $summaryLines.Add('')

        foreach ($item in ($allResults | Sort-Object Region, MonthlyCost)) {
            $label = if ($item.MeterName) { $item.MeterName } else { $item.ProductName }
            $line = "  $($item.Region) | $label | $($item.UnitPrice) $($item.Currency)/$($item.UnitOfMeasure) | Monthly: $($item.Currency) $([string]::Format('{0:N2}', $item.MonthlyCost))"
            if ($item.TierMinUnits -and $item.TierMinUnits -gt 0) {
                $line += " (tier: above $($item.TierMinUnits) units)"
            }
            $summaryLines.Add($line)
        }

        $totalMonthly = ($allResults | Measure-Object -Property MonthlyCost -Sum).Sum
        $summaryLines.Add('')
        $summaryLines.Add('  ---')
        $summaryLines.Add("  TOTAL ESTIMATED MONTHLY: $Currency $([string]::Format('{0:N2}', $totalMonthly))")
        $summaryLines.Add('')

        Write-Information -MessageData ($summaryLines -join [System.Environment]::NewLine) -InformationAction Continue
    }
}
