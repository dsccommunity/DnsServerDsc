<#PSScriptInfo
.VERSION 1.0.0
.GUID 11891a8c-6535-4535-a9b1-8c00792d8574
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/dsccommunity/xDnsServer/blob/master/LICENSE
.PROJECTURI https://github.com/dsccommunity/xDnsServer
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
        This configuration will manage a primary standalone DNS zone
#>

Configuration xDnsServerPrimaryZone_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerPrimaryZone 'AddPrimaryZone'
        {
            Ensure        = 'Present'
            Name          = 'demo.contoso.com'
            ZoneFile      = 'demo.contoso.com.dns'
            DynamicUpdate = 'NonSecureAndSecure'
        }
    }
}
