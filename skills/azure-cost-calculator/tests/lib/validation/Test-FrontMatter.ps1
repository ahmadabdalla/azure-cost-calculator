Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')

function Test-FrontMatter {
    <#
    .SYNOPSIS
        Validates YAML front matter fields and file placement.
    .DESCRIPTION
        Checks that YAML front matter exists, required fields are present,
        aliases are non-empty, category is valid, and the file resides in
        the correct category folder.
    .PARAMETER FrontMatter
        Hashtable returned by Get-FrontMatter (with Found, Fields, EndLine).
    .PARAMETER FilePath
        Path to the service reference file being validated.
    .OUTPUTS
        System.Array
    .EXAMPLE
        Test-FrontMatter -FrontMatter $fm -FilePath 'services/compute/virtual-machines.md'
    #>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$FrontMatter,

        [Parameter(Mandatory)]
        [string]$FilePath
    )

    $config = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'ValidationConfig.psd1')
    $checks = [System.Collections.Generic.List[object]]::new()

    $checks.Add((New-ValidationCheck -Name 'yaml_front_matter' -Pass $FrontMatter.Found `
        -PassMessage 'YAML front matter found' `
        -FailMessage 'Missing YAML front matter (file must start with ---)'))

    if ($FrontMatter.Found) {
        foreach ($field in $config.RequiredFrontMatterFields) {
            $hasField = $FrontMatter.Fields.ContainsKey($field) -and $FrontMatter.Fields[$field].Length -gt 0
            $checks.Add((New-ValidationCheck -Name "frontmatter_$field" -Pass $hasField `
                -PassMessage "$field is present" `
                -FailMessage "Missing required front matter field: $field"))
        }

        # aliases field may be present but empty — require at least one entry
        if ($FrontMatter.Fields.ContainsKey('aliases')) {
            $aliasValue = $FrontMatter.Fields['aliases']
            $parsedAliases = @()
            if ($aliasValue -is [string]) {
                $stripped = $aliasValue -replace '^\[', '' -replace '\]$', ''
                $parsedAliases = @($stripped -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            }
            elseif ($aliasValue -is [System.Collections.IEnumerable]) {
                $parsedAliases = @($aliasValue | ForEach-Object { $_.ToString().Trim() } | Where-Object { $_ })
            }
            $hasAliases = $parsedAliases.Count -gt 0
            $checks.Add((New-ValidationCheck -Name 'aliases_not_empty' -Pass $hasAliases `
                -PassMessage "aliases contains $($parsedAliases.Count) entry(s)" `
                -FailMessage 'aliases field is present but empty - at least one alias is required'))
        }

        if ($FrontMatter.Fields.ContainsKey('category')) {
            $rawCategory = $FrontMatter.Fields['category'].Trim()
            $isValidCategory = $config.ValidCategories -contains $rawCategory
            $checks.Add((New-ValidationCheck -Name 'category_valid' -Pass $isValidCategory `
                -PassMessage "Category '$rawCategory' is valid" `
                -FailMessage "Invalid category '$rawCategory'. Must be one of: $($config.ValidCategories -join ', ')"))
        }

        # File must reside under references/services/<category>/ matching its front matter category
        $fullPath = Resolve-Path -Path $FilePath -ErrorAction SilentlyContinue
        $pathStr = if ($fullPath) { $fullPath.ToString().Replace('\', '/') } else { $FilePath.Replace('\', '/') }
        if ($FrontMatter.Fields.ContainsKey('category')) {
            if ($pathStr -match 'references/services/([^/]+)/') {
                $folderCategory = $Matches[1]
                $expectedCategory = $FrontMatter.Fields['category'].Trim()
                $placementOk = $folderCategory -eq $expectedCategory
                $checks.Add((New-ValidationCheck -Name 'file_placement' -Pass $placementOk `
                    -PassMessage "File is in correct category folder '$folderCategory'" `
                    -FailMessage "File is in '$folderCategory/' but category is '$expectedCategory'"))
            }
            else {
                $checks.Add((New-ValidationCheck -Name 'file_placement' -Pass $false `
                    -PassMessage 'n/a' `
                    -FailMessage "File is not under a 'references/services/<category>/' directory"))
            }
        }
    }

    , $checks
}
