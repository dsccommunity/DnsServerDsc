<#PSScriptInfo
.VERSION 1.0.0
.GUID 192b2a8c-2e8a-470c-8558-2da70c3b8793
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
        This configuration will manage a DNS client subnet
#>

Configuration xDnsServerClientSubnet_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerClientSubnet 'ClientSubnet1'
        {
            Name       = 'London'
            IPv4Subnet = @('10.1.0.0/16', '10.8.0.0/16')
            Ensure     = 'Present'
        }
    }
}
