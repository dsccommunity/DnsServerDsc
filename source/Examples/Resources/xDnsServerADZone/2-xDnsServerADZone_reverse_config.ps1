<#PSScriptInfo
.VERSION 1.0.0
.GUID 35660425-c657-4d31-a89e-a163013b726a
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
        This configuration will manage an AD integrated DNS reverse lookup zone
#>

Configuration xDnsServerADZone_reverse_config
{
    Import-DscResource -Module xDnsServer

    Node localhost
    {
        xDnsServerADZone addReverseADZone
        {
            Name             = '1.168.192.in-addr.arpa'
            DynamicUpdate    = 'Secure'
            ReplicationScope = 'Forest'
            Ensure           = 'Present'
        }
    }
}
