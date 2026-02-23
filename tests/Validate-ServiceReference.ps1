#requires -Version 7.0
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

.PARAMETER CheckAliasRoutingSync
    When specified, checks that file aliases are drawn from the routing map.

.EXAMPLE
    .\Validate-ServiceReference.ps1 -Path services/compute/my-service.md

.EXAMPLE
    .\Validate-ServiceReference.ps1 -Path *.md -CheckAliasUniqueness -CheckAliasRoutingSync
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string[]]$Path,

    [string]$ServicesRoot,

    [switch]$CheckAliasUniqueness,

    [switch]$CheckAliasRoutingSync
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
. (Join-Path $validationDir 'Test-AliasRoutingSync.ps1')

function Test-ServiceReference {
    param([string]$FilePath)

    $checks = [System.Collections.Generic.List[object]]::new()
    $fullPath = Resolve-Path -Path $FilePath -ErrorAction SilentlyContinue

    if (-not $fullPath) {
        $checks.Add((New-ValidationCheck -Name 'file_exists' -Pass $false `
            -PassMessage 'n/a' -FailMessage "File not found: $FilePath"))
        return , $checks
    }

    $lines = @(Get-Content -Path $fullPath -Encoding UTF8)
    $fm = Get-FrontMatter -Lines $lines

    foreach ($c in (Test-FrontMatter -FrontMatter $fm -FilePath $fullPath)) { $checks.Add($c) }
    foreach ($c in (Test-DocumentStructure -Lines $lines)) { $checks.Add($c) }
    foreach ($c in (Test-StyleCompliance -Lines $lines)) { $checks.Add($c) }
    foreach ($c in (Test-ContentRule -Lines $lines -FrontMatter $fm)) { $checks.Add($c) }

    , $checks
}

function Write-CheckResult {
    param(
        [string]$FileName,
        [hashtable]$Check
    )
    $status = if ($Check.Pass) { 'PASS' } else { 'FAIL' }
    $icon = if ($Check.Pass) { '+' } else { '-' }
    Write-Output "[$icon] $status $FileName :: $($Check.Name) - $($Check.Message)"
}

$hasFailures = $false

foreach ($filePath in $Path) {
    $resolvedPaths = @()
    if ($filePath -match '[*?]') {
        $resolvedPaths = @(Get-ChildItem -Path $filePath -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName)
        if ($resolvedPaths.Count -eq 0) {
            Write-Warning "No files matched pattern: $filePath"
        }
    }
    else {
        $resolvedPaths = @($filePath)
    }

    foreach ($rp in $resolvedPaths) {
        $checks = Test-ServiceReference -FilePath $rp
        $leaf = Split-Path -Path $rp -Leaf
        $parent = Split-Path -Path (Split-Path -Path $rp -Parent) -Leaf
        $fileName = if ($parent) { "$parent/$leaf" } else { $leaf }

        foreach ($check in $checks) {
            Write-CheckResult -FileName $fileName -Check $check
            if (-not $check.Pass) { $hasFailures = $true }
        }
    }
}

if ($CheckAliasUniqueness) {
    $root = if ($ServicesRoot) { $ServicesRoot } else {
        Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'skills', 'azure-cost-calculator', 'references', 'services'
    }
    if (Test-Path $root) {
        $aliasChecks = Test-AliasUniqueness -RootPath $root
        foreach ($check in $aliasChecks) {
            Write-CheckResult -FileName 'alias_check' -Check $check
            if (-not $check.Pass) { $hasFailures = $true }
        }
    }
}

if ($CheckAliasRoutingSync) {
    $root = if ($ServicesRoot) { $ServicesRoot } else {
        Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'skills', 'azure-cost-calculator', 'references', 'services'
    }
    $routingMapPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'skills', 'azure-cost-calculator', 'references', 'service-routing.md'
    if ((Test-Path $root) -and (Test-Path $routingMapPath)) {
        $syncChecks = Test-AliasRoutingSync -RootPath $root -RoutingMapPath $routingMapPath
        foreach ($check in $syncChecks) {
            Write-CheckResult -FileName 'routing_sync' -Check $check
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
