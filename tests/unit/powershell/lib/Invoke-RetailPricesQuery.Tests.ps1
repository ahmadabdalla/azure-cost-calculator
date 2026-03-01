BeforeAll {
    . "$PSScriptRoot/../../../../skills/azure-cost-calculator/scripts/lib/Invoke-RetailPricesQuery.ps1"
}

Describe 'Invoke-RetailPricesQuery' {

    BeforeEach {
        Mock Invoke-RestMethod {}
    }

    Context 'when the API returns a single page of results' {
        It 'should return all items from the response' {
            $items = @(
                [PSCustomObject]@{ retailPrice = 0.10; skuName = 'Standard_D2s_v3' }
                [PSCustomObject]@{ retailPrice = 0.20; skuName = 'Standard_D4s_v3' }
            )
            Mock Invoke-RestMethod {
                [PSCustomObject]@{ Items = $items; NextPageLink = $null }
            }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'Virtual Machines'"

            $result | Should -HaveCount 2
            $result[0].skuName | Should -Be 'Standard_D2s_v3'
            $result[1].skuName | Should -Be 'Standard_D4s_v3'
        }
    }

    Context 'when the API returns multiple pages' {
        It 'should follow NextPageLink and aggregate items' {
            $script:pageCallCount = 0
            Mock Invoke-RestMethod {
                $script:pageCallCount++
                if ($script:pageCallCount -eq 1) {
                    [PSCustomObject]@{
                        Items        = @([PSCustomObject]@{ id = 1 })
                        NextPageLink = 'https://prices.azure.com/api/retail/prices?page=2'
                    }
                }
                else {
                    [PSCustomObject]@{
                        Items        = @([PSCustomObject]@{ id = 2 })
                        NextPageLink = $null
                    }
                }
            }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'Storage'" -MaxItems 200

            $result | Should -HaveCount 2
            $result[0].id | Should -Be 1
            $result[1].id | Should -Be 2
            Should -Invoke Invoke-RestMethod -Times 2 -Exactly
        }
    }

    Context 'when accumulated items exceed MaxItems threshold' {
        It 'should stop pagination but keep all items from fetched pages' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = @(
                        [PSCustomObject]@{ id = 1 }
                        [PSCustomObject]@{ id = 2 }
                        [PSCustomObject]@{ id = 3 }
                    )
                    NextPageLink = 'https://prices.azure.com/api/retail/prices?page=2'
                }
            }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'SQL'" -MaxItems 2

            $result | Should -HaveCount 3
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
        }

        It 'should default MaxItems to 100' {
            $items = 1..100 | ForEach-Object { [PSCustomObject]@{ id = $_ } }
            Mock Invoke-RestMethod {
                [PSCustomObject]@{
                    Items        = $items
                    NextPageLink = 'https://prices.azure.com/api/retail/prices?page=2'
                }
            }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'Cosmos DB'"

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
            $result | Should -HaveCount 100
        }
    }

    Context 'when the API returns empty Items' {
        It 'should return an empty collection' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{ Items = @(); NextPageLink = $null }
            }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'Nonexistent'"

            $result | Should -HaveCount 0
        }

        It 'should handle null Items property' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{ Items = $null; NextPageLink = $null }
            }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'Nonexistent'"

            $result | Should -HaveCount 0
        }
    }

    Context 'when CurrencyCode is specified' {
        It 'should pass the currency code in the URI' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{ Items = @([PSCustomObject]@{ id = 1 }); NextPageLink = $null }
            }

            Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" -CurrencyCode 'EUR'

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri -like '*currencyCode=EUR*'
            }
        }

        It 'should default CurrencyCode to USD' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{ Items = @([PSCustomObject]@{ id = 1 }); NextPageLink = $null }
            }

            Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'"

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri -like '*currencyCode=USD*'
            }
        }
    }

    Context 'when the filter is URL-encoded in the request' {
        It 'should encode the filter parameter' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{ Items = @(); NextPageLink = $null }
            }

            Invoke-RetailPricesQuery -Filter "serviceName eq 'Virtual Machines'"

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri -like '*prices.azure.com/api/retail/prices*' -and
                ($Uri -like '*%27Virtual*Machines%27*' -or $Uri -like "*'Virtual*Machines'*")
            }
        }
    }

    Context 'when Invoke-RestMethod throws an error' {
        It 'should propagate the error' {
            Mock Invoke-RestMethod { throw 'API failure' }

            { Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" } | Should -Throw
        }
    }

    Context 'when Invoke-RestMethod throws an HTTP error' {
        It 'should propagate the HTTP error' {
            Mock Invoke-RestMethod { throw [System.Net.WebException]::new('The remote server returned an error: (500) Internal Server Error.') }

            { Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" } | Should -Throw '*500*'
        }
    }

    Context 'when API returns a null response object' {
        It 'should return an empty collection without error' {
            Mock Invoke-RestMethod { return $null }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'"

            @($result).Count | Should -Be 0
        }
    }
}
