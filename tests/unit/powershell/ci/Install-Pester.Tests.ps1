# Tests for .github/scripts/test/Install-Pester.ps1
# Verifies the script installs and imports the correct module versions.

Describe 'Install-Pester' {

    BeforeAll {
        $script:ScriptPath = Join-Path $PSScriptRoot '../../../../.github/scripts/test/Install-Pester.ps1'

        Mock Install-Module { }
        Mock Import-Module { }
        Mock Get-Module {
            @(
                [PSCustomObject]@{ Name = 'Pester'; Version = [version]'5.7.1' },
                [PSCustomObject]@{ Name = 'PSScriptAnalyzer'; Version = [version]'1.24.0' }
            )
        }
        Mock Select-Object { $input }

        . $script:ScriptPath
    }

    It 'installs Pester 5.7.1' {
        Should -Invoke Install-Module -Scope Describe -ParameterFilter {
            $Name -eq 'Pester' -and $RequiredVersion -eq '5.7.1'
        }
    }

    It 'installs PSScriptAnalyzer 1.24.0' {
        Should -Invoke Install-Module -Scope Describe -ParameterFilter {
            $Name -eq 'PSScriptAnalyzer' -and $RequiredVersion -eq '1.24.0'
        }
    }

    It 'uses CurrentUser scope for both modules' {
        Should -Invoke Install-Module -Scope Describe -ParameterFilter { $Scope -eq 'CurrentUser' } -Times 2
    }

    It 'uses -Force flag for both modules' {
        Should -Invoke Install-Module -Scope Describe -ParameterFilter { $Force -eq $true } -Times 2
    }

    It 'imports Pester at the correct version' {
        Should -Invoke Import-Module -Scope Describe -ParameterFilter {
            $Name -eq 'Pester' -and $RequiredVersion -eq '5.7.1'
        }
    }

    It 'imports PSScriptAnalyzer at the correct version' {
        Should -Invoke Import-Module -Scope Describe -ParameterFilter {
            $Name -eq 'PSScriptAnalyzer' -and $RequiredVersion -eq '1.24.0'
        }
    }
}
