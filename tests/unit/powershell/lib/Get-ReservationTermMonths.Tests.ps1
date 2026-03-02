BeforeAll {
    . "$PSScriptRoot/../../../../skills/azure-cost-calculator/scripts/lib/Get-ReservationTermMonths.ps1"
}

Describe 'Get-ReservationTermMonths' {

    Context 'when ReservationTerm is 1 Year' {
        It 'should return 12' {
            $result = Get-ReservationTermMonths -ReservationTerm '1 Year'
            $result | Should -Be 12
        }
    }

    Context 'when ReservationTerm is 3 Years' {
        It 'should return 36' {
            $result = Get-ReservationTermMonths -ReservationTerm '3 Years'
            $result | Should -Be 36
        }
    }

    Context 'when ReservationTerm is 5 Years' {
        It 'should return 60' {
            $result = Get-ReservationTermMonths -ReservationTerm '5 Years'
            $result | Should -Be 60
        }
    }

    Context 'when ReservationTerm is null' {
        It 'should return null' {
            $result = Get-ReservationTermMonths -ReservationTerm $null
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'when ReservationTerm is empty string' {
        It 'should return null' {
            $result = Get-ReservationTermMonths -ReservationTerm ''
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'when ReservationTerm is an unrecognised value' {
        It 'should return null for "2 Years"' {
            $result = Get-ReservationTermMonths -ReservationTerm '2 Years'
            $result | Should -BeNullOrEmpty
        }

        It 'should return null for "10 Years"' {
            $result = Get-ReservationTermMonths -ReservationTerm '10 Years'
            $result | Should -BeNullOrEmpty
        }

        It 'should return null for arbitrary text' {
            $result = Get-ReservationTermMonths -ReservationTerm 'Monthly'
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'when ReservationTerm has different casing' {
        It 'should match case-insensitively and return 12 for "1 year"' {
            $result = Get-ReservationTermMonths -ReservationTerm '1 year'
            $result | Should -Be 12
        }
    }
}
