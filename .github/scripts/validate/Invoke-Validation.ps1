# ---------------------------------------------------------
# Invoke-Validation.ps1
# ---------------------------------------------------------
# Unified entry point for all service-reference validation
# modes. Called by the validate-service-references workflow.
#
# Parameters:
#   -Mode             (required) Validation mode:
#                       ChangedOnly    - validate only the files listed in
#                                        -ChangedFiles (PR service-file changes)
#                       Full           - validate every .md under -ServicesRoot
#                                        (used after infrastructure changes)
#                       RoutingSyncOnly - validate routing-file sync using a
#                                        single representative file (fallback)
#   -ChangedFiles     (optional) Newline-separated list of changed file paths.
#                     Required when Mode = ChangedOnly.
#   -ServicesRoot     (required) Relative path to the services directory.
#   -ValidationScript (required) Path to Validate-ServiceReference.ps1.
#
# Usage examples:
#   # Validate only changed service files
#   ./Invoke-Validation.ps1 -Mode ChangedOnly `
#     -ChangedFiles $env:CHANGED_FILES `
#     -ServicesRoot $env:SERVICES_ROOT `
#     -ValidationScript $env:VALIDATION_SCRIPT
#
#   # Validate all service files (after infrastructure change)
#   ./Invoke-Validation.ps1 -Mode Full `
#     -ServicesRoot $env:SERVICES_ROOT `
#     -ValidationScript $env:VALIDATION_SCRIPT
#
#   # Routing sync check only (fallback)
#   ./Invoke-Validation.ps1 -Mode RoutingSyncOnly `
#     -ServicesRoot $env:SERVICES_ROOT `
#     -ValidationScript $env:VALIDATION_SCRIPT
# ---------------------------------------------------------

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ChangedOnly', 'Full', 'RoutingSyncOnly')]
    [string] $Mode,

    [Parameter()]
    [string] $ChangedFiles,

    [Parameter(Mandatory)]
    [string] $ServicesRoot,

    [Parameter(Mandatory)]
    [string] $ValidationScript
)

switch ($Mode) {

    'ChangedOnly' {
        # Split the multi-line string into an array, keep only files that exist.
        $files = $ChangedFiles -split "`n" |
        Where-Object { $_ -and (Test-Path $_) }

        if ($files.Count -eq 0) {
            Write-Output "No service reference files to validate."
            return
        }

        Write-Output "Validating $($files.Count) changed file(s):"
        $files | ForEach-Object { Write-Output "  - $_" }
        Write-Output ""

        & $ValidationScript -Path $files -ServicesRoot $ServicesRoot `
            -CheckAliasUniqueness -CheckAliasRoutingSync -CheckBillingNeeds -CheckRoutingFileSync
    }

    'Full' {
        # Collect every .md file under the services folder.
        $files = Get-ChildItem -Path $ServicesRoot -Filter '*.md' -Recurse |
        Select-Object -ExpandProperty FullName

        if ($files.Count -eq 0) {
            Write-Output "No service reference files found."
            return
        }

        Write-Output "Infrastructure files changed -- validating all $($files.Count) service reference file(s)."
        Write-Output ""

        & $ValidationScript -Path $files -ServicesRoot $ServicesRoot `
            -CheckAliasUniqueness -CheckAliasRoutingSync -CheckBillingNeeds -CheckRoutingFileSync
    }

    'RoutingSyncOnly' {
        # Pick a single representative file to satisfy the script's -Path requirement.
        $anyFile = Get-ChildItem -Path $ServicesRoot -Filter '*.md' -Recurse |
        Select-Object -First 1 -ExpandProperty FullName

        if ($anyFile) {
            Write-Output "Running routing-sync check using: $anyFile"
            & $ValidationScript -Path $anyFile -ServicesRoot $ServicesRoot -CheckRoutingFileSync
        }
        else {
            Write-Output "No service reference files found -- skipping routing sync check."
        }
    }
}
