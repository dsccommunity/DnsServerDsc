<#PSScriptInfo

.VERSION 1.0.1

.GUID 3c496dfc-346b-49bc-b251-459b2704638c

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
        This configuration will manage aging of a DNS reverse zone
#>

Configuration xDnsServerZoneAging_reverse_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        xDnsServerZoneAging 'DnsServerReverseZoneAging'
        {
            Name              = '168.192.in-addr-arpa'
            Enabled           = $true
            RefreshInterval   = 168   # 7 days
            NoRefreshInterval = 168   # 7 days
        }
    }
}
