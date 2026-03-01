<#
.SYNOPSIS
    Builds an OData $filter string from an ordered hashtable of field/value pairs.
    Supports equality filters and contains() operators.
#>
function Build-ODataFilter {
    param(
        [Parameter(Mandatory)]
        [System.Collections.Specialized.OrderedDictionary]$Filters
    )

    $parts = @()
    foreach ($key in $Filters.Keys) {
        $value = $Filters[$key]
        if ($value) {
            if ($key -eq 'contains') {
                foreach ($containsFilter in $value) {
                    $escaped = $containsFilter.Value -replace "'", "''"
                    $parts += "contains(tolower($($containsFilter.Field)), '$($escaped.ToLower())')"
                }
            }
            else {
                $escaped = $value -replace "'", "''"
                $parts += "$key eq '$escaped'"
            }
        }
    }
    return ($parts -join ' and ')
}
