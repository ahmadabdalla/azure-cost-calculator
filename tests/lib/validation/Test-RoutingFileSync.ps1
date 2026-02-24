Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-FrontMatter.ps1')
. (Join-Path $PSScriptRoot 'Test-AliasRoutingSync.ps1')

function Test-RoutingFileSync {
    <#
    .SYNOPSIS
        Validates that routing map entries and service files are in sync.
    .DESCRIPTION
        Performs bidirectional checks using aliases as the link between
        routing entries and files (since routing s: values are logical
        names that may differ from a file's serviceName):
        1. Every routing entry must have at least one file sharing an alias.
        2. Every service file must have at least one routing entry sharing an alias.
    .PARAMETER RootPath
        Root directory of the services folder to scan.
    .PARAMETER RoutingMapPath
        Path to the service-routing.md file. Defaults to the standard
        repo location relative to RootPath.
    .OUTPUTS
        System.Array of validation check hashtables.
    .EXAMPLE
        Test-RoutingFileSync -RootPath 'skills/azure-cost-calculator/references/services'
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '')]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$RootPath,

        [string]$RoutingMapPath
    )

    $checks = [System.Collections.Generic.List[object]]::new()
    $RootPath = (Resolve-Path -Path $RootPath).Path

    if (-not $RoutingMapPath) {
        $RoutingMapPath = Join-Path -Path $RootPath -ChildPath '..' -AdditionalChildPath 'service-routing.md'
    }

    if (-not (Test-Path $RoutingMapPath)) {
        $checks.Add((New-ValidationCheck -Name 'routing_file_sync' -Pass $false `
                    -PassMessage 'n/a' -FailMessage "Routing map not found: $RoutingMapPath"))
        return , $checks
    }

    $routingEntries = Get-RoutingMapEntry -RoutingMapPath $RoutingMapPath

    # Build per-file alias sets
    $files = Get-ChildItem -Path $RootPath -Filter '*.md' -Recurse
    $fileAliases = [System.Collections.Generic.List[hashtable]]::new()
    # All file aliases flattened for O(1) lookup in Check 1
    $allFileAliases = @{}

    foreach ($file in $files) {
        $fileLines = @(Get-Content -Path $file.FullName -Encoding UTF8)
        $fm = Get-FrontMatter -Lines $fileLines
        if (-not $fm.Found -or -not $fm.Fields.ContainsKey('aliases')) { continue }

        $relativePath = $file.Name
        if ($file.FullName.StartsWith($RootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\', '/')
        }

        $aliasRaw = $fm.Fields['aliases']
        $aliases = @()
        if ($aliasRaw -is [System.Collections.IEnumerable] -and -not ($aliasRaw -is [string])) {
            foreach ($item in $aliasRaw) {
                if ($null -eq $item) { continue }
                $trimmed = $item.ToString().Trim().Trim('"', "'")
                if ($trimmed) { $aliases += $trimmed.ToLowerInvariant() }
            }
        }
        elseif ($null -ne $aliasRaw) {
            $aliasString = $aliasRaw.ToString() -replace '^\[', '' -replace '\]$', ''
            $aliases = @($aliasString -split ',' | ForEach-Object { $_.Trim().Trim('"', "'") } |
                Where-Object { $_ } | ForEach-Object { $_.ToLowerInvariant() })
        }

        if ($aliases.Count -gt 0) {
            $fileAliases.Add(@{ RelPath = $relativePath; Aliases = $aliases })
            foreach ($a in $aliases) {
                $allFileAliases[$a] = $true
            }
        }
    }

    # Check 1: Every routing entry must have at least one file sharing an alias
    foreach ($entry in $routingEntries) {
        $found = $false
        foreach ($a in $entry.Aliases) {
            if ($allFileAliases.ContainsKey($a.ToLowerInvariant())) { $found = $true; break }
        }
        if (-not $found) {
            $checks.Add((New-ValidationCheck -Name 'routing_file_sync' -Pass $false `
                        -PassMessage 'n/a' `
                        -FailMessage "Routing entry '$($entry.Service)' has no matching service file"))
        }
    }

    # Check 2: Every file with aliases must have at least one routing entry sharing an alias
    # Build flat set of all routing aliases for fast lookup
    $allRoutingAliases = @{}
    foreach ($entry in $routingEntries) {
        foreach ($a in $entry.Aliases) {
            $allRoutingAliases[$a.ToLowerInvariant()] = $true
        }
    }

    foreach ($fa in $fileAliases) {
        $found = $false
        foreach ($a in $fa.Aliases) {
            if ($allRoutingAliases.ContainsKey($a)) { $found = $true; break }
        }
        if (-not $found) {
            $checks.Add((New-ValidationCheck -Name 'routing_file_sync' -Pass $false `
                        -PassMessage 'n/a' `
                        -FailMessage "Service file '$($fa.RelPath)' has no matching routing entry"))
        }
    }

    if ($checks.Count -eq 0) {
        $checks.Add((New-ValidationCheck -Name 'routing_file_sync' -Pass $true `
                    -PassMessage 'All routing entries and service files are in sync' `
                    -FailMessage 'n/a'))
    }

    , $checks
}
