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

        It 'should URL-encode the CurrencyCode to prevent parameter injection' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{ Items = @(); NextPageLink = $null }
            }

            Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" -CurrencyCode 'US&D'

            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri -like '*currencyCode=US%26D*' -and $Uri -notlike '*currencyCode=US&D*'
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
        It 'should propagate non-retryable errors immediately' {
            Mock Invoke-RestMethod { throw 'API failure' }

            { Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" } | Should -Throw
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
        }
    }

    Context 'when Invoke-RestMethod throws an HTTP error' {
        It 'should propagate WebException without Response immediately (no retry)' {
            Mock Invoke-RestMethod { throw [System.Net.WebException]::new('The remote server returned an error: (500) Internal Server Error.') }

            { Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" } | Should -Throw '*500*'
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
        }
    }

    Context 'when API returns a null response object' {
        It 'should return an empty collection without error' {
            Mock Invoke-RestMethod { return $null }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'"

            @($result).Count | Should -Be 0
        }
    }

    Context 'retry with exponential backoff' {
        BeforeAll {
            # Helper to create a WebException with a specific HTTP status code.
            # Handles both legacy .NET Framework (m_StatusCode field) and
            # modern .NET 6+ (_httpResponseMessage field) internals.
            function New-RetryableWebException {
                param([int]$StatusCode, [string]$Message = 'Error')
                $mockResponse = [System.Runtime.Serialization.FormatterServices]::GetUninitializedObject([System.Net.HttpWebResponse])
                $field = [System.Net.HttpWebResponse].GetField('m_StatusCode', [System.Reflection.BindingFlags]'NonPublic,Instance')
                if ($field) {
                    $field.SetValue($mockResponse, $StatusCode)
                }
                else {
                    $field = [System.Net.HttpWebResponse].GetField('_httpResponseMessage', [System.Reflection.BindingFlags]'NonPublic,Instance')
                    if ($field) {
                        $httpMsg = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]$StatusCode)
                        $field.SetValue($mockResponse, $httpMsg)
                    }
                }
                return [System.Net.WebException]::new($Message, $null, [System.Net.WebExceptionStatus]::ProtocolError, $mockResponse)
            }
        }

        BeforeEach {
            Mock Start-Sleep {}
        }

        It 'should retry on HTTP 429 and succeed on later attempt' {
            $script:retryCount = 0
            Mock Invoke-RestMethod {
                $script:retryCount++
                if ($script:retryCount -le 2) {
                    throw (New-RetryableWebException -StatusCode 429 -Message 'Too Many Requests')
                }
                [PSCustomObject]@{ Items = @([PSCustomObject]@{ id = 1 }); NextPageLink = $null }
            }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'"

            $result | Should -HaveCount 1
            Should -Invoke Invoke-RestMethod -Times 3 -Exactly
            Should -Invoke Start-Sleep -Times 2 -Exactly
        }

        It 'should exhaust retries for persistent HTTP 503 errors' {
            Mock Invoke-RestMethod {
                throw (New-RetryableWebException -StatusCode 503 -Message 'Service Unavailable')
            }

            { Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" -MaxRetries 3 } | Should -Throw
            Should -Invoke Invoke-RestMethod -Times 3 -Exactly
            Should -Invoke Start-Sleep -Times 2 -Exactly
        }

        It 'should not retry on HTTP 400 (non-retryable status)' {
            Mock Invoke-RestMethod {
                throw (New-RetryableWebException -StatusCode 400 -Message 'Bad Request')
            }

            { Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" } | Should -Throw
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
            Should -Invoke Start-Sleep -Times 0 -Exactly
        }

        It 'should not retry generic non-web exceptions' {
            Mock Invoke-RestMethod { throw 'Something broke' }

            { Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" } | Should -Throw
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
            Should -Invoke Start-Sleep -Times 0 -Exactly
        }

        It 'should succeed without retries when API responds normally' {
            Mock Invoke-RestMethod {
                [PSCustomObject]@{ Items = @([PSCustomObject]@{ id = 1 }); NextPageLink = $null }
            }

            $result = Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'"

            $result | Should -HaveCount 1
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
            Should -Invoke Start-Sleep -Times 0 -Exactly
        }

        It 'should use exponential delays (2s, 4s) for BaseDelaySeconds=2' {
            $script:sleepCalls = @()
            Mock Start-Sleep { $script:sleepCalls += $Seconds }
            Mock Invoke-RestMethod {
                throw (New-RetryableWebException -StatusCode 429 -Message 'Rate limited')
            }

            { Invoke-RetailPricesQuery -Filter "serviceName eq 'VMs'" -MaxRetries 3 -BaseDelaySeconds 2 } | Should -Throw

            $script:sleepCalls | Should -HaveCount 2
            $script:sleepCalls[0] | Should -Be 2   # 2 * 2^0
            $script:sleepCalls[1] | Should -Be 4   # 2 * 2^1
        }
    }
}
