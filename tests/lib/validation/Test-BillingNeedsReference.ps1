Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-FrontMatter.ps1')
function Test-BillingNeedsReference {
    <#
    .SYNOPSIS
        Checks that every billingNeeds entry references a valid routing map service name.
    .DESCRIPTION
        Reads the service-routing.md file to build a set of known routing
        map service names (s: values), then verifies every billingNeeds
        entry in every service file matches an actual routing map name.
        Returns one or more check results.
    .PARAMETER RootPath
        Root directory of the services folder to scan for billingNeeds references.
    .OUTPUTS
        System.Array
    .EXAMPLE
        Test-BillingNeedsReference -RootPath 'skills/azure-cost-calculator/references/services'
    #>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$RootPath
    )
    $checks = [System.Collections.Generic.List[object]]::new()
    $RootPath = (Resolve-Path -Path $RootPath).Path
    $files = Get-ChildItem -Path $RootPath -Filter '*.md' -Recurse
    # First pass: collect all known routing map service names (case-insensitive)
    $routingMapPath = Join-Path (Split-Path $RootPath -Parent) 'service-routing.md'
    if (-not (Test-Path $routingMapPath)) {
        $checks.Add((New-ValidationCheck -Name 'billing_needs_reference' -Pass $false `
                    -PassMessage 'n/a' -FailMessage "Routing map not found at '$routingMapPath'"))
        , $checks
        return
    }
    $routingNames = @{}
    $routingLines = @(Get-Content -Path $routingMapPath -Encoding UTF8)
    foreach ($line in $routingLines) {
        if ($line -match "^\s*-\s*s:\s*[`"']?([^`"']+)[`"']?\s*$") {
            $name = $Matches[1].Trim()
            if ($name) {
                $routingNames[$name.ToLowerInvariant()] = $name
            }
        }
    }
    # Second pass: validate billingNeeds references
    foreach ($file in $files) {
        $fileLines = @(Get-Content -Path $file.FullName -Encoding UTF8)
        $fm = Get-FrontMatter -Lines $fileLines
        if (-not $fm.Found -or -not $fm.Fields.ContainsKey('billingNeeds')) { continue }
        $needsRaw = $fm.Fields['billingNeeds']
        $needs = @()
        if ($needsRaw -is [System.Collections.IEnumerable] -and -not ($needsRaw -is [string])) {
            foreach ($item in $needsRaw) {
                if ($null -ne $item -and $item.ToString().Trim()) {
                    $needs += $item.ToString().Trim()
                }
            }
        }
        else {
            $needsString = $needsRaw.ToString()
            $needsString = $needsString -replace '^\[', '' -replace '\]$', ''
            $needs = $needsString -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }
        $relativePath = $file.Name
        if ($file.FullName.StartsWith($RootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\', '/')
        }
        foreach ($need in $needs) {
            $need = $need -replace '^[''""]', '' -replace '[''""]$', ''
            $key = $need.ToLowerInvariant()
            if (-not $routingNames.ContainsKey($key)) {
                $checks.Add((New-ValidationCheck -Name 'billing_needs_reference' -Pass $false `
                            -PassMessage 'n/a' `
                            -FailMessage "billingNeeds value '$need' in '$relativePath' does not match any routing map service name"))
            }
        }
    }
    if ($checks.Count -eq 0) {
        $checks.Add((New-ValidationCheck -Name 'billing_needs_reference' -Pass $true `
                    -PassMessage 'All billingNeeds entries reference valid routing map service names' `
                    -FailMessage 'n/a'))
    }
    , $checks
}