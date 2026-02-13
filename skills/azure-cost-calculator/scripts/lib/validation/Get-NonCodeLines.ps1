Set-StrictMode -Version Latest

function Get-NonCodeLines {
    <#
    .SYNOPSIS
        Returns lines that are outside fenced code blocks.
    .DESCRIPTION
        Iterates through the supplied lines and excludes any that fall
        inside triple-backtick fenced code blocks. Fence markers
        themselves are also excluded.
    .PARAMETER Lines
        The full set of file lines to filter.
    .OUTPUTS
        System.Collections.Generic.List[string]
    .EXAMPLE
        Get-NonCodeLines -Lines @('hello', '```', 'code', '```', 'world')
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[string]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $result = [System.Collections.Generic.List[string]]::new()
    $insideCodeBlock = $false

    foreach ($line in $Lines) {
        if ($line -match '^\s*```') {
            $insideCodeBlock = -not $insideCodeBlock
            continue
        }
        if (-not $insideCodeBlock) {
            $result.Add($line)
        }
    }

    , $result
}
