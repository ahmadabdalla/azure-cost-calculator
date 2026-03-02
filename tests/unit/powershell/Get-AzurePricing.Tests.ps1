Describe 'Get-AzurePricing' {

    BeforeAll {
        $script:ScriptPath = Join-Path $PSScriptRoot '../../../skills/azure-cost-calculator/scripts/Get-AzurePricing.ps1'
    }

    Context 'Single region consumption pricing' {
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
                            currencyCode         = 'USD'
                            type                 = 'Consumption'
                            isPrimaryMeterRegion = $true
                            tierMinimumUnits     = 0
                            reservationTerm      = $null
                        })
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -ArmSkuName 'Standard_D2s_v5' -OutputFormat Json 3>$null
            $script:Result = ($raw -join "`n") | ConvertFrom-Json
        }

        It 'Should calculate MonthlyCost as unitPrice times 730' {
            $script:Result.results[0].MonthlyCost | Should -Be 70.08
        }

        It 'Should return eastus as Region' {
            $script:Result.results[0].Region | Should -Be 'eastus'
        }

        It 'Should return exactly one result' {
            $script:Result.totalItems | Should -Be 1
        }

        It 'Should set PriceType to Consumption' {
            $script:Result.results[0].PriceType | Should -Be 'Consumption'
        }

    }

    Context 'Multi-region pricing' {
        BeforeAll {
            $script:MultiRegionCallCount = 0
            Mock Invoke-RestMethod {
                $script:MultiRegionCallCount++
                $regions = @('eastus', 'westeurope')
                $idx = [math]::Min($script:MultiRegionCallCount - 1, $regions.Count - 1)
                $region = $regions[$idx]
                [PSCustomObject]@{
                    Items        = @([PSCustomObject]@{
                            serviceName          = 'Virtual Machines'
                            productName          = 'Virtual Machines Dv5 Series'
                            skuName              = 'D2s v5'
                            armSkuName           = 'Standard_D2s_v5'
                            meterName            = 'D2s v5'
                            armRegionName        = $region
                            retailPrice          = 0.096
                            unitOfMeasure        = '1 Hour'
                            currencyCode         = 'USD'
                            type                 = 'Consumption'
                            isPrimaryMeterRegion = $true
                            tierMinimumUnits     = 0
                            reservationTerm      = $null
                        })
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -Region 'eastus', 'westeurope' -OutputFormat Json 3>$null
            $script:Result = ($raw -join "`n") | ConvertFrom-Json
        }

        It 'Should return results for both regions' {
            $script:Result.totalItems | Should -Be 2
        }

        It 'Should include eastus' {
            $script:Result.results.Region | Should -Contain 'eastus'
        }

        It 'Should include westeurope' {
            $script:Result.results.Region | Should -Contain 'westeurope'
        }
    }

    Context 'Reservation pricing with 1 Year term' {
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
                            retailPrice          = 600.0
                            unitOfMeasure        = '1 Hour'
                            currencyCode         = 'USD'
                            type                 = 'Reservation'
                            isPrimaryMeterRegion = $true
                            tierMinimumUnits     = 0
                            reservationTerm      = '1 Year'
                        })
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -PriceType Reservation -OutputFormat Json 3>$null
            $script:Result = ($raw -join "`n") | ConvertFrom-Json
        }

        It 'Should calculate MonthlyCost as retailPrice divided by 12' {
            $script:Result.results[0].MonthlyCost | Should -Be 50.0
        }

        It 'Should set ReservationTerm to 1 Year' {
            $script:Result.results[0].ReservationTerm | Should -Be '1 Year'
        }
    }

    Context 'Quantity parameter' {
        BeforeAll {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = @([PSCustomObject]@{
                            serviceName          = 'Storage'
                            productName          = 'Blob Storage'
                            skuName              = 'Hot LRS'
                            armSkuName           = ''
                            meterName            = 'Data Stored'
                            armRegionName        = 'eastus'
                            retailPrice          = 0.018
                            unitOfMeasure        = '1 GB/Month'
                            currencyCode         = 'USD'
                            type                 = 'Consumption'
                            isPrimaryMeterRegion = $true
                            tierMinimumUnits     = 0
                            reservationTerm      = $null
                        })
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Storage' -Quantity 100 -OutputFormat Json 3>$null
            $script:Result = ($raw -join "`n") | ConvertFrom-Json
        }

        It 'Should multiply quantity into MonthlyCost' {
            $script:Result.results[0].MonthlyCost | Should -Be 1.8
        }

        It 'Should report Quantity as 100' {
            $script:Result.results[0].Quantity | Should -Be 100
        }

        It 'Should mark QuantitySpecified as true' {
            $script:Result.results[0].QuantitySpecified | Should -BeTrue
        }
    }

    Context 'InstanceCount parameter' {
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
                            currencyCode         = 'USD'
                            type                 = 'Consumption'
                            isPrimaryMeterRegion = $true
                            tierMinimumUnits     = 0
                            reservationTerm      = $null
                        })
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -InstanceCount 3 -OutputFormat Json 3>$null
            $script:Result = ($raw -join "`n") | ConvertFrom-Json
        }

        It 'Should multiply InstanceCount into MonthlyCost' {
            $script:Result.results[0].MonthlyCost | Should -Be 210.24
        }

        It 'Should report InstanceCount as 3' {
            $script:Result.results[0].InstanceCount | Should -Be 3
        }
    }

    Context 'Deduplication prefers isPrimaryMeterRegion' {
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
                            currencyCode         = 'USD'
                            type                 = 'Consumption'
                            isPrimaryMeterRegion = $true
                            tierMinimumUnits     = 0
                            reservationTerm      = $null
                        },
                        [PSCustomObject]@{
                            serviceName          = 'Virtual Machines'
                            productName          = 'Virtual Machines Dv5 Series'
                            skuName              = 'D2s v5'
                            armSkuName           = 'Standard_D2s_v5'
                            meterName            = 'D2s v5'
                            armRegionName        = 'eastus'
                            retailPrice          = 0.100
                            unitOfMeasure        = '1 Hour'
                            currencyCode         = 'USD'
                            type                 = 'Consumption'
                            isPrimaryMeterRegion = $false
                            tierMinimumUnits     = 0
                            reservationTerm      = $null
                        }
                    )
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Json 3>$null
            $script:Result = ($raw -join "`n") | ConvertFrom-Json
        }

        It 'Should return only one result after deduplication' {
            $script:Result.totalItems | Should -Be 1
        }

        It 'Should keep the primary meter region item' {
            $script:Result.results[0].UnitPrice | Should -Be 0.096
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

        It 'Should warn about no pricing data found' {
            ($script:Warnings.Message -join "`n") | Should -Match 'No pricing data found'
        }
    }

    Context 'Json output format structure' {
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
                            currencyCode         = 'USD'
                            type                 = 'Consumption'
                            isPrimaryMeterRegion = $true
                            tierMinimumUnits     = 0
                            reservationTerm      = $null
                        })
                    NextPageLink = $null
                }
            }

            $raw = & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Json 3>$null
            $script:Result = ($raw -join "`n") | ConvertFrom-Json
        }

        It 'Should have query property with serviceName' {
            $script:Result.query.serviceName | Should -Be 'Virtual Machines'
        }

        It 'Should have results array' {
            @($script:Result.results).Count | Should -BeGreaterThan 0
        }

        It 'Should have totalItems matching results count' {
            $script:Result.totalItems | Should -Be @($script:Result.results).Count
        }

        It 'Should have summary with min, max, and total cost' {
            $script:Result.summary.minMonthlyCost | Should -Be 70.08
            $script:Result.summary.maxMonthlyCost | Should -Be 70.08
            $script:Result.summary.totalMonthlyCost | Should -Be 70.08
        }
    }

    Context 'Summary output format' {
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
                            currencyCode         = 'USD'
                            type                 = 'Consumption'
                            isPrimaryMeterRegion = $true
                            tierMinimumUnits     = 0
                            reservationTerm      = $null
                        })
                    NextPageLink = $null
                }
            }

            $script:InfoOutput = & $script:ScriptPath -ServiceName 'Virtual Machines' -OutputFormat Summary 3>$null 6>&1
            $script:InfoText = $script:InfoOutput | Out-String
        }

        It 'Should include Azure Pricing Estimate header' {
            $script:InfoText | Should -Match 'Azure Pricing Estimate'
        }

        It 'Should include TOTAL ESTIMATED MONTHLY line' {
            $script:InfoText | Should -Match 'TOTAL ESTIMATED MONTHLY'
        }

        It 'Should include the service name' {
            $script:InfoText | Should -Match 'Virtual Machines'
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
