<#
.SYNOPSIS
    Validates service reference markdown files against contribution rules.

.DESCRIPTION
    Checks service reference files for YAML front matter, required sections,
    45-line rule compliance, style enforcement, and file placement.
    Returns structured output for CI consumption.

.PARAMETER Path
    One or more paths to service reference markdown files to validate.

.PARAMETER ServicesRoot
    Root directory of the services folder. Used for file placement and alias
    uniqueness checks. Defaults to the standard repo location.

.PARAMETER CheckAliasUniqueness
    When specified, checks for alias collisions across all service files.

.EXAMPLE
    .\Validate-ServiceReference.ps1 -Path services/compute/my-service.md

.EXAMPLE
    .\Validate-ServiceReference.ps1 -Path *.md -CheckAliasUniqueness
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string[]]$Path,

    [string]$ServicesRoot,

    [switch]$CheckAliasUniqueness
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$validationDir = Join-Path -Path $PSScriptRoot -ChildPath 'lib' -AdditionalChildPath 'validation'
. (Join-Path $validationDir 'Get-FrontMatter.ps1')
. (Join-Path $validationDir 'Test-FrontMatter.ps1')
. (Join-Path $validationDir 'Test-DocumentStructure.ps1')
. (Join-Path $validationDir 'Test-StyleCompliance.ps1')
. (Join-Path $validationDir 'Test-ContentRule.ps1')
. (Join-Path $validationDir 'Test-AliasUniqueness.ps1')

function Test-ServiceReference {
    param([string]$FilePath)

    $checks = [System.Collections.Generic.List[object]]::new()
    $fullPath = Resolve-Path -Path $FilePath -ErrorAction SilentlyContinue

    if (-not $fullPath) {
        $checks.Add(@{ Name = 'file_exists'; Pass = $false; Message = "File not found: $FilePath" })
        return $checks
    }

    $lines = @(Get-Content -Path $fullPath)
    $fm = Get-FrontMatter -Lines $lines

    foreach ($c in (Test-FrontMatter -FrontMatter $fm -FilePath $fullPath)) { $checks.Add($c) }
    foreach ($c in (Test-DocumentStructure -Lines $lines)) { $checks.Add($c) }
    foreach ($c in (Test-StyleCompliance -Lines $lines)) { $checks.Add($c) }
    foreach ($c in (Test-ContentRule -Lines $lines -FrontMatter $fm)) { $checks.Add($c) }

    return $checks
}

$allResults = @{}
$hasFailures = $false

foreach ($filePath in $Path) {
    $resolvedPaths = @()
    if ($filePath -match '[*?]') {
        $resolvedPaths = Get-ChildItem -Path $filePath -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName
    }
    else {
        $resolvedPaths = @($filePath)
    }

    foreach ($rp in $resolvedPaths) {
        $checks = Test-ServiceReference -FilePath $rp
        $fileName = Split-Path -Leaf $rp
        $allResults[$fileName] = $checks

        foreach ($check in $checks) {
            $status = if ($check.Pass) { 'PASS' } else { 'FAIL' }
            $icon = if ($check.Pass) { '+' } else { '-' }
            Write-Output "[$icon] $status $fileName :: $($check.Name) - $($check.Message)"
            if (-not $check.Pass) { $hasFailures = $true }
        }
    }
}

if ($CheckAliasUniqueness) {
    $root = if ($ServicesRoot) { $ServicesRoot } else {
        Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'references', 'services'
    }
    if (Test-Path $root) {
        $aliasChecks = Test-AliasUniqueness -RootPath $root
        $allResults['_alias_uniqueness'] = $aliasChecks
        foreach ($check in $aliasChecks) {
            $status = if ($check.Pass) { 'PASS' } else { 'FAIL' }
            $icon = if ($check.Pass) { '+' } else { '-' }
            Write-Output "[$icon] $status alias_check :: $($check.Name) - $($check.Message)"
            if (-not $check.Pass) { $hasFailures = $true }
        }
    }
}

Write-Output ''
if ($hasFailures) {
    Write-Output 'RESULT: FAIL - One or more checks failed'
    throw 'Validation failed. One or more checks did not pass.'
}
else {
    Write-Output 'RESULT: PASS - All checks passed'
}
