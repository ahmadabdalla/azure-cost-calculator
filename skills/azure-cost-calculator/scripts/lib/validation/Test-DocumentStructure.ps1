Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')
. (Join-Path $PSScriptRoot 'Get-H2Sections.ps1')

function Test-DocumentStructure {
    <#
    .SYNOPSIS
        Validates required and optional section structure.
    .DESCRIPTION
        Checks that required H2 sections exist, appear in the correct
        relative order, and that optional sections appear after Notes.
    .PARAMETER Lines
        The full set of file lines to validate.
    .OUTPUTS
        System.Collections.Generic.List[object]
    .EXAMPLE
        Test-DocumentStructure -Lines @(Get-Content -Path 'service.md')
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[object]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $config = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'ValidationConfig.psd1')
    $checks = [System.Collections.Generic.List[object]]::new()

    # Required sections must exist as H2
    foreach ($section in $config.RequiredSections) {
        $pattern = "^#{2}\s+$([regex]::Escape($section))\s*$"
        $hasSection = @($Lines | Where-Object { $_ -match $pattern }).Count -gt 0
        $checks.Add((New-ValidationCheck `
            -Name "section_$(($section -replace '\s+', '_').ToLower())" `
            -Pass $hasSection `
            -PassMessage "Section '$section' found" `
            -FailMessage "Missing required section: ## $section"))
    }

    # Extract all H2 headings with their line numbers
    $h2Headings = Get-H2Sections -Lines $Lines

    # Check required sections appear in correct relative order
    $requiredPositions = [System.Collections.Generic.List[object]]::new()
    foreach ($heading in $h2Headings) {
        $orderIndex = [System.Array]::IndexOf($config.RequiredSectionOrder, $heading.Name)
        if ($orderIndex -ge 0) {
            $requiredPositions.Add(@{ Name = $heading.Name; Line = $heading.Line; OrderIndex = $orderIndex })
        }
    }

    $orderingOk = $true
    $orderingMessages = [System.Collections.Generic.List[string]]::new()
    for ($i = 1; $i -lt $requiredPositions.Count; $i++) {
        if ($requiredPositions[$i].OrderIndex -lt $requiredPositions[$i - 1].OrderIndex) {
            $orderingOk = $false
            $orderingMessages.Add(
                "'$($requiredPositions[$i].Name)' (L$($requiredPositions[$i].Line)) appears before '$($requiredPositions[$i - 1].Name)' (L$($requiredPositions[$i - 1].Line)) but should come after it"
            )
        }
    }

    $checks.Add((New-ValidationCheck -Name 'section_order' -Pass $orderingOk `
        -PassMessage 'Required sections are in correct order' `
        -FailMessage ('Section ordering violation: ' + ($orderingMessages -join '; '))))

    # Check optional sections appear after Notes
    $notesLine = $null
    foreach ($heading in $h2Headings) {
        if ($heading.Name -eq 'Notes') {
            $notesLine = $heading.Line
            break
        }
    }

    $optionalBeforeNotes = [System.Collections.Generic.List[string]]::new()
    if ($null -ne $notesLine) {
        foreach ($heading in $h2Headings) {
            if ($config.OptionalSections -contains $heading.Name -and $heading.Line -lt $notesLine) {
                $optionalBeforeNotes.Add("'$($heading.Name)' (L$($heading.Line))")
            }
        }
    }

    $optionalOrderOk = $optionalBeforeNotes.Count -eq 0
    $checks.Add((New-ValidationCheck -Name 'optional_sections_after_notes' -Pass $optionalOrderOk `
        -PassMessage 'All optional sections appear after Notes (or no optional sections present)' `
        -FailMessage ('Optional sections before Notes: ' + ($optionalBeforeNotes -join ', ') + ' — must move after Notes')))

    , $checks
}
