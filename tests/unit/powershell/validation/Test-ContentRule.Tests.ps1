Describe 'Test-ContentRule' {

    BeforeAll {
        $validationRoot = Join-Path $PSScriptRoot '../../../lib/validation'
        . (Join-Path $validationRoot 'Get-FrontMatter.ps1')
        . (Join-Path $validationRoot 'Test-ContentRule.ps1')
        $validationConfig = Import-PowerShellDataFile -Path (Join-Path $validationRoot 'ValidationConfig.psd1')
        $emptyFrontMatter = @{ Found = $false; Fields = @{} }

        function New-ServiceReferenceLines {
            param(
                [string[]]$ExtraFrontMatter = @(),
                [string[]]$QueryLines = @()
            )

            @(
                '---'
                'serviceName: Display Service'
                'category: compute'
                'aliases: [Display Service]'
            ) + $ExtraFrontMatter + @(
                'primaryCost: "Hourly rate times quantity"'
                '---'
                '# Display Service'
                ''
                '## Query Pattern'
            ) + $QueryLines + @(
                'Quantity: 1'
                ''
                '## Cost Formula'
                'Monthly = retailPrice * Quantity'
                ''
                '## Notes'
                '- Test note'
            )
        }

        function Invoke-ServiceNameConsistencyCheck {
            param(
                [string[]]$ExtraFrontMatter = @(),
                [string[]]$QueryLines = @()
            )

            $lines = New-ServiceReferenceLines -ExtraFrontMatter $ExtraFrontMatter -QueryLines $QueryLines
            $frontMatter = Get-FrontMatter -Lines $lines
            $checks = Test-ContentRule -Lines $lines -FrontMatter $frontMatter

            foreach ($check in $checks) {
                if ($check.Name -eq 'servicename_consistency') {
                    return $check
                }
            }
        }

    }

    It 'passes when ServiceName matches serviceName' {
        $check = Invoke-ServiceNameConsistencyCheck -QueryLines @('ServiceName: Display Service')

        $check.Pass | Should -BeTrue
    }

    It 'passes when ServiceName matches apiServiceName' {
        $check = Invoke-ServiceNameConsistencyCheck `
            -ExtraFrontMatter @('apiServiceName: API Service') `
            -QueryLines @('ServiceName: API Service')

        $check.Pass | Should -BeTrue
    }

    It 'passes when ServiceName matches queryServiceNames' {
        $check = Invoke-ServiceNameConsistencyCheck `
            -ExtraFrontMatter @('queryServiceNames: [Extra Service, Another Service]') `
            -QueryLines @('ServiceName: Another Service')

        $check.Pass | Should -BeTrue
    }

    It 'keeps allowing ServiceName values declared in billingNeeds' {
        $check = Invoke-ServiceNameConsistencyCheck `
            -ExtraFrontMatter @('billingNeeds: [Dependency Service]') `
            -QueryLines @('ServiceName: Dependency Service')

        $check.Pass | Should -BeTrue
    }

    It 'fails when ServiceName is not declared in front matter service metadata' {
        $check = Invoke-ServiceNameConsistencyCheck -QueryLines @('ServiceName: Unknown Service')

        $check.Pass | Should -BeFalse
        $check.Message | Should -Match 'Unknown Service'
    }

    It 'does not treat the old cross-service comment as an override' {
        $oldMarker = '<' + '!-- cross-service --' + '>'
        $check = Invoke-ServiceNameConsistencyCheck -QueryLines @("ServiceName: Unknown Service $oldMarker")

        $check.Pass | Should -BeFalse
        $check.Message | Should -Match 'Unknown Service'
    }

    It 'allows a file at the configured line-count limit' {
        $checks = Test-ContentRule -Lines (@('') * $validationConfig.MaxLineCount) -FrontMatter $emptyFrontMatter
        $check = $checks | Where-Object Name -eq 'line_count_limit'

        $check.Pass | Should -BeTrue
    }

    It 'rejects a file above the configured line-count limit' {
        $checks = Test-ContentRule -Lines (@('') * ($validationConfig.MaxLineCount + 1)) -FrontMatter $emptyFrontMatter
        $check = $checks | Where-Object Name -eq 'line_count_limit'

        $check.Pass | Should -BeFalse
    }

    It 'accepts a direct API URL that passes a non-empty currencyCode' {
        $url = 'API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq ''Azure DNS''&currencyCode={currencyCode}'
        $lines = New-ServiceReferenceLines -QueryLines @($url)
        $checks = Test-ContentRule -Lines $lines -FrontMatter (Get-FrontMatter -Lines $lines)
        $check = $checks | Where-Object Name -eq 'api_url_currency_code'

        $check.Pass | Should -BeTrue
    }

    It 'rejects a direct API URL that omits currencyCode' {
        $url = 'API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq ''Azure DNS'''
        $lines = New-ServiceReferenceLines -QueryLines @($url)
        $checks = Test-ContentRule -Lines $lines -FrontMatter (Get-FrontMatter -Lines $lines)
        $check = $checks | Where-Object Name -eq 'api_url_currency_code'

        $check.Pass | Should -BeFalse
    }

    It 'rejects a direct API URL whose currencyCode is empty' {
        $url = 'API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq ''Azure DNS''&currencyCode='
        $lines = New-ServiceReferenceLines -QueryLines @($url)
        $checks = Test-ContentRule -Lines $lines -FrontMatter (Get-FrontMatter -Lines $lines)
        $check = $checks | Where-Object Name -eq 'api_url_currency_code'

        $check.Pass | Should -BeFalse
    }

    It 'rejects a currencyCode buried inside the $filter clause' {
        $url = 'API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq ''Azure DNS'' and currencyCode eq ''EUR'''
        $lines = New-ServiceReferenceLines -QueryLines @($url)
        $checks = Test-ContentRule -Lines $lines -FrontMatter (Get-FrontMatter -Lines $lines)
        $check = $checks | Where-Object Name -eq 'api_url_currency_code'

        $check.Pass | Should -BeFalse
    }

    It 'checks Retail Prices query URLs even without an API: prefix' {
        $url = 'See https://prices.azure.com/api/retail/prices?$filter=serviceName eq ''Azure DNS'''
        $lines = New-ServiceReferenceLines -QueryLines @('ServiceName: Display Service', $url)
        $checks = Test-ContentRule -Lines $lines -FrontMatter (Get-FrontMatter -Lines $lines)
        $check = $checks | Where-Object Name -eq 'api_url_currency_code'

        $check.Pass | Should -BeFalse
    }

    It 'skips the currencyCode check for files with no direct API URLs' {
        $lines = New-ServiceReferenceLines -QueryLines @('ServiceName: Display Service')
        $checks = Test-ContentRule -Lines $lines -FrontMatter (Get-FrontMatter -Lines $lines)

        ($checks | Where-Object Name -eq 'api_url_currency_code') | Should -BeNullOrEmpty
    }
}
