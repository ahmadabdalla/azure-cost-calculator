Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-H2Section.ps1')

function Test-QueryBlockCompleteness {
    <#
    .SYNOPSIS
        Validates that every query block in the Query Pattern section includes ServiceName.
    .DESCRIPTION
        Parses query blocks within the ## Query Pattern section and ensures each
        non-API block contains an explicit ServiceName: declaration. Query blocks
        are self-contained — agents parse them individually and should not rely
        on preambles.
    .PARAMETER Lines
        The full set of file lines to validate.
    .OUTPUTS
        System.Array
    .EXAMPLE
        Test-QueryBlockCompleteness -Lines @(Get-Content -Path 'service.md' -Encoding UTF8)
    #>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $checks = [System.Collections.Generic.List[object]]::new()

    $sections = Get-H2Section -Lines $Lines
    $queryPatternSection = $null
    foreach ($section in $sections) {
        if ($section.Name -match '^Query\s+Pattern') {
            $queryPatternSection = $section
            break
        }
    }

    if ($null -eq $queryPatternSection) {
        $checks.Add((New-ValidationCheck -Name 'query_block_completeness' -Pass $true `
                    -PassMessage 'No Query Pattern section — skipped' `
                    -FailMessage 'n/a'))
    }
    else {
        $contentStartIdx = $queryPatternSection.Line
        $contentEndIdx = $Lines.Count - 1
        foreach ($section in $sections) {
            if ($section.Line -gt $queryPatternSection.Line) {
                $contentEndIdx = $section.Line - 2
                break
            }
        }

        $keyPattern = '^\s*(ServiceName|SkuName|ProductName|MeterName|PriceType|ArmSkuName|Quantity|InstanceCount|Region|Currency|HoursPerMonth|OutputFormat)\s*:'
        $apiPattern = '^\s*API\s*:'
        $serviceNamePattern = '^\s*ServiceName\s*:\s*\S'

        $insideCodeFence = $false
        $insideHtmlComment = $false
        $blocks = [System.Collections.Generic.List[object]]::new()
        $currentBlock = $null

        for ($i = $contentStartIdx; $i -le $contentEndIdx; $i++) {
            $line = $Lines[$i]

            if ($line -match '^\s*```') {
                $insideCodeFence = -not $insideCodeFence
                if ($null -ne $currentBlock) {
                    $blocks.Add($currentBlock)
                    $currentBlock = $null
                }
                continue
            }
            if ($insideCodeFence) { continue }

            if ($insideHtmlComment) {
                if ($line -match '-->') {
                    $insideHtmlComment = $false
                }
                continue
            }
            if ($line -match '<!--') {
                $stripped = $line -replace '<!--.*?-->', ''
                if ($stripped -match '<!--') {
                    if ($null -ne $currentBlock) {
                        $blocks.Add($currentBlock)
                        $currentBlock = $null
                    }
                    $insideHtmlComment = $true
                    continue
                }
                if ([string]::IsNullOrWhiteSpace($stripped)) {
                    if ($null -ne $currentBlock) {
                        $blocks.Add($currentBlock)
                        $currentBlock = $null
                    }
                    continue
                }
                $line = $stripped
            }

            if ([string]::IsNullOrWhiteSpace($line) -or $line -match '^###\s+') {
                if ($null -ne $currentBlock) {
                    $blocks.Add($currentBlock)
                    $currentBlock = $null
                }
                continue
            }

            if ($line -match $apiPattern) {
                if ($null -ne $currentBlock) {
                    $blocks.Add($currentBlock)
                }
                $currentBlock = @{
                    StartLine      = $i + 1
                    FirstLine      = $line.Trim()
                    IsApi          = $true
                    HasServiceName = $false
                }
                continue
            }

            if ($line -match $keyPattern) {
                if ($null -eq $currentBlock) {
                    $currentBlock = @{
                        StartLine      = $i + 1
                        FirstLine      = $line.Trim()
                        IsApi          = $false
                        HasServiceName = $false
                    }
                }
                if ($line -match $serviceNamePattern) {
                    $currentBlock.HasServiceName = $true
                }
            }
        }

        if ($null -ne $currentBlock) {
            $blocks.Add($currentBlock)
        }

        $failedBlocks = [System.Collections.Generic.List[object]]::new()
        foreach ($block in $blocks) {
            if (-not $block.IsApi -and -not $block.HasServiceName) {
                $failedBlocks.Add($block)
            }
        }

        if ($failedBlocks.Count -eq 0) {
            $checks.Add((New-ValidationCheck -Name 'query_block_completeness' -Pass $true `
                        -PassMessage 'All query blocks include ServiceName declaration' `
                        -FailMessage 'n/a'))
        }
        else {
            foreach ($block in $failedBlocks) {
                $checks.Add((New-ValidationCheck -Name 'query_block_completeness' -Pass $false `
                            -PassMessage 'n/a' `
                            -FailMessage "Query block starting at line $($block.StartLine) ('$($block.FirstLine)') is missing ServiceName: declaration"))
            }
        }
    }
    , $checks
}