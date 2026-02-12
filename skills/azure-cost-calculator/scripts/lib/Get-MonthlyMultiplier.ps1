<#
.SYNOPSIS
    Maps a unitOfMeasure string to a monthly multiplier.
    Hourly units return $HoursMonth; daily units return 30; everything else returns 1.
#>
function Get-MonthlyMultiplier {
    param(
        [Parameter(Mandatory)]
        [string]$UnitOfMeasure,

        [Parameter()]
        [double]$HoursMonth = 730
    )

    switch -Wildcard ($UnitOfMeasure) {
        '1 Hour*' { return $HoursMonth }
        '1/Hour' { return $HoursMonth }
        '1 GiB Hour' { return $HoursMonth }
        '1/Day' { return 30 }
        default { return 1 }
    }
}
