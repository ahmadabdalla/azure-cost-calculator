Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-NonCodeLines.ps1')

function Test-StyleCompliance {
    <#
    .SYNOPSIS
        Validates style rules for service reference files.
    .DESCRIPTION
        Checks for prohibited verified-date annotations, case-sensitive
        header annotations, trap formatting, hardcoded dollar figures in
        traps, and emoji warning formats.
    .PARAMETER Lines
        The full set of file lines to validate.
    .OUTPUTS
        System.Collections.Generic.List[object]
    .EXAMPLE
        Test-StyleCompliance -Lines @(Get-Content -Path 'service.md')
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[object]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $checks = [System.Collections.Generic.List[object]]::new()
    $nonCodeLines = Get-NonCodeLines -Lines $Lines

    # No "verified" dates outside code blocks
    $verifiedPattern = '(?i)\bverified\b.*\d{4}'
    $hasVerifiedDate = @($nonCodeLines | Where-Object { $_ -match $verifiedPattern }).Count -gt 0
    $checks.Add((New-ValidationCheck -Name 'no_verified_dates' -Pass (-not $hasVerifiedDate) `
        -PassMessage 'No "verified" dates found' `
        -FailMessage 'Found "verified" date annotation. Remove all verified dates per style rules.'))

    # No "(case-sensitive)" in headers
    $caseAnnotation = @($Lines | Where-Object { $_ -match '^#+\s+.*\(case-sensitive\)' }).Count -gt 0
    $checks.Add((New-ValidationCheck -Name 'no_case_sensitive_headers' -Pass (-not $caseAnnotation) `
        -PassMessage 'No "(case-sensitive)" annotations in headers' `
        -FailMessage 'Found "(case-sensitive)" in section header. Case-sensitivity is assumed per shared.md.'))

    # Trap format
    $trapLines = $nonCodeLines | Where-Object { $_ -match '>\s*\*\*Trap' }
    $badTraps = @($trapLines | Where-Object { $_ -notmatch '>\s*\*\*Trap\*\*:' -and $_ -notmatch '>\s*\*\*Trap\s*\(.*\)\*\*:' })
    $trapFormatOk = $badTraps.Count -eq 0
    $checks.Add((New-ValidationCheck -Name 'trap_format' -Pass $trapFormatOk `
        -PassMessage 'Trap format is correct' `
        -FailMessage 'Invalid trap format. Use: > **Trap**: ... or > **Trap ({name})**: ...'))

    # No hardcoded dollar figures in trap sections
    $trapSections = [System.Collections.Generic.List[string]]::new()
    $inTrapSection = $false
    foreach ($line in $nonCodeLines) {
        if ($line -match '>\s*\*\*Trap') {
            $inTrapSection = $true
            $trapSections.Add($line)
        }
        elseif ($inTrapSection) {
            if ($line -match '^>\s+') {
                $trapSections.Add($line)
            }
            else {
                $inTrapSection = $false
            }
        }
    }
    $trapsWithDollarFigures = @($trapSections | Where-Object { $_ -match '\$\d+(\.\d+)?' })
    $noDollarFiguresInTraps = $trapsWithDollarFigures.Count -eq 0
    $checks.Add((New-ValidationCheck -Name 'no_hardcoded_prices_in_traps' -Pass $noDollarFiguresInTraps `
        -PassMessage 'No hardcoded dollar figures in trap sections' `
        -FailMessage "Found $($trapsWithDollarFigures.Count) trap line(s) with hardcoded dollar figures (e.g., `$0.00`). Use descriptive text like 'zero price', 'minimal cost', or reference 'retailPrice' instead."))

    # Warning format: no emoji prefixes in blockquotes
    $warnChar = [char]0x26A0
    $hasEmojiWarning = @($Lines | Where-Object { $_ -match "^\s*>\s*$warnChar(\uFE0F)?" }).Count -gt 0
    $checks.Add((New-ValidationCheck -Name 'warning_format' -Pass (-not $hasEmojiWarning) `
        -PassMessage 'No non-standard warning formats found' `
        -FailMessage "Found $warnChar emoji in blockquote -- use > **Warning**: ... format instead"))

    , $checks
}
