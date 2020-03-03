<#PSScriptInfo
.VERSION 1.0.0
.GUID 580a9ebd-095b-48cb-ba02-d15094b4938d
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
        This configuration will manage a secondary standalone DNS zone
#>

Configuration xDnsServerSecondaryZone_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerSecondaryZone 'sec'
        {
            Ensure        = 'Present'
            Name          = 'demo.contoso.com'
            MasterServers = '192.168.10.2'
        }
    }
}
