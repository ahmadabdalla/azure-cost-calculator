Set-StrictMode -Version Latest

function New-ValidationCheck {
    <#
    .SYNOPSIS
        Creates a standardised validation result hashtable.
    .DESCRIPTION
        Factory function that builds the hashtable returned by every
        validation check. Selects PassMessage or FailMessage based on
        the Pass parameter.
    .PARAMETER Name
        Short label that identifies the check.
    .PARAMETER Pass
        Whether the check passed.
    .PARAMETER PassMessage
        Message to include when the check passes.
    .PARAMETER FailMessage
        Message to include when the check fails.
    .OUTPUTS
        hashtable
    .EXAMPLE
        New-ValidationCheck -Name 'HasTitle' -Pass $true -PassMessage 'Title found' -FailMessage 'Missing title'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [bool]$Pass,

        [Parameter(Mandatory)]
        [string]$PassMessage,

        [Parameter(Mandatory)]
        [string]$FailMessage
    )

    if ($PSCmdlet.ShouldProcess($Name, 'Create validation check')) {
        @{
            Name    = $Name
            Pass    = $Pass
            Message = if ($Pass) { $PassMessage } else { $FailMessage }
        }
    }
}
