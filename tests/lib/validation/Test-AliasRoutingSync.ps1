Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-FrontMatter.ps1')

function Get-RoutingMapEntry {
    <#
    .SYNOPSIS
        Parses routing map entries from service-routing.md.
    .DESCRIPTION
        Extracts service and alias entries from colon-delimited lines
        in the routing map markdown file.
    .PARAMETER RoutingMapPath
        Path to the service-routing.md file.
    .OUTPUTS
        System.Array of hashtables with Service and Aliases keys.
    #>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$RoutingMapPath
    )

    $lines = @(Get-Content -Path $RoutingMapPath -Encoding UTF8)
    $entries = [System.Collections.Generic.List[hashtable]]::new()
    $inSection = $false

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^\s*#') {
            if ($line -match '^##\s+.+\(services/[^)]+\)') { $inSection = $true }
            continue
        }
        if (-not $inSection) { continue }
        if ($line -notmatch '^\s*-\s+') { continue }

        $entryLine = $line -replace '^\s*-\s+', ''
        $colonIndex = $entryLine.IndexOf(':')
        if ($colonIndex -lt 0) { continue }
        $serviceName = $entryLine.Substring(0, $colonIndex).Trim()
        $aliasString = $entryLine.Substring($colonIndex + 1).Trim()

        if (-not $serviceName) { continue }

        $aliases = @()
        foreach ($a in ($aliasString -split ',')) {
            $trimmed = $a.Trim()
            if ($trimmed) { $aliases += $trimmed }
        }
        $entries.Add(@{ Service = $serviceName; Aliases = $aliases })
    }

    , $entries
}

function Test-AliasRoutingSync {
    <#
    .SYNOPSIS
        Validates alias sync between routing map and service reference files.
    .DESCRIPTION
        Performs bidirectional checks:
        1. Every file alias must exist in at least one routing map entry.
        2. Every routing map alias must be covered by at least one file.
        Handles split-file services (DNS, Storage) where multiple files
        share aliases from one or more routing entries.
    .PARAMETER RootPath
        Root directory of the services folder to scan.
    .PARAMETER RoutingMapPath
        Path to the service-routing.md file. Defaults to the standard
        repo location relative to RootPath.
    .OUTPUTS
        System.Array
    .EXAMPLE
        Test-AliasRoutingSync -RootPath 'skills/azure-cost-calculator/references/services'
    #>
    [CmdletBinding()]
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
        $checks.Add((New-ValidationCheck -Name 'alias_routing_sync' -Pass $false `
                    -PassMessage 'n/a' -FailMessage "Routing map not found: $RoutingMapPath"))
    }
    else {
        $routingEntries = Get-RoutingMapEntry -RoutingMapPath $RoutingMapPath

        # Build a set of all routing aliases (lowercase → original)
        $routingAliasSet = @{}
        foreach ($entry in $routingEntries) {
            foreach ($alias in $entry.Aliases) {
                $routingAliasSet[$alias.ToLowerInvariant()] = $alias
            }
        }

        # Parse all file aliases
        $fileAliasSet = @{}
        $files = Get-ChildItem -Path $RootPath -Filter '*.md' -Recurse

        foreach ($file in $files) {
            $fileLines = @(Get-Content -Path $file.FullName -Encoding UTF8)
            $fm = Get-FrontMatter -Lines $fileLines
            if (-not $fm.Found -or -not $fm.Fields.ContainsKey('aliases')) { continue }

            $aliasRaw = $fm.Fields['aliases']
            $aliases = @()

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

            $relativePath = $file.Name
            if ($file.FullName.StartsWith($RootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
                $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\', '/')
            }

            foreach ($alias in $aliases) {
                $alias = $alias -replace '^[''"]', '' -replace '[''"]$', ''
                $key = $alias.ToLowerInvariant()
                if (-not $fileAliasSet.ContainsKey($key)) {
                    $fileAliasSet[$key] = @{ Alias = $alias; Files = @($relativePath) }
                }
                else {
                    $fileAliasSet[$key].Files += $relativePath
                }
            }
        }

        # Check 1: Every file alias must exist in the routing map
        foreach ($key in $fileAliasSet.Keys) {
            if (-not $routingAliasSet.ContainsKey($key)) {
                $info = $fileAliasSet[$key]
                $fileList = $info.Files -join ', '
                $checks.Add((New-ValidationCheck -Name 'alias_routing_sync' -Pass $false `
                            -PassMessage 'n/a' `
                            -FailMessage "File alias '$($info.Alias)' (in $fileList) not found in routing map"))
            }
        }

        # Check 2: Every routing alias must exist in at least one file
        # Only check routing entries that have at least one matching file
        foreach ($entry in $routingEntries) {
            $entryAliasKeys = $entry.Aliases | ForEach-Object { $_.ToLowerInvariant() }
            $hasMatchingFile = $false
            foreach ($key in $entryAliasKeys) {
                if ($fileAliasSet.ContainsKey($key)) { $hasMatchingFile = $true; break }
            }
            if (-not $hasMatchingFile) { continue }

            foreach ($alias in $entry.Aliases) {
                $key = $alias.ToLowerInvariant()
                if (-not $fileAliasSet.ContainsKey($key)) {
                    $checks.Add((New-ValidationCheck -Name 'alias_routing_sync' -Pass $false `
                                -PassMessage 'n/a' `
                                -FailMessage "Routing alias '$alias' (entry: $($entry.Service)) not found in any file"))
                }
            }
        }
    }

    if ($checks.Count -eq 0) {
        $checks.Add((New-ValidationCheck -Name 'alias_routing_sync' -Pass $true `
                    -PassMessage 'All aliases are in sync between routing map and service files' `
                    -FailMessage 'n/a'))
    }

    , $checks
}
