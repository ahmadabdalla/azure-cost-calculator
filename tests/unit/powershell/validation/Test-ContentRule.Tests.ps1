Describe 'Test-ContentRule serviceName consistency' {

    BeforeAll {
        $validationRoot = Join-Path $PSScriptRoot '../../../lib/validation'
        . (Join-Path $validationRoot 'Get-FrontMatter.ps1')
        . (Join-Path $validationRoot 'Test-ContentRule.ps1')

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
}
