Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-FrontMatter.ps1')

function Test-AliasUniqueness {
    <#
    .SYNOPSIS
        Checks for alias collisions across all service reference files.
    .DESCRIPTION
        Scans all markdown files under the given root path (excluding
        TEMPLATE.md), parses their YAML front matter aliases, and reports
        any duplicates. Returns one or more check results.
    .PARAMETER RootPath
        Root directory of the services folder to scan for alias collisions.
    .OUTPUTS
        System.Collections.Generic.List[object]
    .EXAMPLE
        Test-AliasUniqueness -RootPath 'skills/azure-cost-calculator/references/services'
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[object]])]
    param(
        [Parameter(Mandatory)]
        [string]$RootPath
    )

    $checks = [System.Collections.Generic.List[object]]::new()
    $RootPath = (Resolve-Path -Path $RootPath).Path
    $aliasMap = @{}
    $files = Get-ChildItem -Path $RootPath -Filter '*.md' -Recurse |
        Where-Object { $_.Name -ne 'TEMPLATE.md' }

    foreach ($file in $files) {
        $fileLines = @(Get-Content -Path $file.FullName)
        $fm = Get-FrontMatter -Lines $fileLines
        if (-not $fm.Found -or -not $fm.Fields.ContainsKey('aliases')) { continue }

        $aliasRaw = $fm.Fields['aliases']
        $aliases = @()

        # Handle both YAML sequences (array objects) and inline bracket strings
        if ($aliasRaw -is [System.Collections.IEnumerable] -and -not ($aliasRaw -is [string])) {
            foreach ($item in $aliasRaw) {
                if ($null -ne $item -and $item.ToString().Trim()) {
                    $aliases += $item.ToString().Trim()
                }
            }
        }
        else {
            $aliasString = $aliasRaw.ToString()
            $aliasString = $aliasString -replace '^\[', '' -replace '\]$', ''
            $aliases = $aliasString -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }

        # Use relative path for clearer reporting
        $relativePath = $file.Name
        if ($file.FullName.StartsWith($RootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\', '/')
        }

        foreach ($alias in $aliases) {
            $key = $alias.ToLower()
            if ($aliasMap.ContainsKey($key)) {
                $checks.Add((New-ValidationCheck -Name 'alias_uniqueness' -Pass $false `
                    -PassMessage 'n/a' `
                    -FailMessage "Alias '$alias' is used in both '$($aliasMap[$key])' and '$relativePath'"))
            }
            else {
                $aliasMap[$key] = $relativePath
            }
        }
    }

    if ($checks.Count -eq 0) {
        $checks.Add((New-ValidationCheck -Name 'alias_uniqueness' -Pass $true `
            -PassMessage 'No alias collisions detected' `
            -FailMessage 'n/a'))
    }

    , $checks
}
