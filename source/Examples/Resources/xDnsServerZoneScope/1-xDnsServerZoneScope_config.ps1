<#PSScriptInfo
.VERSION 1.0.0
.GUID f4aceafc-6d40-4e4f-94bc-d3b0e1e1bcac
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
        This configuration will manage a DNS zone scope
#>

Configuration xDnsServerZoneScope_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    xDnsServerZoneScope 'ZoneScope1'
    {
        Name     = 'contoso_NorthAmerica'
        ZoneName = 'contoso.com'
        Ensure   = 'Present'
    }
}
