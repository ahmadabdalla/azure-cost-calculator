BeforeAll {
    . "$PSScriptRoot/../../../../skills/azure-cost-calculator/scripts/lib/Build-ODataFilter.ps1"
}

Describe 'Build-ODataFilter' {

    Context 'when given a single equality filter' {
        It 'should return a single eq clause' {
            $filters = [ordered]@{ serviceName = 'Virtual Machines' }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "serviceName eq 'Virtual Machines'"
        }
    }

    Context 'when given multiple equality filters' {
        It 'should join clauses with and' {
            $filters = [ordered]@{
                serviceName   = 'Virtual Machines'
                armRegionName = 'eastus'
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "serviceName eq 'Virtual Machines' and armRegionName eq 'eastus'"
        }

        It 'should preserve insertion order of keys' {
            $filters = [ordered]@{
                armRegionName = 'westus'
                serviceName   = 'Storage'
                skuName       = 'Standard_LRS'
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "armRegionName eq 'westus' and serviceName eq 'Storage' and skuName eq 'Standard_LRS'"
        }
    }

    Context 'when filters contain null or empty values' {
        It 'should skip keys with null values' {
            $filters = [ordered]@{
                serviceName   = 'Virtual Machines'
                armRegionName = $null
                skuName       = 'Standard_D2s_v3'
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "serviceName eq 'Virtual Machines' and skuName eq 'Standard_D2s_v3'"
        }

        It 'should skip keys with empty string values' {
            $filters = [ordered]@{
                serviceName   = ''
                armRegionName = 'eastus'
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "armRegionName eq 'eastus'"
        }

        It 'should return empty string when all values are null' {
            $filters = [ordered]@{
                serviceName   = $null
                armRegionName = $null
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'when filters contain a contains clause' {
        It 'should produce a single contains expression' {
            $filters = [ordered]@{
                contains = @(
                    @{ Field = 'meterName'; Value = 'Spot' }
                )
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "contains(tolower(meterName), 'spot')"
        }

        It 'should produce multiple contains expressions joined with and' {
            $filters = [ordered]@{
                contains = @(
                    @{ Field = 'meterName'; Value = 'Spot' }
                    @{ Field = 'skuName'; Value = 'Standard' }
                )
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "contains(tolower(meterName), 'spot') and contains(tolower(skuName), 'standard')"
        }

        It 'should combine contains with equality filters' {
            $filters = [ordered]@{
                serviceName   = 'Virtual Machines'
                contains      = @(
                    @{ Field = 'meterName'; Value = 'Spot' }
                )
                armRegionName = 'eastus'
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "serviceName eq 'Virtual Machines' and contains(tolower(meterName), 'spot') and armRegionName eq 'eastus'"
        }
    }

    Context 'when values contain special characters' {
        It 'should include apostrophes as-is in the value' {
            $filters = [ordered]@{ skuName = "Dadsv5 Type1" }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "skuName eq 'Dadsv5 Type1'"
        }

        It 'should not mangle values with spaces' {
            $filters = [ordered]@{ productName = 'Azure App Service Basic Plan' }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "productName eq 'Azure App Service Basic Plan'"
        }

        It 'should escape apostrophes in contains values for OData' {
            $filters = [ordered]@{
                contains = @(
                    @{ Field = 'meterName'; Value = "it's" }
                )
            }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "contains(tolower(meterName), 'it''s')"
        }

        It 'should escape apostrophes in equality values for OData' {
            $filters = [ordered]@{ serviceName = "App Service's Plan" }
            $result = Build-ODataFilter -Filters $filters
            $result | Should -Be "serviceName eq 'App Service''s Plan'"
        }
    }

    Context 'when given an empty ordered dictionary' {
        It 'should return an empty string' {
            $filters = [ordered]@{}
            $result = Build-ODataFilter -Filters $filters
            $result | Should -BeNullOrEmpty
        }
    }
}
