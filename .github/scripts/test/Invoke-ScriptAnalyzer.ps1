# ---------------------------------------------------------
# Invoke-ScriptAnalyzer.ps1
# ---------------------------------------------------------
# Runs PSScriptAnalyzer against a target path and fails the
# build if any Error or Warning diagnostics are found.
#
# Parameters:
#   -TargetPath  (string, required) -- path to analyze
#
# Exit codes:
#   0 -- no errors or warnings
#   1 -- one or more Error/Warning diagnostics found
# ---------------------------------------------------------

param(
    [Parameter(Mandatory)]
    [string] $TargetPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $TargetPath)) {
    Write-Error "Target path not found: $TargetPath"
    exit 1
}

$results = Invoke-ScriptAnalyzer -Path $TargetPath -Recurse -ReportSummary
$results | Format-Table -AutoSize

if ($results | Where-Object Severity -in 'Error', 'Warning') {
    Write-Error "PSScriptAnalyzer found errors or warnings."
    exit 1
}
