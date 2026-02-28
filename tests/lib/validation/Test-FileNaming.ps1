Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'New-ValidationCheck.ps1')

function Test-FileNaming {
    <#
    .SYNOPSIS
        Validates the filename follows kebab-case convention from serviceName.
    .DESCRIPTION
        Checks that the file is named according to the repo convention:
        strip leading Azure/Microsoft/MS prefix and version suffixes from
        the YAML serviceName, convert to kebab-case, and append .md.
        A known-exceptions hashtable handles legitimate edge cases.
    .PARAMETER FilePath
        Full path to the service reference file.
    .PARAMETER FrontMatter
        Hashtable returned by Get-FrontMatter (with Found, Fields, EndLine).
    .OUTPUTS
        System.Array
    .EXAMPLE
        Test-FileNaming -FilePath 'services/cosmos-db.md' -FrontMatter @{ Found = $true; Fields = @{ serviceName = 'Azure Cosmos DB' }; EndLine = 3 }
    #>
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [hashtable]$FrontMatter
    )

    $checks = [System.Collections.Generic.List[object]]::new()

    $hasServiceName = $FrontMatter.Found -and
    $FrontMatter.Fields.ContainsKey('serviceName') -and
    -not [string]::IsNullOrWhiteSpace($FrontMatter.Fields['serviceName'])

    if (-not $hasServiceName) {
        $checks.Add((New-ValidationCheck -Name 'file_naming' -Pass $true `
                    -PassMessage 'Skipped — no serviceName in front-matter' `
                    -FailMessage 'Skipped — no serviceName in front-matter'))
    }
    else {
        $serviceName = $FrontMatter.Fields['serviceName'].Trim()
        $actualFile = Split-Path -Leaf $FilePath

        # Known exceptions where the algorithmic conversion does not match
        $exceptions = @{
            'Azure Active Directory B2C'                     = 'aad-b2c.md'
            'Azure Active Directory for External Identities' = 'aad-external-identities.md'
            'Azure Front Door Service'                       = 'front-door.md'
            'Azure Managed Instance for Apache Cassandra'    = 'cassandra-managed-instance.md'
            'Azure Spring Cloud'                             = 'spring-apps.md'
            'Advanced Container Networking Services'         = 'advanced-container-networking.md'
            'Change Tracking and Inventory'                  = 'change-tracking.md'
            'Dynamics 365 for Customer Insights'             = 'dynamics-365-customer-insights.md'
            'ExpressRoute'                                   = 'express-route.md'
            'Foundry Models'                                 = 'openai-service.md'
            'Foundry Tools'                                  = 'ai-services.md'
            'Microsoft Planetary Computer Pro'               = 'planetary-computer.md'
            'SQL Server Stretch Database'                    = 'sql-stretch-database.md'
            'Windows 10 IoT Core Services'                   = 'windows-iot-core.md'
            'not in API'                                     = 'ddos-protection.md'
        }

        # Split-file services: multiple files share a serviceName — accept the actual filename
        $splitFileOverrides = @(
            'private-dns.md',       # serviceName: Azure DNS (split with dns.md)
            'private-link.md',      # serviceName: Virtual Network (split with virtual-network.md)
            'data-lake-storage.md', # serviceName: Storage (split with storage.md, managed-disks.md)
            'managed-disks.md',     # serviceName: Storage (split with storage.md, data-lake-storage.md)
            'file-sync.md',         # serviceName: Storage (split with storage.md, managed-disks.md, data-lake-storage.md)
            'container-storage.md'  # serviceName: Storage (split with storage.md, managed-disks.md, data-lake-storage.md)
            )

        if ($actualFile -in $splitFileOverrides) {
            $expectedFile = $actualFile
        }
        elseif ($exceptions.ContainsKey($serviceName)) {
            $expectedFile = $exceptions[$serviceName]
        }
        else {
            $name = $serviceName
            while ($name -match '^(Azure |Microsoft |MS )') {
                $name = $name -replace '^(Azure |Microsoft |MS )', ''
            }
            $name = $name.Trim()
            $name = $name -replace '\s+v\d+$', ''

            $brandedWords = @{
                'SignalR'    = 'signalr'
                'DevOps'     = 'devops'
                'OpenAI'     = 'openai'
                'BizTalk'    = 'biztalk'
                'PlayFab'    = 'playfab'
                'PubSub'     = 'pubsub'
                'DevTest'    = 'devtest'
                'NetApp'     = 'netapp'
                'StorSimple' = 'storsimple'
                'HBase'      = 'hbase'
            }
            foreach ($brand in $brandedWords.Keys) {
                $name = $name -replace [regex]::Escape($brand), $brandedWords[$brand]
            }
            $name = $name -replace '[^\w\s-]', ''

            $expectedFile = (($name -split '\s+' | ForEach-Object { $_.ToLower() }) -join '-') + '.md'
        }

        # Case-sensitive comparison enforces lowercase kebab-case filenames
        $pass = $actualFile -ceq $expectedFile
        $failMsg = "Filename '$actualFile' does not match expected '$expectedFile' (from serviceName '$serviceName')"
        if (-not $pass) {
            $failMsg += ". If multiple files share this serviceName, add the filename to `$splitFileOverrides in Test-FileNaming.ps1"
        }
        $checks.Add((New-ValidationCheck -Name 'file_naming' -Pass $pass `
                    -PassMessage "Filename '$actualFile' matches expected '$expectedFile'" `
                    -FailMessage $failMsg))
    }

    , $checks
}