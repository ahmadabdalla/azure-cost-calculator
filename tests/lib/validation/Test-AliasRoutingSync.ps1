Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-FrontMatter.ps1')

function Get-RoutingMapAliases {
    <#
    .SYNOPSIS
        Parses the service routing map and returns a hashtable of
        service-name to alias-array mappings.
    .PARAMETER RoutingMapPath
        Path to the service-routing.md file.
    .OUTPUTS
        hashtable  Keys are routing entry service names (s: values),
                   values are arrays of alias strings.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$RoutingMapPath
    )

    $lines = Get-Content -Path $RoutingMapPath -Encoding UTF8
    $map = @{}
    $currentService = $null
    $inMultiLine = $false
    $bracketBuffer = ''

    # Helper: merge aliases into the map (handles duplicate service entries)
    function Add-AliasesToMap {
        param([hashtable]$Map, [string]$Service, [string[]]$Aliases)
        if ($Map.ContainsKey($Service)) {
            $Map[$Service] = @($Map[$Service]) + @($Aliases)
        }
        else {
            $Map[$Service] = @($Aliases)
        }
    }

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if ($line -match '^\s*-\s*s:\s*"([^"]+)"') {
            $currentService = $Matches[1]
        }

        # Multi-line alias block start (a: with no value on the same line)
        if ($line -match '^\s*a:\s*$' -and $currentService) {
            $inMultiLine = $true
            $bracketBuffer = ''
            continue
        }

        if ($inMultiLine) {
            $trimmed = $line.Trim()
            $bracketBuffer = if ($bracketBuffer) { "$bracketBuffer $trimmed" } else { $trimmed }
            if ($line -match '\]') {
                $inMultiLine = $false
                $aliasStr = $bracketBuffer -replace '^\[', '' -replace '\]\s*$', ''
                $aliases = $aliasStr -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
                Add-AliasesToMap -Map $map -Service $currentService -Aliases $aliases
                $currentService = $null
            }
            continue
        }

        # Single-line alias list
        if ($line -match '\[(.+)\]' -and $currentService) {
            $aliasStr = $Matches[1]
            $aliases = $aliasStr -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            Add-AliasesToMap -Map $map -Service $currentService -Aliases $aliases
            $currentService = $null
        }
    }

    $map
}

function Test-AliasRoutingSync {
    <#
    .SYNOPSIS
        Validates that file frontmatter aliases are drawn from the
        routing map and contain no extras.
    .DESCRIPTION
        For each service reference file, finds the corresponding routing
        map entry and checks that every alias in the file also appears
        in the routing map entry (case-insensitive). Reports any alias
        present in the file but absent from the routing map.
    .PARAMETER RootPath
        Root directory of the services folder.
    .PARAMETER RoutingMapPath
        Path to service-routing.md.
    .OUTPUTS
        System.Array
    #>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$RootPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$RoutingMapPath
    )

    $checks = [System.Collections.Generic.List[object]]::new()
    $RootPath = (Resolve-Path -Path $RootPath).Path
    $routingAliases = Get-RoutingMapAliases -RoutingMapPath $RoutingMapPath

    # Build a flattened set of all routing map aliases (case-insensitive)
    $allRoutingAliasesLower = @{}
    foreach ($entry in $routingAliases.GetEnumerator()) {
        foreach ($alias in $entry.Value) {
            $allRoutingAliasesLower[$alias.ToLowerInvariant()] = $entry.Key
        }
    }

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
            $aliases = @($aliasString -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        }

        $relativePath = $file.Name
        if ($file.FullName.StartsWith($RootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\', '/')
        }

        foreach ($alias in $aliases) {
            $alias = $alias -replace '^[''"]', '' -replace '[''"]$', ''
            $key = $alias.ToLowerInvariant()
            if (-not $allRoutingAliasesLower.ContainsKey($key)) {
                $checks.Add((New-ValidationCheck -Name 'alias_routing_sync' -Pass $false `
                            -PassMessage 'n/a' `
                            -FailMessage "Alias '$alias' in '$relativePath' is not in the routing map"))
            }
        }
    }

    if ($checks.Count -eq 0) {
        $checks.Add((New-ValidationCheck -Name 'alias_routing_sync' -Pass $true `
                    -PassMessage 'All file aliases are present in the routing map' `
                    -FailMessage 'n/a'))
    }

    , $checks
}
