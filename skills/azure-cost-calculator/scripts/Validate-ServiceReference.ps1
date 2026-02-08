<#
.SYNOPSIS
    Validates service reference markdown files against contribution rules.

.DESCRIPTION
    Checks service reference files for YAML front matter, required sections,
    45-line rule compliance, style enforcement, and file placement.
    Returns structured output for CI consumption.

.PARAMETER Path
    One or more paths to service reference markdown files to validate.

.PARAMETER ServicesRoot
    Root directory of the services folder. Used for file placement and alias
    uniqueness checks. Defaults to the standard repo location.

.PARAMETER CheckAliasUniqueness
    When specified, checks for alias collisions across all service files.

.EXAMPLE
    .\Validate-ServiceReference.ps1 -Path services/compute/my-service.md

.EXAMPLE
    .\Validate-ServiceReference.ps1 -Path *.md -CheckAliasUniqueness
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string[]]$Path,

    [string]$ServicesRoot,

    [switch]$CheckAliasUniqueness
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ValidCategories = @(
    'compute', 'containers', 'databases', 'networking', 'storage',
    'security', 'monitoring', 'management', 'integration', 'analytics',
    'ai-ml', 'iot', 'developer-tools', 'identity', 'migration',
    'web', 'communication', 'specialist'
)

$RequiredFrontMatterFields = @('serviceName', 'category', 'aliases')

$RequiredSections = @(
    'Query Pattern',
    'Cost Formula',
    'Notes'
)

function Get-FrontMatter {
    param([string[]]$Lines)

    $result = @{ Found = $false; Fields = @{}; EndLine = 0 }

    if ($Lines.Count -eq 0 -or $Lines[0].Trim() -ne '---') {
        return $result
    }

    # Find the closing --- delimiter
    for ($i = 1; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i].Trim() -eq '---') {
            $result.Found = $true
            $result.EndLine = $i
            break
        }
    }

    if (-not $result.Found) {
        return $result
    }

    # Extract front matter lines (between the --- markers)
    $frontMatterLines = @()
    if ($result.EndLine -gt 1) {
        $frontMatterLines = $Lines[1..($result.EndLine - 1)]
    }

    # Parse supporting both single-line "key: value" and multi-line "key:" followed by "- item" lines
    $index = 0
    while ($index -lt $frontMatterLines.Count) {
        $line = $frontMatterLines[$index]

        # Match single-line "key: value" (value is non-empty)
        if ($line -match '^\s*(\w+)\s*:\s*(.+)$') {
            $key = $Matches[1]
            $value = $Matches[2].Trim()
            $result.Fields[$key] = $value
            $index++
            continue
        }

        # Match "key:" with no value -- consume subsequent lines
        if ($line -match '^\s*(\w+)\s*:\s*$') {
            $key = $Matches[1]
            $index++

            # Check if next line is a bracketed list (single or multi-line)
            if ($index -lt $frontMatterLines.Count -and $frontMatterLines[$index] -match '^\s+\[') {
                # Accumulate lines until we find the closing bracket
                $bracketContent = ''
                while ($index -lt $frontMatterLines.Count) {
                    $bracketContent += $frontMatterLines[$index].Trim()
                    if ($frontMatterLines[$index] -match '\]\s*$') {
                        $index++
                        break
                    }
                    $index++
                }
                $result.Fields[$key] = $bracketContent
                continue
            }

            # Otherwise consume "- item" YAML sequence lines
            $items = @()
            while ($index -lt $frontMatterLines.Count) {
                $nextLine = $frontMatterLines[$index]
                if ($nextLine -match '^\s+\-\s*(.+)$') {
                    $items += $Matches[1].Trim()
                    $index++
                    continue
                }
                break
            }
            # Store as comma-joined bracket string to match inline format downstream
            $result.Fields[$key] = '[' + ($items -join ', ') + ']'
            continue
        }

        $index++
    }

    return $result
}

function Test-ServiceReference {
    param([string]$FilePath)

    $checks = [System.Collections.Generic.List[object]]::new()
    $fullPath = Resolve-Path -Path $FilePath -ErrorAction SilentlyContinue

    if (-not $fullPath) {
        $checks.Add(@{ Name = 'file_exists'; Pass = $false; Message = "File not found: $FilePath" })
        return $checks
    }

    $lines = Get-Content -Path $fullPath

    # --- YAML Front Matter ---
    $fm = Get-FrontMatter -Lines $lines

    $checks.Add(@{
            Name    = 'yaml_front_matter'
            Pass    = $fm.Found
            Message = if ($fm.Found) { 'YAML front matter found' } else { 'Missing YAML front matter (file must start with ---)' }
        })

    if ($fm.Found) {
        foreach ($field in $RequiredFrontMatterFields) {
            $hasField = $fm.Fields.ContainsKey($field) -and $fm.Fields[$field].Length -gt 0
            $checks.Add(@{
                    Name    = "frontmatter_$field"
                    Pass    = $hasField
                    Message = if ($hasField) { "$field is present" } else { "Missing required front matter field: $field" }
                })
        }

        # --- Alias-specific: ensure at least one alias actually exists ---
        if ($fm.Fields.ContainsKey('aliases')) {
            $aliasValue = $fm.Fields['aliases']
            $parsedAliases = @()
            if ($aliasValue -is [string]) {
                $stripped = $aliasValue -replace '^\[', '' -replace '\]$', ''
                $parsedAliases = @($stripped -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            }
            elseif ($aliasValue -is [System.Collections.IEnumerable]) {
                $parsedAliases = @($aliasValue | ForEach-Object { $_.ToString().Trim() } | Where-Object { $_ })
            }
            $hasAliases = $parsedAliases.Count -gt 0
            $checks.Add(@{
                    Name    = 'aliases_not_empty'
                    Pass    = $hasAliases
                    Message = if ($hasAliases) { "aliases contains $($parsedAliases.Count) entry(s)" } else { 'aliases field is present but empty - at least one alias is required' }
                })
        }

        # --- Category validation ---
        if ($fm.Fields.ContainsKey('category')) {
            $rawCategory = $fm.Fields['category'].Trim()
            $isValidCategory = $ValidCategories -contains $rawCategory
            $checks.Add(@{
                    Name    = 'category_valid'
                    Pass    = $isValidCategory
                    Message = if ($isValidCategory) {
                        "Category '$rawCategory' is valid"
                    }
                    else {
                        "Invalid category '$rawCategory'. Must be one of: $($ValidCategories -join ', ')"
                    }
                })
        }

        # --- File placement ---
        $pathStr = $fullPath.ToString().Replace('\', '/')
        if ($fm.Fields.ContainsKey('category')) {
            if ($pathStr -match 'services/([^/]+)/') {
                $folderCategory = $Matches[1]
                $expectedCategory = $fm.Fields['category'].Trim()
                $placementOk = $folderCategory -eq $expectedCategory
                $checks.Add(@{
                        Name    = 'file_placement'
                        Pass    = $placementOk
                        Message = if ($placementOk) {
                            "File is in correct category folder '$folderCategory'"
                        }
                        else {
                            "File is in '$folderCategory/' but category is '$expectedCategory'"
                        }
                    })
            }
            else {
                $checks.Add(@{
                        Name    = 'file_placement'
                        Pass    = $false
                        Message = "File is not under a 'references/services/<category>/' directory"
                    })
            }
        }
    }

    # --- 45-Line Rule ---
    $first45 = if ($lines.Count -ge 45) { $lines[0..44] } else { $lines }
    $hasQueryInFirst45 = $false
    for ($i = 0; $i -lt $first45.Count; $i++) {
        if ($first45[$i] -match '(?i)^\s*```(powershell|pwsh)') {
            $hasQueryInFirst45 = $true
            break
        }
    }

    $checks.Add(@{
            Name    = 'forty_five_line_rule'
            Pass    = $hasQueryInFirst45
            Message = if ($hasQueryInFirst45) {
                'Query pattern (```powershell/pwsh) found within first 45 lines'
            }
            else {
                'No ```powershell or ```pwsh block found within first 45 lines (45-line rule)'
            }
        })

    # --- Required Sections (must be h2 per TEMPLATE.md spec) ---
    foreach ($section in $RequiredSections) {
        $pattern = "^#{2}\s+$([regex]::Escape($section))\s*$"
        $hasSection = @($lines | Where-Object { $_ -match $pattern }).Count -gt 0
        $checks.Add(@{
                Name    = "section_$(($section -replace '\s+', '_').ToLower())"
                Pass    = $hasSection
                Message = if ($hasSection) { "Section '$section' found" } else { "Missing required section: ## $section" }
            })
    }

    # --- Style: No "verified" dates (skip fenced code blocks) ---
    $nonCodeLines = [System.Collections.Generic.List[string]]::new()
    $insideCodeBlock = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*```') {
            $insideCodeBlock = -not $insideCodeBlock
            continue
        }
        if (-not $insideCodeBlock) {
            $nonCodeLines.Add($line)
        }
    }
    $verifiedPattern = '(?i)\bverified\b.*\d{4}'
    $hasVerifiedDate = @($nonCodeLines | Where-Object { $_ -match $verifiedPattern }).Count -gt 0
    $checks.Add(@{
            Name    = 'no_verified_dates'
            Pass    = -not $hasVerifiedDate
            Message = if (-not $hasVerifiedDate) {
                'No "verified" dates found'
            }
            else {
                'Found "verified" date annotation. Remove all verified dates per style rules.'
            }
        })

    # --- Style: No "(case-sensitive)" in headers ---
    $caseAnnotation = @($lines | Where-Object { $_ -match '^#+\s+.*\(case-sensitive\)' }).Count -gt 0
    $checks.Add(@{
            Name    = 'no_case_sensitive_headers'
            Pass    = -not $caseAnnotation
            Message = if (-not $caseAnnotation) {
                'No "(case-sensitive)" annotations in headers'
            }
            else {
                'Found "(case-sensitive)" in section header. Case-sensitivity is assumed per shared.md.'
            }
        })

    # --- Style: Trap format ---
    $trapLines = $lines | Where-Object { $_ -match '>\s*\*\*Trap' }
    $badTraps = @($trapLines | Where-Object { $_ -notmatch '>\s*\*\*Trap\*\*:' -and $_ -notmatch '>\s*\*\*Trap\s*\(.*\)\*\*:' })
    $trapFormatOk = $badTraps.Count -eq 0
    $checks.Add(@{
            Name    = 'trap_format'
            Pass    = $trapFormatOk
            Message = if ($trapFormatOk) {
                'Trap format is correct'
            }
            else {
                'Invalid trap format. Use: > **Trap**: ... or > **Trap ({name})**: ...'
            }
        })

    return $checks
}

function Test-AliasUniqueness {
    param([string]$RootPath)

    $checks = [System.Collections.Generic.List[object]]::new()
    $RootPath = (Resolve-Path -Path $RootPath).Path
    $aliasMap = @{}
    $files = Get-ChildItem -Path $RootPath -Filter '*.md' -Recurse |
    Where-Object { $_.Name -ne 'TEMPLATE.md' }

    foreach ($file in $files) {
        $fileLines = Get-Content -Path $file.FullName
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
                $checks.Add(@{
                        Name    = 'alias_uniqueness'
                        Pass    = $false
                        Message = "Alias '$alias' is used in both '$($aliasMap[$key])' and '$relativePath'"
                    })
            }
            else {
                $aliasMap[$key] = $relativePath
            }
        }
    }

    if ($checks.Count -eq 0) {
        $checks.Add(@{
                Name    = 'alias_uniqueness'
                Pass    = $true
                Message = 'No alias collisions detected'
            })
    }

    return $checks
}

# --- Main ---
$allResults = @{}
$hasFailures = $false

foreach ($filePath in $Path) {
    $resolvedPaths = @()
    if ($filePath -match '[*?]') {
        $resolvedPaths = Get-ChildItem -Path $filePath -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName
    }
    else {
        $resolvedPaths = @($filePath)
    }

    foreach ($rp in $resolvedPaths) {
        $checks = Test-ServiceReference -FilePath $rp
        $fileName = Split-Path -Leaf $rp
        $allResults[$fileName] = $checks

        foreach ($check in $checks) {
            $status = if ($check.Pass) { 'PASS' } else { 'FAIL' }
            $icon = if ($check.Pass) { '+' } else { '-' }
            Write-Output "[$icon] $status $fileName :: $($check.Name) - $($check.Message)"
            if (-not $check.Pass) { $hasFailures = $true }
        }
    }
}

if ($CheckAliasUniqueness) {
    $root = if ($ServicesRoot) { $ServicesRoot } else {
        Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'references', 'services'
    }
    if (Test-Path $root) {
        $aliasChecks = Test-AliasUniqueness -RootPath $root
        $allResults['_alias_uniqueness'] = $aliasChecks
        foreach ($check in $aliasChecks) {
            $status = if ($check.Pass) { 'PASS' } else { 'FAIL' }
            $icon = if ($check.Pass) { '+' } else { '-' }
            Write-Output "[$icon] $status alias_check :: $($check.Name) - $($check.Message)"
            if (-not $check.Pass) { $hasFailures = $true }
        }
    }
}

Write-Output ''
if ($hasFailures) {
    Write-Output 'RESULT: FAIL - One or more checks failed'
    exit 1
}
else {
    Write-Output 'RESULT: PASS - All checks passed'
    exit 0
}
