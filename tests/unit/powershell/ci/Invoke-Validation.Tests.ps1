# Tests for .github/scripts/validate/Invoke-Validation.ps1
# Validates ChangedOnly, Full, and RoutingSyncOnly modes using a mock
# validator script that logs received parameters to a JSON file.

Describe 'Invoke-Validation' {

    BeforeAll {
        $script:ScriptPath = Join-Path $PSScriptRoot '../../../../.github/scripts/validate/Invoke-Validation.ps1'
    }

    Context 'ChangedOnly mode' {

        Context 'with valid files' {
            BeforeAll {
                $script:ServicesDir = Join-Path $TestDrive 'services'
                New-Item -Path $script:ServicesDir -ItemType Directory -Force
                'content' | Set-Content (Join-Path $script:ServicesDir 'vm.md')
                'content' | Set-Content (Join-Path $script:ServicesDir 'sql.md')

                # Mock validator records received params to a JSON file
                $script:ParamLog = Join-Path $TestDrive 'param-log.json'
                $script:MockValidator = Join-Path $TestDrive 'Mock-Validator.ps1'
                @"
param([string[]]`$Path, [string]`$ServicesRoot,
      [switch]`$CheckAliasUniqueness, [switch]`$CheckAliasRoutingSync,
      [switch]`$CheckBillingNeeds, [switch]`$CheckRoutingFileSync)
@{Path=`$Path; ServicesRoot=`$ServicesRoot;
  CheckAliasUniqueness=`$CheckAliasUniqueness.IsPresent;
  CheckAliasRoutingSync=`$CheckAliasRoutingSync.IsPresent;
  CheckBillingNeeds=`$CheckBillingNeeds.IsPresent;
  CheckRoutingFileSync=`$CheckRoutingFileSync.IsPresent
} | ConvertTo-Json | Set-Content '$($script:ParamLog -replace "\\","/")'
"@ | Set-Content $script:MockValidator

                $changedFiles = @(
                    (Join-Path $script:ServicesDir 'vm.md'),
                    (Join-Path $script:ServicesDir 'sql.md')
                ) -join "`n"

                $script:Output = & $script:ScriptPath -Mode ChangedOnly `
                    -ChangedFiles $changedFiles `
                    -ServicesRoot $script:ServicesDir `
                    -ValidationScript $script:MockValidator
            }

            It 'passes all 4 check flags to the validator' {
                $params = Get-Content $script:ParamLog | ConvertFrom-Json
                $params.CheckAliasUniqueness  | Should -Be $true
                $params.CheckAliasRoutingSync | Should -Be $true
                $params.CheckBillingNeeds     | Should -Be $true
                $params.CheckRoutingFileSync  | Should -Be $true
            }

            It 'passes both changed files' {
                $params = Get-Content $script:ParamLog | ConvertFrom-Json
                @($params.Path).Count | Should -Be 2
            }

            It 'includes the file count in output' {
                ($script:Output -join "`n") | Should -Match 'Validating 2 changed file'
            }
        }

        Context 'with nonexistent files' {
            BeforeAll {
                $script:ServicesDir = Join-Path $TestDrive 'services-missing'
                New-Item -Path $script:ServicesDir -ItemType Directory -Force

                $script:MockValidator = Join-Path $TestDrive 'Mock-NoOp.ps1'
                '' | Set-Content $script:MockValidator

                $changedFiles = "/nonexistent/path/a.md`n/nonexistent/path/b.md"

                $script:Output = & $script:ScriptPath -Mode ChangedOnly `
                    -ChangedFiles $changedFiles `
                    -ServicesRoot $script:ServicesDir `
                    -ValidationScript $script:MockValidator
            }

            It 'reports no files to validate' {
                $script:Output | Should -Match 'No service reference files to validate'
            }
        }

        Context 'with empty ChangedFiles string' {
            BeforeAll {
                $script:ServicesDir = Join-Path $TestDrive 'services-empty'
                New-Item -Path $script:ServicesDir -ItemType Directory -Force

                $script:MockValidator = Join-Path $TestDrive 'Mock-NoOp.ps1'
                '' | Set-Content $script:MockValidator

                $script:Output = & $script:ScriptPath -Mode ChangedOnly `
                    -ChangedFiles '' `
                    -ServicesRoot $script:ServicesDir `
                    -ValidationScript $script:MockValidator
            }

            It 'reports no files to validate' {
                $script:Output | Should -Match 'No service reference files to validate'
            }
        }
    }

    Context 'Full mode' {

        Context 'with .md files in directory' {
            BeforeAll {
                $script:ServicesDir = Join-Path $TestDrive 'full-services'
                New-Item -Path $script:ServicesDir -ItemType Directory -Force
                'a' | Set-Content (Join-Path $script:ServicesDir 'vm.md')
                'b' | Set-Content (Join-Path $script:ServicesDir 'sql.md')
                'c' | Set-Content (Join-Path $script:ServicesDir 'storage.md')

                $script:ParamLog = Join-Path $TestDrive 'full-param-log.json'
                $script:MockValidator = Join-Path $TestDrive 'Mock-FullValidator.ps1'
                @"
param([string[]]`$Path, [string]`$ServicesRoot,
      [switch]`$CheckAliasUniqueness, [switch]`$CheckAliasRoutingSync,
      [switch]`$CheckBillingNeeds, [switch]`$CheckRoutingFileSync)
@{Path=`$Path; ServicesRoot=`$ServicesRoot;
  CheckAliasUniqueness=`$CheckAliasUniqueness.IsPresent;
  CheckAliasRoutingSync=`$CheckAliasRoutingSync.IsPresent;
  CheckBillingNeeds=`$CheckBillingNeeds.IsPresent;
  CheckRoutingFileSync=`$CheckRoutingFileSync.IsPresent
} | ConvertTo-Json | Set-Content '$($script:ParamLog -replace "\\","/")'
"@ | Set-Content $script:MockValidator

                $script:Output = & $script:ScriptPath -Mode Full `
                    -ServicesRoot $script:ServicesDir `
                    -ValidationScript $script:MockValidator
            }

            It 'passes all 4 check flags to the validator' {
                $params = Get-Content $script:ParamLog | ConvertFrom-Json
                $params.CheckAliasUniqueness  | Should -Be $true
                $params.CheckAliasRoutingSync | Should -Be $true
                $params.CheckBillingNeeds     | Should -Be $true
                $params.CheckRoutingFileSync  | Should -Be $true
            }

            It 'discovers all 3 .md files' {
                $params = Get-Content $script:ParamLog | ConvertFrom-Json
                @($params.Path).Count | Should -Be 3
            }

            It 'reports infrastructure validation in output' {
                ($script:Output -join "`n") | Should -Match 'validating all 3 service reference file'
            }
        }

        Context 'with empty directory' {
            BeforeAll {
                $script:ServicesDir = Join-Path $TestDrive 'full-empty'
                New-Item -Path $script:ServicesDir -ItemType Directory -Force

                $script:MockValidator = Join-Path $TestDrive 'Mock-NoOp2.ps1'
                '' | Set-Content $script:MockValidator

                $script:Output = & $script:ScriptPath -Mode Full `
                    -ServicesRoot $script:ServicesDir `
                    -ValidationScript $script:MockValidator
            }

            It 'reports no service reference files found' {
                $script:Output | Should -Match 'No service reference files found'
            }
        }
    }

    Context 'RoutingSyncOnly mode' {

        Context 'with files present' {
            BeforeAll {
                $script:ServicesDir = Join-Path $TestDrive 'routing-services'
                New-Item -Path $script:ServicesDir -ItemType Directory -Force
                'x' | Set-Content (Join-Path $script:ServicesDir 'vm.md')
                'y' | Set-Content (Join-Path $script:ServicesDir 'sql.md')

                $script:ParamLog = Join-Path $TestDrive 'routing-param-log.json'
                $script:MockValidator = Join-Path $TestDrive 'Mock-RoutingValidator.ps1'
                @"
param([string[]]`$Path, [string]`$ServicesRoot,
      [switch]`$CheckAliasUniqueness, [switch]`$CheckAliasRoutingSync,
      [switch]`$CheckBillingNeeds, [switch]`$CheckRoutingFileSync)
@{Path=`$Path; ServicesRoot=`$ServicesRoot;
  CheckAliasUniqueness=`$CheckAliasUniqueness.IsPresent;
  CheckAliasRoutingSync=`$CheckAliasRoutingSync.IsPresent;
  CheckBillingNeeds=`$CheckBillingNeeds.IsPresent;
  CheckRoutingFileSync=`$CheckRoutingFileSync.IsPresent
} | ConvertTo-Json | Set-Content '$($script:ParamLog -replace "\\","/")'
"@ | Set-Content $script:MockValidator

                $script:Output = & $script:ScriptPath -Mode RoutingSyncOnly `
                    -ServicesRoot $script:ServicesDir `
                    -ValidationScript $script:MockValidator
            }

            It 'passes only CheckRoutingFileSync flag' {
                $params = Get-Content $script:ParamLog | ConvertFrom-Json
                $params.CheckRoutingFileSync  | Should -Be $true
                $params.CheckAliasUniqueness  | Should -Be $false
                $params.CheckAliasRoutingSync | Should -Be $false
                $params.CheckBillingNeeds     | Should -Be $false
            }

            It 'passes a single file' {
                $params = Get-Content $script:ParamLog | ConvertFrom-Json
                # RoutingSyncOnly picks one representative file
                @($params.Path).Count | Should -Be 1
            }

            It 'reports which file is used for the check' {
                $script:Output | Should -Match 'Running routing-sync check using:'
            }
        }

        Context 'with empty directory' {
            BeforeAll {
                $script:ServicesDir = Join-Path $TestDrive 'routing-empty'
                New-Item -Path $script:ServicesDir -ItemType Directory -Force

                $script:MockValidator = Join-Path $TestDrive 'Mock-NoOp3.ps1'
                '' | Set-Content $script:MockValidator

                $script:Output = & $script:ScriptPath -Mode RoutingSyncOnly `
                    -ServicesRoot $script:ServicesDir `
                    -ValidationScript $script:MockValidator
            }

            It 'reports skipping routing sync check' {
                $script:Output | Should -Match 'skipping routing sync check'
            }
        }
    }
}
