#Requires -Version 7.0
<#
.SYNOPSIS
    Runs Pester 5 unit tests for the skill's PowerShell scripts.

.DESCRIPTION
    Entry-point runner that ensures Pester 5 is available, then executes all
    *.Tests.ps1 files under tests/unit/powershell/. Outputs results in the
    requested format (NUnitXml for CI, Detailed for local development).

.PARAMETER OutputFormat
    Pester output verbosity: Detailed (default), Normal, Minimal, None, Diagnostic.

.PARAMETER CIOutputPath
    If specified, writes NUnitXml results to this path for CI consumption.

.EXAMPLE
    pwsh tests/unit/Run-PesterTests.ps1
    # Runs all PowerShell unit tests with Detailed output.

.EXAMPLE
    pwsh tests/unit/Run-PesterTests.ps1 -CIOutputPath results/pester.xml
    # Runs tests and writes NUnit XML report for CI.
#>
[CmdletBinding()]
param(
    [ValidateSet('Detailed', 'Normal', 'Minimal', 'None', 'Diagnostic')]
    [string]$OutputFormat = 'Detailed',

    [string]$CIOutputPath
)

$ErrorActionPreference = 'Stop'

# Ensure Pester 5+ is available
$pester = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version.Major -ge 5 } | Select-Object -First 1
if (-not $pester) {
    Write-Host 'Pester 5 not found. Installing from PSGallery...' -ForegroundColor Yellow
    Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -Scope CurrentUser -SkipPublisherCheck
}
Import-Module Pester -MinimumVersion 5.0.0

# Discover test path
$testRoot = Join-Path $PSScriptRoot 'powershell'

# Build Pester configuration
$config = New-PesterConfiguration
$config.Run.Path = $testRoot
$config.Run.Exit = $true
$config.Output.Verbosity = $OutputFormat

if ($CIOutputPath) {
    $dir = Split-Path $CIOutputPath -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = $CIOutputPath
    $config.TestResult.OutputFormat = 'NUnitXml'
}

# Run
Invoke-Pester -Configuration $config
