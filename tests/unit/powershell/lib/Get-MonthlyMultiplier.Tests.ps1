BeforeAll {
    . "$PSScriptRoot/../../../../skills/azure-cost-calculator/scripts/lib/Get-MonthlyMultiplier.ps1"
}

Describe 'Get-MonthlyMultiplier' {

    Context 'when unit matches 1 Hour wildcard' {
        It 'should return default HoursMonth for "1 Hour"' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1 Hour'
            $result | Should -Be 730
        }

        It 'should return default HoursMonth for "1 Hours"' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1 Hours'
            $result | Should -Be 730
        }

        It 'should return default HoursMonth for "1 Hour (PC)"' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1 Hour (PC)'
            $result | Should -Be 730
        }

        It 'should return custom HoursMonth when overridden' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1 Hour' -HoursMonth 744
            $result | Should -Be 744
        }
    }

    Context 'when unit is 1/Hour' {
        It 'should return default HoursMonth' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1/Hour'
            $result | Should -Be 730
        }

        It 'should return custom HoursMonth when overridden' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1/Hour' -HoursMonth 750
            $result | Should -Be 750
        }
    }

    Context 'when unit is 1 GiB Hour' {
        It 'should return default HoursMonth' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1 GiB Hour'
            $result | Should -Be 730
        }

        It 'should return custom HoursMonth when overridden' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1 GiB Hour' -HoursMonth 720
            $result | Should -Be 720
        }
    }

    Context 'when unit is 1/Day' {
        It 'should return 30' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1/Day'
            $result | Should -Be 30
        }

        It 'should ignore HoursMonth parameter' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1/Day' -HoursMonth 999
            $result | Should -Be 30
        }
    }

    Context 'when unit does not match any known pattern' {
        It 'should return 1 for "1 GB/Month"' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1 GB/Month'
            $result | Should -Be 1
        }

        It 'should return 1 for "1/Month"' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1/Month'
            $result | Should -Be 1
        }

        It 'should return 1 for "10K Transactions"' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '10K Transactions'
            $result | Should -Be 1
        }

        It 'should return 1 for an arbitrary string' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure 'Unknown Unit'
            $result | Should -Be 1
        }
    }

    Context 'when HoursMonth defaults' {
        It 'should default to 730' {
            $result = Get-MonthlyMultiplier -UnitOfMeasure '1 Hour'
            $result | Should -BeExactly 730
        }
    }
}
