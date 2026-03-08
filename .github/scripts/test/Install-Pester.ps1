# ---------------------------------------------------------
# Install-Pester.ps1
# ---------------------------------------------------------
# Installs and imports test dependencies for the PowerShell
# unit test job:
#   - Pester         5.7.1   (test framework)
#   - PSScriptAnalyzer 1.24.0 (static analysis)
# ---------------------------------------------------------

$ErrorActionPreference = 'Stop'

Install-Module -Name Pester          -RequiredVersion 5.7.1  -Force -Scope CurrentUser
Install-Module -Name PSScriptAnalyzer -RequiredVersion 1.24.0 -Force -Scope CurrentUser

Import-Module Pester          -RequiredVersion 5.7.1
Import-Module PSScriptAnalyzer -RequiredVersion 1.24.0

Get-Module Pester, PSScriptAnalyzer | Select-Object Name, Version
