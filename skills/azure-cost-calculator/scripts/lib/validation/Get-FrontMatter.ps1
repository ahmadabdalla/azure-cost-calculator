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
