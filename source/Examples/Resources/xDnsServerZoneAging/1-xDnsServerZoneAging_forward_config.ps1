<#PSScriptInfo
.VERSION 1.0.0
.GUID 54006187-ab7b-4071-ab51-df864cd6f834
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
