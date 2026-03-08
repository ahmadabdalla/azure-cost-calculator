# Tests for .github/scripts/test/Invoke-ScriptAnalyzer.ps1
# Runs the analyzer script as a subprocess against crafted PS1 files so that
# `exit 1` in the script under test does not terminate the Pester runner.
# Requires PSScriptAnalyzer to be installed (tests skip gracefully if missing).

Describe 'Invoke-ScriptAnalyzer' {

    BeforeAll {
        $script:ScriptPath = Join-Path $PSScriptRoot '../../../../.github/scripts/test/Invoke-ScriptAnalyzer.ps1'
        $script:HasAnalyzer = $null -ne (Get-Module -ListAvailable PSScriptAnalyzer)
    }

    Context 'clean scripts with no diagnostics' {
        BeforeAll {
            if (-not $script:HasAnalyzer) { return }
            $dir = Join-Path $TestDrive 'clean'
            New-Item $dir -ItemType Directory -Force
            @'
param([string]$Name)
Write-Output "Hello $Name"
'@ | Set-Content (Join-Path $dir 'good.ps1')

            $script:Output = pwsh -NoProfile -File $script:ScriptPath -TargetPath $dir 2>&1
            $script:ExitCode = $LASTEXITCODE
        }

        It 'exits with code 0' -Skip:(-not $script:HasAnalyzer) {
            $script:ExitCode | Should -Be 0
        }
    }

    Context 'scripts with only Information-severity results' {
        BeforeAll {
            if (-not $script:HasAnalyzer) { return }
            $dir = Join-Path $TestDrive 'info-only'
            New-Item $dir -ItemType Directory -Force
            # Trailing whitespace triggers an Information-level rule
            "Write-Output 'hello'   " | Set-Content (Join-Path $dir 'trailing.ps1')

            $script:Output = pwsh -NoProfile -File $script:ScriptPath -TargetPath $dir 2>&1
            $script:ExitCode = $LASTEXITCODE
        }

        It 'exits with code 0 (no Error/Warning)' -Skip:(-not $script:HasAnalyzer) {
            $script:ExitCode | Should -Be 0
        }
    }

    Context 'scripts with Warning diagnostics' {
        BeforeAll {
            if (-not $script:HasAnalyzer) { return }
            $dir = Join-Path $TestDrive 'warn'
            New-Item $dir -ItemType Directory -Force
            # Write-Host triggers PSAvoidUsingWriteHost (Warning severity)
            'Write-Host "bad practice"' | Set-Content (Join-Path $dir 'bad.ps1')

            $script:Output = pwsh -NoProfile -File $script:ScriptPath -TargetPath $dir 2>&1
            $script:ExitCode = $LASTEXITCODE
        }

        It 'exits with code 1' -Skip:(-not $script:HasAnalyzer) {
            $script:ExitCode | Should -Be 1
        }

        It 'output mentions errors or warnings' -Skip:(-not $script:HasAnalyzer) {
            "$($script:Output)" | Should -Match 'errors or warnings'
        }
    }

    Context 'scripts with Error diagnostics' {
        BeforeAll {
            if (-not $script:HasAnalyzer) { return }
            $dir = Join-Path $TestDrive 'error'
            New-Item $dir -ItemType Directory -Force
            # Credential in plaintext triggers PSAvoidUsingPlainTextForPassword (Error/Warning)
            @'
function Get-Data {
    param(
        [string]$Password
    )
    Write-Output $Password
}
'@ | Set-Content (Join-Path $dir 'cred.ps1')

            $script:Output = pwsh -NoProfile -File $script:ScriptPath -TargetPath $dir 2>&1
            $script:ExitCode = $LASTEXITCODE
        }

        It 'exits with code 1' -Skip:(-not $script:HasAnalyzer) {
            $script:ExitCode | Should -Be 1
        }
    }

    Context 'scripts with mixed Information and Warning diagnostics' {
        BeforeAll {
            if (-not $script:HasAnalyzer) { return }
            $dir = Join-Path $TestDrive 'mixed'
            New-Item $dir -ItemType Directory -Force
            # Info-level: trailing whitespace; Warning-level: Write-Host
            @'
Write-Host "bad"
Write-Output 'ok'
'@ | Set-Content (Join-Path $dir 'mixed.ps1')

            $script:Output = pwsh -NoProfile -File $script:ScriptPath -TargetPath $dir 2>&1
            $script:ExitCode = $LASTEXITCODE
        }

        It 'exits with code 1 because of the Warning' -Skip:(-not $script:HasAnalyzer) {
            $script:ExitCode | Should -Be 1
        }
    }
}
