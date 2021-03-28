<#PSScriptInfo

.VERSION 1.0.0

.GUID 82d3c621-1cd2-4989-b234-ba0e38630639

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/DnsServerDsc/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/DnsServerDsc

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
First version.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module DnsServerDsc

<#
    .DESCRIPTION
        This configuration will change the cache settings on the DNS server.
#>

Configuration DnsServerRecursion_SetRecursionSettings_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerCache 'SetRecursionSettings'
        {
            DnsServer         = 'localhost'
            Enable            = $true
            AdditionalTimeout = 4
            RetryInterval     = 3
            Timeout           = 8
        }
    }
}
