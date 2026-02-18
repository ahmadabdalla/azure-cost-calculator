Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')

function Test-ContentRule {
    <#
    .SYNOPSIS
        Validates content rules for service reference files.
    .DESCRIPTION
        Checks the 45-line rule, scaling parameters, line count limit,
        primary cost line, code fences in Query Pattern, template comments,
        serviceName consistency, inline alias format, and single H1 heading.
    .PARAMETER Lines
        The full set of file lines to validate.
    .PARAMETER FrontMatter
        Hashtable returned by Get-FrontMatter (with Found, Fields, EndLine).
    .OUTPUTS
        System.Array
    .EXAMPLE
        Test-ContentRule -Lines @(Get-Content -Path 'service.md') -FrontMatter $fm
    #>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string[]]$Lines,

        [Parameter(Mandatory)]
        [hashtable]$FrontMatter
    )

    $config = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'ValidationConfig.psd1')
    $checks = [System.Collections.Generic.List[object]]::new()

    # 45-line rule: query pattern must appear early so the agent finds it quickly
    $deadline = $config.QueryPatternDeadline
    $first45 = @(if ($Lines.Count -ge $deadline) { $Lines[0..($deadline - 1)] } else { $Lines })
    $hasQueryInFirst45 = $false
    for ($i = 0; $i -lt $first45.Count; $i++) {
        if ($first45[$i] -match '(?i)^\s*```(powershell|pwsh)' -or $first45[$i] -match '^\s*ServiceName\s*:' -or $first45[$i] -match '^\s*API\s*:') {
            $hasQueryInFirst45 = $true
            break
        }
    }
    $checks.Add((New-ValidationCheck -Name 'forty_five_line_rule' -Pass $hasQueryInFirst45 `
        -PassMessage 'Query pattern found within first 45 lines' `
        -FailMessage 'No query pattern found within first 45 lines (45-line rule). Expected ```powershell/pwsh block, ServiceName: declaration, or API: declaration.'))

    # At least one query or Cost Formula must show how to scale (InstanceCount/Quantity/multiplier)
    $queryBlockLines = [System.Collections.Generic.List[string]]::new()
    $insidePwshBlock = $false
    foreach ($line in $Lines) {
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
    $hasScalingParam = @($queryBlockLines | Where-Object { $_ -match '-InstanceCount\b|-Quantity\b' }).Count -gt 0
    if (-not $hasScalingParam) {
        $hasScalingParam = @($Lines | Where-Object { $_ -match '^\s*(InstanceCount|Quantity)\s*:' }).Count -gt 0
    }
    if (-not $hasScalingParam) {
        $inCostFormula = $false
        foreach ($line in $Lines) {
            if ($line -match '^#{2}\s+Cost\s+Formula') { $inCostFormula = $true; continue }
            if ($inCostFormula -and $line -match '^##(?!#)\s+') { break }
            if ($inCostFormula -and $line -match "(?i)(\u00D7|x|\*)\s*\w*(count|quantity|instance|gb|tb|unit|shard|replica|node)|per[\s-]+(gb|tb|unit|instance|10k|100k|1m|million|day|hour)|estimat|730\s*(hours|hrs)|monthly\s*=") {
                $hasScalingParam = $true
                break
            }
        }
    }
    $checks.Add((New-ValidationCheck -Name 'scaling_parameter' -Pass $hasScalingParam `
        -PassMessage 'Scaling parameter or cost formula multiplier found' `
        -FailMessage 'No scaling parameter (InstanceCount/Quantity) or cost formula multiplier found. At least one query or formula must demonstrate how to scale.'))

    $maxLines = $config.MaxLineCount
    $checks.Add((New-ValidationCheck -Name 'line_count_limit' -Pass ($Lines.Count -le $maxLines) `
        -PassMessage "File is $($Lines.Count) lines (limit: $maxLines)" `
        -FailMessage "File is $($Lines.Count) lines -- exceeds $($maxLines)-line limit by $($Lines.Count - $maxLines) lines"))

    $hasPrimaryCostBody = @($Lines | Where-Object { $_ -match '^\*\*Primary cost\*\*\s*:' }).Count -gt 0
    $hasPrimaryCostYaml = $FrontMatter.Found -and $FrontMatter.Fields.ContainsKey('primaryCost')
    $hasPrimaryCost = $hasPrimaryCostBody -or $hasPrimaryCostYaml
    $checks.Add((New-ValidationCheck -Name 'primary_cost_line' -Pass $hasPrimaryCost `
        -PassMessage ('Primary cost found' + $(if ($hasPrimaryCostYaml) { ' (YAML frontmatter)' } else { ' (body line)' })) `
        -FailMessage 'Missing primaryCost in YAML frontmatter or **Primary cost**: line in body'))

    # Query Pattern uses declarative Key: Value format, not fenced code blocks
    $codeFenceInQueryPattern = $false
    $inQueryPatternSection = $false
    foreach ($line in $Lines) {
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
    $checks.Add((New-ValidationCheck -Name 'no_code_fences_in_query_pattern' -Pass (-not $codeFenceInQueryPattern) `
        -PassMessage 'No code fences in Query Pattern section' `
        -FailMessage 'Code fence found in Query Pattern section -- use declarative Key: Value format instead'))

    $hasTemplateComments = @($Lines | Where-Object { $_ -match 'INSTRUCTIONS FOR AUTHORS' -or $_ -match 'DELETE THIS COMMENT BLOCK' }).Count -gt 0
    $checks.Add((New-ValidationCheck -Name 'no_template_comments' -Pass (-not $hasTemplateComments) `
        -PassMessage 'No template instruction comments found' `
        -FailMessage 'Found template instruction comments -- delete all <!-- INSTRUCTIONS FOR AUTHORS --> blocks before publishing'))

    # Every ServiceName: in a query must match the YAML serviceName to avoid silent API mismatches
    $yamlValue = $null
    if ($FrontMatter.Found -and $FrontMatter.Fields.ContainsKey('serviceName')) {
        $yamlValue = $FrontMatter.Fields['serviceName'].Trim() -replace "^'|'$", ''
    }
    $hasApiLines = @($Lines | Where-Object { $_ -match '^\s*API\s*:' }).Count -gt 0
    $serviceNameLines = [System.Collections.Generic.List[object]]::new()
    $insideHtmlComment = $false
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i]
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
        $effective = $effective -replace '<!--.*?-->', ''
        if ($effective -match '<!--') {
            $insideHtmlComment = $true
            $effective = $effective -replace '<!--.*$', ''
        }
        if ($effective -match '^\s*ServiceName\s*:\s*(.+)$') {
            # cross-service ServiceName lines are intentionally different from YAML
            if ($Lines[$i] -match '<!--\s*cross-service\s*-->') {
                continue
            }
            # billingNeeds lists services billed under a different serviceName
            if ($FrontMatter.Found -and $FrontMatter.Fields.ContainsKey('billingNeeds')) {
                $rawNeeds = $FrontMatter.Fields['billingNeeds'] -replace '^\[|\]$', ''
                $needsList = $rawNeeds -split ',' | ForEach-Object { $_.Trim() }
                if ($needsList -contains $Matches[1].Trim()) {
                    continue
                }
            }
            $serviceNameLines.Add(@{ Value = $Matches[1].Trim(); LineNum = $i + 1 })
        }
    }
    if ($hasApiLines -and $serviceNameLines.Count -eq 0) {
        $checks.Add((New-ValidationCheck -Name 'servicename_consistency' -Pass $true `
            -PassMessage 'File uses API: pattern -- serviceName consistency check skipped' `
            -FailMessage 'n/a'))
    }
    elseif ($serviceNameLines.Count -eq 0 -and -not $hasApiLines) {
        $checks.Add((New-ValidationCheck -Name 'servicename_consistency' -Pass $false `
            -PassMessage 'n/a' `
            -FailMessage 'No ServiceName: or API: declarations found in file'))
    }
    elseif ($null -eq $yamlValue -and $serviceNameLines.Count -gt 0) {
        $checks.Add((New-ValidationCheck -Name 'servicename_consistency' -Pass $false `
            -PassMessage 'n/a' `
            -FailMessage 'ServiceName: declarations found but YAML serviceName is missing -- cannot verify consistency'))
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
        if ($null -eq $snMismatch) {
            $checks.Add((New-ValidationCheck -Name 'servicename_consistency' -Pass $true `
                -PassMessage 'All ServiceName declarations match YAML front matter' `
                -FailMessage 'n/a'))
        }
        else {
            $checks.Add((New-ValidationCheck -Name 'servicename_consistency' -Pass $false `
                -PassMessage 'n/a' `
                -FailMessage "ServiceName '$($snMismatch.QueryValue)' on line $($snMismatch.LineNum) does not match YAML serviceName '$($snMismatch.YamlValue)'"))
        }
    }

    # Multi-line YAML aliases waste line budget; require inline [term1, term2] format
    if ($FrontMatter.Found -and $FrontMatter.Fields.ContainsKey('aliases')) {
        $aliasLineInline = $false
        $fmStarted = $false
        foreach ($line in $Lines) {
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
        $checks.Add((New-ValidationCheck -Name 'inline_aliases' -Pass $aliasLineInline `
            -PassMessage 'Aliases use inline [...] format' `
            -FailMessage 'Aliases must use inline format: aliases: [term1, term2]. Multi-line YAML wastes line budget.'))
    }

    $h1Count = @($Lines | Where-Object { $_ -match '^#\s+[^#]' }).Count
    if ($h1Count -eq 1) {
        $checks.Add((New-ValidationCheck -Name 'single_h1_heading' -Pass $true `
            -PassMessage 'Single H1 heading found' `
            -FailMessage 'n/a'))
    }
    elseif ($h1Count -eq 0) {
        $checks.Add((New-ValidationCheck -Name 'single_h1_heading' -Pass $false `
            -PassMessage 'n/a' `
            -FailMessage 'No H1 heading found -- file must have a service title'))
    }
    else {
        $checks.Add((New-ValidationCheck -Name 'single_h1_heading' -Pass $false `
            -PassMessage 'n/a' `
            -FailMessage "Found $h1Count H1 headings -- file must have exactly one"))
    }

    , $checks
}
