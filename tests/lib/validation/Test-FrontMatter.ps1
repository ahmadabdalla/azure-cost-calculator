Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')

function Test-FrontMatter {
    <#
    .SYNOPSIS
        Validates YAML front matter fields and file placement.
    .DESCRIPTION
        Checks that YAML front matter exists, required fields are present,
        aliases are non-empty, category is valid, file resides in the correct
        category folder, and B+ schema fields conform to type/enum/length
        constraints defined in frontmatter-schema.psd1.
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
    $schemaPath = Join-Path $PSScriptRoot '..' -AdditionalChildPath '..', 'schema', 'frontmatter-schema.psd1'
    $schema = Import-PowerShellDataFile -Path $schemaPath
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
            if ($pathStr -match $config.ServicesFolderPattern) {
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

        # ── B+ schema field validation ──────────────────────────────────
        # Validate optional fields when present: type, enum, and length constraints

        foreach ($fieldName in $schema.Fields.Keys) {
            $fieldDef = $schema.Fields[$fieldName]

            # Skip fields already handled above or not present
            if ($fieldName -in @('serviceName', 'category', 'aliases')) { continue }
            if (-not $FrontMatter.Fields.ContainsKey($fieldName)) { continue }

            $rawValue = $FrontMatter.Fields[$fieldName].Trim() -replace '^[''"]', '' -replace '[''"]$', ''

            # Type: boolean — must be 'true' or 'false'
            if ($fieldDef.Type -eq 'boolean') {
                $isValidBool = $rawValue -in @('true', 'false')
                $checks.Add((New-ValidationCheck -Name "frontmatter_${fieldName}_type" -Pass $isValidBool `
                            -PassMessage "$fieldName is a valid boolean ('$rawValue')" `
                            -FailMessage "$fieldName must be 'true' or 'false', got '$rawValue'"))
            }

            # MaxLength constraint (e.g., primaryCost ≤ 120 chars)
            if ($fieldDef.ContainsKey('MaxLength')) {
                $valueLength = $rawValue.Length
                $maxLen = $fieldDef.MaxLength
                $lengthOk = $valueLength -le $maxLen
                $checks.Add((New-ValidationCheck -Name "frontmatter_${fieldName}_length" -Pass $lengthOk `
                            -PassMessage "$fieldName is $valueLength chars (limit: $maxLen)" `
                            -FailMessage "$fieldName is $valueLength chars — exceeds $maxLen-char limit"))
            }

            # AllowedValues enum constraint (e.g., pricingRegion)
            if ($fieldDef.ContainsKey('AllowedValues') -and $fieldDef.Type -ne 'array') {
                $isAllowed = $fieldDef.AllowedValues -contains $rawValue
                $checks.Add((New-ValidationCheck -Name "frontmatter_${fieldName}_enum" -Pass $isAllowed `
                            -PassMessage "$fieldName '$rawValue' is a valid value" `
                            -FailMessage "$fieldName '$rawValue' is not valid. Must be one of: $($fieldDef.AllowedValues -join ', ')"))
            }

            # AllowedValues for array fields (e.g., billingConsiderations)
            if ($fieldDef.ContainsKey('AllowedValues') -and $fieldDef.Type -eq 'array') {
                $stripped = $rawValue -replace '^\[', '' -replace '\]$', ''
                $items = @($stripped -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
                $invalidItems = @($items | Where-Object { $fieldDef.AllowedValues -notcontains $_ })
                $allValid = $invalidItems.Count -eq 0
                $checks.Add((New-ValidationCheck -Name "frontmatter_${fieldName}_values" -Pass $allValid `
                            -PassMessage "$fieldName values are all valid" `
                            -FailMessage "$fieldName contains invalid value(s): $($invalidItems -join ', '). Allowed: $($fieldDef.AllowedValues -join ', ')"))
            }
        }
    }

    , $checks
}
