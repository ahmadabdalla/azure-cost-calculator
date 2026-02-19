Set-StrictMode -Version Latest

function Get-FrontMatter {
    <#
    .SYNOPSIS
        Parses YAML front matter from a markdown file's lines.
    .DESCRIPTION
        Reads the supplied lines and extracts YAML front matter delimited
        by --- markers. Returns a hashtable with Found, Fields, and EndLine
        properties. Supports single-line key: value, multi-line bracketed
        lists, and YAML sequence (- item) formats.
    .PARAMETER Lines
        The full set of file lines to parse.
    .OUTPUTS
        hashtable
    .EXAMPLE
        Get-FrontMatter -Lines @('---', 'serviceName: VMs', 'category: compute', '---')
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $result = @{ Found = $false; Fields = @{}; EndLine = 0 }

    if ($Lines.Count -eq 0 -or $Lines[0].Trim() -ne '---') {
        return $result
    }

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

    $frontMatterLines = @()
    if ($result.EndLine -gt 1) {
        $frontMatterLines = $Lines[1..($result.EndLine - 1)]
    }

    $index = 0
    while ($index -lt $frontMatterLines.Count) {
        $line = $frontMatterLines[$index]

        if ($line -match '^\s*([\w-]+)\s*:\s*(.+)$') {
            $key = $Matches[1]
            $value = $Matches[2].Trim()
            $result.Fields[$key] = $value
            $index++
            continue
        }

        # "key:" with no value — consume bracketed list or YAML sequence below it
        if ($line -match '^\s*([\w-]+)\s*:\s*$') {
            $key = $Matches[1]
            $index++

            if ($index -lt $frontMatterLines.Count -and $frontMatterLines[$index] -match '^\s+\[') {
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
            # Normalise to bracket string so downstream sees the same format as inline aliases
            $result.Fields[$key] = '[' + ($items -join ', ') + ']'
            continue
        }

        $index++
    }

    return $result
}
