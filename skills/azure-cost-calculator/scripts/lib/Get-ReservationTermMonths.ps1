<#
.SYNOPSIS
    Maps a reservationTerm string to the number of months in the term.

.DESCRIPTION
    Converts Azure API reservationTerm values ('1 Year', '3 Years', '5 Years')
    to their equivalent month counts. Returns $null for null, empty, or
    unrecognized inputs.

.PARAMETER ReservationTerm
    The reservationTerm string from the Azure Retail Prices API.

.EXAMPLE
    Get-ReservationTermMonths -ReservationTerm '1 Year'
    # Returns 12

.EXAMPLE
    Get-ReservationTermMonths -ReservationTerm '3 Years'
    # Returns 36

.EXAMPLE
    Get-ReservationTermMonths -ReservationTerm $null
    # Returns $null

.OUTPUTS
    System.Nullable[int]
#>
function Get-ReservationTermMonths {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '',
        Justification = 'Months is a unit of measurement, not a plural collection.')]
    [OutputType([System.Nullable[int]])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$ReservationTerm
    )

    if ([string]::IsNullOrEmpty($ReservationTerm)) {
        return $null
    }

    switch ($ReservationTerm) {
        '1 Year' { return 12 }
        '3 Years' { return 36 }
        '5 Years' { return 60 }
        default { return $null }
    }
}
