Describe 'Test-FrontMatter schema type validation' {

    BeforeAll {
        $validationRoot = Join-Path $PSScriptRoot '../../../lib/validation'
        . (Join-Path $validationRoot 'Get-FrontMatter.ps1')
        . (Join-Path $validationRoot 'Test-FrontMatter.ps1')

        function New-ServiceReferenceLines {
            param(
                [string[]]$ExtraFrontMatter = @()
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
            )
        }

        function Invoke-FrontMatterChecks {
            param(
                [string[]]$ExtraFrontMatter = @()
            )

            $lines = New-ServiceReferenceLines -ExtraFrontMatter $ExtraFrontMatter
            $frontMatter = Get-FrontMatter -Lines $lines
            Test-FrontMatter `
                -FrontMatter $frontMatter `
                -FilePath 'skills/azure-cost-calculator/references/services/compute/display-service.md'
        }

        function Get-ValidationCheck {
            param(
                [object[]]$Checks,
                [string]$Name
            )

            foreach ($check in $Checks) {
                if ($check.Name -eq $Name) {
                    return $check
                }
            }
        }
    }

    It 'passes when apiServiceName is scalar and queryServiceNames is an array' {
        $checks = Invoke-FrontMatterChecks -ExtraFrontMatter @(
            'apiServiceName: API Service'
            'queryServiceNames: [Extra Service]'
        )

        (Get-ValidationCheck -Checks $checks -Name 'frontmatter_apiServiceName_type').Pass | Should -BeTrue
        (Get-ValidationCheck -Checks $checks -Name 'frontmatter_queryServiceNames_type').Pass | Should -BeTrue
    }

    It 'fails when apiServiceName uses array syntax' {
        $checks = Invoke-FrontMatterChecks -ExtraFrontMatter @('apiServiceName: [API Service, Another API Service]')
        $check = Get-ValidationCheck -Checks $checks -Name 'frontmatter_apiServiceName_type'

        $check.Pass | Should -BeFalse
        $check.Message | Should -Match 'scalar string'
    }

    It 'fails when queryServiceNames uses scalar syntax' {
        $checks = Invoke-FrontMatterChecks -ExtraFrontMatter @('queryServiceNames: Extra Service')
        $check = Get-ValidationCheck -Checks $checks -Name 'frontmatter_queryServiceNames_type'

        $check.Pass | Should -BeFalse
        $check.Message | Should -Match 'array syntax'
    }
}
