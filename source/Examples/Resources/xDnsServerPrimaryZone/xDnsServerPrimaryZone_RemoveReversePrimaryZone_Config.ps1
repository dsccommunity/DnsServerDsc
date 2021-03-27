<#PSScriptInfo

.VERSION 1.0.0

.GUID aadc72a0-e2f7-4fb0-a5f0-cf24b8edd702

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
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module DnsServerDsc

<#
    .DESCRIPTION
        This configuration will remove a file-backed primary zone.
#>
Configuration xDnsServerPrimaryZone_RemoveReversePrimaryZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        xDnsServerPrimaryZone 'RemovePrimaryZone'
        {
            Ensure        = 'Absent'
            Name          = '1.168.192.in-addr.arpa'
        }
    }
}
