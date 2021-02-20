<#PSScriptInfo

.VERSION 1.0.1

.GUID 54006187-ab7b-4071-ab51-df864cd6f834

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/xDnsServer/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/xDnsServer

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module xDnsServer


<#
    .DESCRIPTION
        This configuration will manage aging of a DNS forward zone
#>

Configuration xDnsServerZoneAging_forward_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerZoneAging 'DnsServerZoneAging'
        {
            Name              = 'contoso.com'
            Enabled           = $true
            RefreshInterval   = 120   # 5 days
            NoRefreshInterval = 240   # 10 days
        }
    }
}
