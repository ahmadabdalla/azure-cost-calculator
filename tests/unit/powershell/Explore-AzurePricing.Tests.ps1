Describe 'Explore-AzurePricing' {

    BeforeAll {
        $script:ScriptPath = Join-Path $PSScriptRoot '../../../skills/azure-cost-calculator/scripts/Explore-AzurePricing.ps1'

        # PS 5.1 ConvertFrom-Json returns a JSON array as a single nested object
        # instead of unwrapping it. Piping through ForEach-Object forces consistent
        # array unwrap on both PS 5.1 and PS 7+.
        function script:ConvertFrom-JsonArray {
            param([string]$Json)
            @($Json | ConvertFrom-Json | ForEach-Object { $_ })
        }
    }

    Context 'ServiceName query' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = @([PSCustomObject]@{
                            serviceName          = 'Virtual Machines'
                            productName          = 'Virtual Machines Dv5 Series'
                            skuName              = 'D2s v5'
                            armSkuName           = 'Standard_D2s_v5'
                            meterName            = 'D2s v5'
                            armRegionName        = 'eastus'
                            retailPrice          = 0.096
                            unitOfMeasure        = '1 Hour'
                            isPrimaryMeterRegion = $true
                        })
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Json 3>$null
            $script:Result = @(script:ConvertFrom-JsonArray ($raw -join "`n"))
        }

        It 'Should return results' {
            $script:Result.Count | Should -BeGreaterThan 0
        }
    }

    Context 'SearchTerm query' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = @([PSCustomObject]@{
                            serviceName          = 'Azure Cache for Redis'
                            productName          = 'Azure Cache for Redis'
                            skuName              = 'C0 Basic'
                            armSkuName           = ''
                            meterName            = 'C0 Cache Instance'
                            armRegionName        = 'eastus'
                            retailPrice          = 0.022
                            unitOfMeasure        = '1 Hour'
                            isPrimaryMeterRegion = $true
                        })
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -SearchTerm 'redis' -OutputFormat Json 3>$null
            $script:Result = @(script:ConvertFrom-JsonArray ($raw -join "`n"))
        }

        It 'Should return results for search term' {
            $script:Result.Count | Should -BeGreaterThan 0
        }
    }

    Context 'Neither ServiceName nor SearchTerm provided' {
        BeforeAll {
            Mock Invoke-RestMethod {}

            $script:AllOutput = & $script:ScriptPath -OutputFormat Json 3>&1
            $script:Warnings = @($script:AllOutput | Where-Object { $_ -is [System.Management.Automation.WarningRecord] })
        }

        It 'Should produce a warning' {
            $script:Warnings.Count | Should -BeGreaterThan 0
        }

        It 'Should warn about providing ServiceName or SearchTerm' {
            ($script:Warnings.Message -join "`n") | Should -Match 'ServiceName'
        }

        It 'Should not call the API' {
            Should -Invoke Invoke-RestMethod -Times 0 -Exactly
        }
    }

    Context 'Deduplication of identical entries' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = @(
                        [PSCustomObject]@{
                            serviceName          = 'Virtual Machines'
                            productName          = 'Virtual Machines Dv5 Series'
                            skuName              = 'D2s v5'
                            armSkuName           = 'Standard_D2s_v5'
                            meterName            = 'D2s v5'
                            armRegionName        = 'eastus'
                            retailPrice          = 0.096
                            unitOfMeasure        = '1 Hour'
                            isPrimaryMeterRegion = $true
                        },
                        [PSCustomObject]@{
                            serviceName          = 'Virtual Machines'
                            productName          = 'Virtual Machines Dv5 Series'
                            skuName              = 'D2s v5'
                            armSkuName           = 'Standard_D2s_v5'
                            meterName            = 'D2s v5'
                            armRegionName        = 'eastus'
                            retailPrice          = 0.096
                            unitOfMeasure        = '1 Hour'
                            isPrimaryMeterRegion = $false
                        },
                        [PSCustomObject]@{
                            serviceName          = 'Virtual Machines'
                            productName          = 'Virtual Machines Dv5 Series'
                            skuName              = 'D4s v5'
                            armSkuName           = 'Standard_D4s_v5'
                            meterName            = 'D4s v5'
                            armRegionName        = 'eastus'
                            retailPrice          = 0.192
                            unitOfMeasure        = '1 Hour'
                            isPrimaryMeterRegion = $true
                        }
                    )
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Json 3>$null
            $script:Result = @(script:ConvertFrom-JsonArray ($raw -join "`n"))
        }

        It 'Should return only distinct combinations' {
            $script:Result.Count | Should -Be 2
        }
    }

    Context 'Top limit caps output' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = @(
                        [PSCustomObject]@{
                            serviceName = 'Virtual Machines'; productName = 'Product A'
                            skuName = 'Sku A'; armSkuName = 'Arm A'; meterName = 'Meter A'
                            armRegionName = 'eastus'; retailPrice = 0.10
                            unitOfMeasure = '1 Hour'; isPrimaryMeterRegion = $true
                        },
                        [PSCustomObject]@{
                            serviceName = 'Virtual Machines'; productName = 'Product B'
                            skuName = 'Sku B'; armSkuName = 'Arm B'; meterName = 'Meter B'
                            armRegionName = 'eastus'; retailPrice = 0.20
                            unitOfMeasure = '1 Hour'; isPrimaryMeterRegion = $true
                        },
                        [PSCustomObject]@{
                            serviceName = 'Virtual Machines'; productName = 'Product C'
                            skuName = 'Sku C'; armSkuName = 'Arm C'; meterName = 'Meter C'
                            armRegionName = 'eastus'; retailPrice = 0.30
                            unitOfMeasure = '1 Hour'; isPrimaryMeterRegion = $true
                        },
                        [PSCustomObject]@{
                            serviceName = 'Virtual Machines'; productName = 'Product D'
                            skuName = 'Sku D'; armSkuName = 'Arm D'; meterName = 'Meter D'
                            armRegionName = 'eastus'; retailPrice = 0.40
                            unitOfMeasure = '1 Hour'; isPrimaryMeterRegion = $true
                        },
                        [PSCustomObject]@{
                            serviceName = 'Virtual Machines'; productName = 'Product E'
                            skuName = 'Sku E'; armSkuName = 'Arm E'; meterName = 'Meter E'
                            armRegionName = 'eastus'; retailPrice = 0.50
                            unitOfMeasure = '1 Hour'; isPrimaryMeterRegion = $true
                        }
                    )
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -Top 3 -OutputFormat Json 3>$null
            $script:Result = @(script:ConvertFrom-JsonArray ($raw -join "`n"))
        }

        It 'Should cap output to Top value' {
            $script:Result.Count | Should -Be 3
        }
    }

    Context 'Json output format' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = @(
                        [PSCustomObject]@{
                            serviceName = 'Virtual Machines'; productName = 'Virtual Machines Dv5 Series'
                            skuName = 'D2s v5'; armSkuName = 'Standard_D2s_v5'; meterName = 'D2s v5'
                            armRegionName = 'eastus'; retailPrice = 0.096
                            unitOfMeasure = '1 Hour'; isPrimaryMeterRegion = $true
                        },
                        [PSCustomObject]@{
                            serviceName = 'Virtual Machines'; productName = 'Virtual Machines Dv5 Series'
                            skuName = 'D4s v5'; armSkuName = 'Standard_D4s_v5'; meterName = 'D4s v5'
                            armRegionName = 'eastus'; retailPrice = 0.192
                            unitOfMeasure = '1 Hour'; isPrimaryMeterRegion = $true
                        }
                    )
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Json 3>$null
            $script:Result = @(script:ConvertFrom-JsonArray ($raw -join "`n"))
        }

        It 'Should include ServiceName in each result' {
            $script:Result | ForEach-Object { $_.ServiceName | Should -Be 'Virtual Machines' }
        }

        It 'Should include SamplePrice in each result' {
            $script:Result | ForEach-Object { $null -ne $_.SamplePrice | Should -BeTrue }
        }

        It 'Should include expected properties' {
            $props = $script:Result[0].PSObject.Properties.Name
            $props | Should -Contain 'ServiceName'
            $props | Should -Contain 'ProductName'
            $props | Should -Contain 'SkuName'
            $props | Should -Contain 'MeterName'
            $props | Should -Contain 'UnitOfMeasure'
            $props | Should -Contain 'SamplePrice'
        }
    }

    Context 'No results from API' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = @()
                    NextPageLink = $null
                }
            }

            $script:AllOutput = & $script:ScriptPath -ServiceName 'NonExistent' -OutputFormat Json 3>&1
            $script:Warnings = @($script:AllOutput | Where-Object { $_ -is [System.Management.Automation.WarningRecord] })
        }

        It 'Should produce warnings about no data' {
            $script:Warnings.Count | Should -BeGreaterThan 0
        }

        It 'Should warn about no results found' {
            ($script:Warnings.Message -join "`n") | Should -Match 'No.*results|No.*data|No.*found'
        }
    }

    Context 'Error handling on API failure' {
        BeforeAll {
            Mock Invoke-RestMethod { throw [System.Net.WebException]::new('Connection refused') }

            $script:AllOutput = & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Json 3>&1
            $script:Warnings = @($script:AllOutput | Where-Object { $_ -is [System.Management.Automation.WarningRecord] })
        }

        It 'Should not throw a terminating error' {
            $script:Warnings | Should -Not -BeNullOrEmpty
        }

        It 'Should warn about API failure' {
            ($script:Warnings.Message -join "`n") | Should -Match 'API request failed'
        }
    }

    Context 'Error handling on HTTP error with Response property' {
        BeforeAll {
            Mock Invoke-RestMethod {
                $ex = [System.Exception]::new('The remote server returned an error: (429) Too Many Requests')
                $ex | Add-Member -NotePropertyName 'Response' -NotePropertyValue ([PSCustomObject]@{ StatusCode = 429 })
                throw $ex
            }

            $script:AllOutput = & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Json 3>&1
            $script:Warnings = @($script:AllOutput | Where-Object { $_ -is [System.Management.Automation.WarningRecord] })
        }

        It 'Should not throw a terminating error' {
            $script:Warnings | Should -Not -BeNullOrEmpty
        }

        It 'Should warn about API error' {
            ($script:Warnings.Message -join "`n") | Should -Match 'API.*error'
        }
    }

    Context 'Error handling rethrows non-HTTP exceptions' {
        BeforeAll {
            Mock Invoke-RestMethod { throw [System.InvalidOperationException]::new('Unexpected failure') }
        }

        It 'Should rethrow the exception' {
            { & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Json 3>$null } | Should -Throw '*Unexpected failure*'
        }
    }
}
