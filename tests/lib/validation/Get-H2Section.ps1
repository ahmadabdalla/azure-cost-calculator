Set-StrictMode -Version Latest

function Get-H2Section {
    <#
    .SYNOPSIS
        Parses H2 headings and their 1-based line numbers.
    .DESCRIPTION
        Scans the supplied lines for Markdown H2 headings (## ...)
        and returns a list of objects with Name and Line properties.
    .PARAMETER Lines
        The full set of file lines to scan.
    .OUTPUTS
        System.Array
    .EXAMPLE
        Get-H2Section -Lines @('# Title', '## Section One', 'text', '## Section Two')
    #>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $sections = [System.Collections.Generic.List[object]]::new()
    $insideCodeBlock = $false

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^\s*```') {
            $insideCodeBlock = -not $insideCodeBlock
            continue
        }
        if (-not $insideCodeBlock -and $Lines[$i] -match '^##\s+(.+?)\s*$') {
            $sections.Add(@{ Name = $Matches[1]; Line = $i + 1 })
        }
    }

    , $sections
}
