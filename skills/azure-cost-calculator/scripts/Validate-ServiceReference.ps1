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

    $lines = @(Get-Content -Path $fullPath)

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
            if ($pathStr -match 'references/services/([^/]+)/') {
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
    # Accept either a ```powershell/pwsh code block OR a declarative ServiceName: line
    $first45 = if ($lines.Count -ge 45) { $lines[0..44] } else { $lines }
    $hasQueryInFirst45 = $false
    for ($i = 0; $i -lt $first45.Count; $i++) {
        if ($first45[$i] -match '(?i)^\s*```(powershell|pwsh)' -or $first45[$i] -match '^\s*ServiceName\s*:' -or $first45[$i] -match '^\s*API\s*:') {
            $hasQueryInFirst45 = $true
            break
        }
    }

    $checks.Add(@{
            Name    = 'forty_five_line_rule'
            Pass    = $hasQueryInFirst45
            Message = if ($hasQueryInFirst45) {
                'Query pattern found within first 45 lines'
            }
            else {
                'No query pattern found within first 45 lines (45-line rule). Expected ```powershell/pwsh block, ServiceName: declaration, or API: declaration.'
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
    $trapLines = $nonCodeLines | Where-Object { $_ -match '>\s*\*\*Trap' }
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

    # --- Scaling parameter: InstanceCount, Quantity, or Cost Formula scaling ---
    # Check 1: ```powershell/pwsh blocks for -InstanceCount/-Quantity (old format)
    # Check 2: Declarative InstanceCount:/Quantity: lines (new format)
    # Check 3: Cost Formula section references scaling (e.g., x instanceCount, x quantity,
    #           x shardCount, x unitCount, x resourceCount, per-unit multipliers, etc.)
    $queryBlockLines = [System.Collections.Generic.List[string]]::new()
    $insidePwshBlock = $false
    foreach ($line in $lines) {
        if ($line -match '(?i)^\s*```(powershell|pwsh)') {
            $insidePwshBlock = $true
            continue
        }
        if ($insidePwshBlock -and $line -match '^\s*```') {
            $insidePwshBlock = $false
            continue
        }
        if ($insidePwshBlock) {
            $queryBlockLines.Add($line)
        }
    }
    # Check PowerShell format: -InstanceCount or -Quantity in code blocks
    $hasScalingParam = @($queryBlockLines | Where-Object { $_ -match '-InstanceCount\b|-Quantity\b' }).Count -gt 0
    # Check declarative format: InstanceCount: or Quantity: on any line
    if (-not $hasScalingParam) {
        $hasScalingParam = @($lines | Where-Object { $_ -match '^\s*(InstanceCount|Quantity)\s*:' }).Count -gt 0
    }
    # Check Cost Formula section for scaling multipliers (x count, per-unit, GB volume, etc.)
    if (-not $hasScalingParam) {
        $inCostFormula = $false
        foreach ($line in $lines) {
            if ($line -match '^#{2}\s+Cost\s+Formula') { $inCostFormula = $true; continue }
            if ($inCostFormula -and $line -match '^##(?!#)\s+') { break }
            if ($inCostFormula -and $line -match "(?i)(\u00D7|x|\*)\s*\w*(count|quantity|instance|gb|tb|unit|shard|replica|node)|per[\s-]+(gb|tb|unit|instance|10k|100k|1m|million|day|hour)|estimat|730\s*(hours|hrs)|monthly\s*=") {
                $hasScalingParam = $true
                break
            }
        }
    }
    $checks.Add(@{
            Name    = 'scaling_parameter'
            Pass    = $hasScalingParam
            Message = if ($hasScalingParam) {
                'Scaling parameter or cost formula multiplier found'
            }
            else {
                'No scaling parameter (InstanceCount/Quantity) or cost formula multiplier found. At least one query or formula must demonstrate how to scale.'
            }
        })

    # --- Line count limit: file must be <= 100 lines ---
    $checks.Add(@{
            Name    = 'line_count_limit'
            Pass    = $lines.Count -le 100
            Message = if ($lines.Count -le 100) {
                "File is $($lines.Count) lines (limit: 100)"
            }
            else {
                "File is $($lines.Count) lines -- exceeds 100-line limit by $($lines.Count - 100) lines"
            }
        })

    # --- Primary cost line: file must contain **Primary cost**: ---
    $hasPrimaryCost = @($lines | Where-Object { $_ -match '^\*\*Primary cost\*\*\s*:' }).Count -gt 0
    $checks.Add(@{
            Name    = 'primary_cost_line'
            Pass    = $hasPrimaryCost
            Message = if ($hasPrimaryCost) { 'Primary cost line found' } else { 'Missing **Primary cost**: line after title' }
        })

    # --- No code fences in Query Pattern section ---
    $codeFenceInQueryPattern = $false
    $inQueryPatternSection = $false
    foreach ($line in $lines) {
        if ($line -match '^##\s+Query\s+Pattern') {
            $inQueryPatternSection = $true
            continue
        }
        if ($inQueryPatternSection -and $line -match '^##(?!#)\s+') {
            $inQueryPatternSection = $false
            continue
        }
        if ($inQueryPatternSection -and $line -match '^\s*```') {
            $codeFenceInQueryPattern = $true
            break
        }
    }
    $checks.Add(@{
            Name    = 'no_code_fences_in_query_pattern'
            Pass    = -not $codeFenceInQueryPattern
            Message = if (-not $codeFenceInQueryPattern) {
                'No code fences in Query Pattern section'
            }
            else {
                'Code fence found in Query Pattern section -- use declarative Key: Value format instead'
            }
        })

    # --- No template instruction comments ---
    $hasTemplateComments = @($lines | Where-Object { $_ -match 'INSTRUCTIONS FOR AUTHORS' -or $_ -match 'DELETE THIS COMMENT BLOCK' }).Count -gt 0
    $checks.Add(@{
            Name    = 'no_template_comments'
            Pass    = -not $hasTemplateComments
            Message = if (-not $hasTemplateComments) {
                'No template instruction comments found'
            }
            else {
                'Found template instruction comments -- delete all <!-- INSTRUCTIONS FOR AUTHORS --> blocks before publishing'
            }
        })

    # --- ServiceName consistency: YAML serviceName must match all ServiceName: declarations ---
    $yamlValue = $null
    if ($fm.Found -and $fm.Fields.ContainsKey('serviceName')) {
        $yamlValue = $fm.Fields['serviceName'].Trim() -replace "^'|'$", ''
    }
    # Check if file uses API: pattern (Global-only services)
    $hasApiLines = @($lines | Where-Object { $_ -match '^\s*API\s*:' }).Count -gt 0
    # Collect ServiceName: lines (excluding HTML comments)
    $serviceNameLines = [System.Collections.Generic.List[object]]::new()
    $insideHtmlComment = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $effective = $line
        if ($insideHtmlComment) {
            if ($effective -match '-->(.*)$') {
                $insideHtmlComment = $false
                $effective = $Matches[1]
            }
            else {
                continue
            }
        }
        # Remove any inline comment that opens and closes on this line
        $effective = $effective -replace '<!--.*?-->', ''
        if ($effective -match '<!--') {
            $insideHtmlComment = $true
            $effective = $effective -replace '<!--.*$', ''
        }
        if ($effective -match '^\s*ServiceName\s*:\s*(.+)$') {
            $serviceNameLines.Add(@{ Value = $Matches[1].Trim(); LineNum = $i + 1 })
        }
    }
    if ($hasApiLines -and $serviceNameLines.Count -eq 0) {
        $checks.Add(@{
                Name    = 'servicename_consistency'
                Pass    = $true
                Message = 'File uses API: pattern -- serviceName consistency check skipped'
            })
    }
    elseif ($serviceNameLines.Count -eq 0 -and -not $hasApiLines) {
        $checks.Add(@{
                Name    = 'servicename_consistency'
                Pass    = $false
                Message = 'No ServiceName: or API: declarations found in file'
            })
    }
    elseif ($null -eq $yamlValue -and $serviceNameLines.Count -gt 0) {
        $checks.Add(@{
                Name    = 'servicename_consistency'
                Pass    = $false
                Message = 'ServiceName: declarations found but YAML serviceName is missing -- cannot verify consistency'
            })
    }
    else {
        $snMismatch = $null
        foreach ($entry in $serviceNameLines) {
            $queryValue = $entry.Value -replace "^'|'$", ''
            if ($queryValue -ne $yamlValue) {
                $snMismatch = @{ QueryValue = $queryValue; LineNum = $entry.LineNum; YamlValue = $yamlValue }
                break
            }
        }
        $checks.Add(@{
                Name    = 'servicename_consistency'
                Pass    = $null -eq $snMismatch
                Message = if ($null -eq $snMismatch) {
                    'All ServiceName declarations match YAML front matter'
                }
                else {
                    "ServiceName '$($snMismatch.QueryValue)' on line $($snMismatch.LineNum) does not match YAML serviceName '$($snMismatch.YamlValue)'"
                }
            })
    }

    # --- Inline aliases: aliases must use inline [...] format, not multi-line YAML ---
    if ($fm.Found -and $fm.Fields.ContainsKey('aliases')) {
        $aliasLineInline = $false
        $fmStarted = $false
        foreach ($line in $lines) {
            if ($line.Trim() -eq '---' -and -not $fmStarted) {
                $fmStarted = $true
                continue
            }
            if ($fmStarted -and $line.Trim() -eq '---') {
                break
            }
            if ($fmStarted -and $line -match '^\s*aliases\s*:') {
                if ($line -match '^\s*aliases\s*:\s*\[') {
                    $aliasLineInline = $true
                }
                break
            }
        }
        $checks.Add(@{
                Name    = 'inline_aliases'
                Pass    = $aliasLineInline
                Message = if ($aliasLineInline) {
                    'Aliases use inline [...] format'
                }
                else {
                    'Aliases must use inline format: aliases: [term1, term2]. Multi-line YAML wastes line budget.'
                }
            })
    }

    # --- Single H1 heading ---
    $h1Count = @($lines | Where-Object { $_ -match '^#\s+[^#]' }).Count
    $checks.Add(@{
            Name    = 'single_h1_heading'
            Pass    = $h1Count -eq 1
            Message = if ($h1Count -eq 1) {
                'Single H1 heading found'
            }
            elseif ($h1Count -eq 0) {
                'No H1 heading found -- file must have a service title'
            }
            else {
                "Found $h1Count H1 headings -- file must have exactly one"
            }
        })

    # --- Warning format: no emoji prefixes in blockquotes ---
    $warnChar = [char]0x26A0  # WARNING SIGN (U+26A0)
    $hasEmojiWarning = @($lines | Where-Object { $_ -match ">\s*$warnChar" }).Count -gt 0
    $checks.Add(@{
            Name    = 'warning_format'
            Pass    = -not $hasEmojiWarning
            Message = if (-not $hasEmojiWarning) {
                'No non-standard warning formats found'
            }
            else {
                "Found $warnChar emoji in blockquote -- use > **Warning**: ... format instead"
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
    throw 'Validation failed. One or more checks did not pass.'
}
else {
    Write-Output 'RESULT: PASS - All checks passed'
}
