<#PSScriptInfo
.VERSION 1.0.0
.GUID 3c496dfc-346b-49bc-b251-459b2704638c
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/xDnsServer/blob/master/LICENSE
.PROJECTURI https://github.com/Powershell/xDnsServer
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module xDnsServer

<#
    .DESCRIPTION
        This configuration will manage aging of a DNS reverse zone
#>

Configuration xDnsServerZoneAging_reverse_config
{
    Import-DscResource -Module xDnsServer

    Node localhost
    {
        xDnsServerZoneAging DnsServerReverseZoneAging
        {
            Name              = '168.192.in-addr-arpa'
            Enabled           = $true
            RefreshInterval   = 168   # 7 days
            NoRefreshInterval = 168   # 7 days
        }
    }
}
