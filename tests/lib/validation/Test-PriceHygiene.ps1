Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-NonCodeLine.ps1')
. (Join-Path $PSScriptRoot 'Get-H2Section.ps1')

function Test-PriceHygiene {
    <#
    .SYNOPSIS
        Validates that hardcoded dollar amounts do not appear outside exempt sections.
    .DESCRIPTION
        Scans all lines outside Known Rates, Common SKUs, fenced code blocks,
        and HTML comments for hardcoded prices such as $0.00, $1,234.56,
        USD 10, or 0.50 USD. Prices belong in retailPrice references or
        the Known Rates section.
    .PARAMETER Lines
        The full set of file lines to validate.
    .PARAMETER FrontMatter
        Hashtable returned by Get-FrontMatter (with Found, Fields, EndLine).
    .OUTPUTS
        System.Array
    .EXAMPLE
        Test-PriceHygiene -Lines @(Get-Content -Path 'service.md') -FrontMatter $fm
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'FrontMatter',
        Justification = 'Required by validation harness interface')]
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string[]]$Lines,

        [Parameter(Mandatory)]
        [hashtable]$FrontMatter
    )

    $checks = [System.Collections.Generic.List[object]]::new()
    $sections = Get-H2Section -Lines $Lines

    # Build a set of exempt line ranges (1-based) for Known Rates and Common SKUs
    $exemptRanges = [System.Collections.Generic.List[object]]::new()
    for ($s = 0; $s -lt $sections.Count; $s++) {
        $sectionName = $sections[$s].Name
        if ($sectionName -eq 'Known Rates' -or $sectionName -eq 'Common SKUs') {
            $startLine = $sections[$s].Line
            if ($s + 1 -lt $sections.Count) {
                $endLine = $sections[$s + 1].Line - 1
            }
            else {
                $endLine = $Lines.Count
            }
            $exemptRanges.Add(@{ Start = $startLine; End = $endLine })
        }
    }

    $dollarPattern = '\$\d[\d,]*(\.\d+)?'
    $usdPrefixPattern = 'USD\s+\d'
    $usdSuffixPattern = '\d+\.\d+\s+USD'
    $violations = [System.Collections.Generic.List[string]]::new()
    $insideCodeBlock = $false
    $insideHtmlComment = $false

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $lineNum = $i + 1
        $line = $Lines[$i]

        # Toggle fenced code blocks
        if ($line -match '^\s*```') {
            $insideCodeBlock = -not $insideCodeBlock
            continue
        }
        if ($insideCodeBlock) { continue }

        # Track multi-line HTML comments
        if ($insideHtmlComment) {
            if ($line -match '-->') {
                $insideHtmlComment = $false
            }
            continue
        }
        if ($line -match '<!--.*-->') {
            # Single-line HTML comment — strip it and check remainder
            $effective = $line -replace '<!--.*?-->', ''
        }
        elseif ($line -match '<!--') {
            $insideHtmlComment = $true
            continue
        }
        else {
            $effective = $line
        }

        # Skip exempt sections
        $isExempt = $false
        foreach ($range in $exemptRanges) {
            if ($lineNum -ge $range.Start -and $lineNum -le $range.End) {
                $isExempt = $true
                break
            }
        }
        if ($isExempt) { continue }

        # Skip trap blockquotes — price checks in traps handled by Test-StyleCompliance
        if ($effective -match '^\s*>\s*\*\*Trap') { continue }

        # Check for hardcoded prices
        if ($effective -match $dollarPattern -or
            $effective -match $usdPrefixPattern -or
            $effective -match $usdSuffixPattern) {
            $trimmed = $line.Trim()
            $violations.Add("Hardcoded price found on line ${lineNum}: '${trimmed}'. Use retailPrice references or move to Known Rates.")
        }
    }

    $passed = $violations.Count -eq 0
    if ($passed) {
        $checks.Add((New-ValidationCheck -Name 'no_hardcoded_prices' -Pass $true `
                    -PassMessage 'No hardcoded prices found outside exempt sections' `
                    -FailMessage 'n/a'))
    }
    else {
        foreach ($violation in $violations) {
            $checks.Add((New-ValidationCheck -Name 'no_hardcoded_prices' -Pass $false `
                        -PassMessage 'n/a' `
                        -FailMessage $violation))
        }
    }
    , $checks
}