Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-FrontMatter.ps1')
function Test-BillingNeedsReference {
    <#
    .SYNOPSIS
        Checks that every billingNeeds entry references a valid serviceName.
    .DESCRIPTION
        Scans all markdown files under the given root path, builds a set
        of known serviceName values, then verifies every billingNeeds
        entry in every file matches an actual serviceName in the repo.
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
    # First pass: collect all known serviceName values (case-insensitive)
    $serviceNames = @{}
    foreach ($file in $files) {
        $fileLines = @(Get-Content -Path $file.FullName -Encoding UTF8)
        $fm = Get-FrontMatter -Lines $fileLines
        if (-not $fm.Found -or -not $fm.Fields.ContainsKey('serviceName')) { continue }
        $name = $fm.Fields['serviceName'].ToString().Trim()
        $name = $name -replace '^[''""]', '' -replace '[''""]$', ''
        if ($name) {
            $serviceNames[$name.ToLowerInvariant()] = $name
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
            if (-not $serviceNames.ContainsKey($key)) {
                $checks.Add((New-ValidationCheck -Name 'billing_needs_reference' -Pass $false `
                            -PassMessage 'n/a' `
                            -FailMessage "billingNeeds value '$need' in '$relativePath' does not match any serviceName in the repo"))
            }
        }
    }
    if ($checks.Count -eq 0) {
        $checks.Add((New-ValidationCheck -Name 'billing_needs_reference' -Pass $true `
                    -PassMessage 'All billingNeeds entries reference valid serviceNames' `
                    -FailMessage 'n/a'))
    }
    , $checks
}