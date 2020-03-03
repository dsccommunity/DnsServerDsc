<#PSScriptInfo
.VERSION 1.0.0
.GUID 372199ea-f1c8-47cd-aa86-90f1d91fc7b4
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
        This configuration will set the DNS forwarders
#>

Configuration xDnsServerForwarder_set_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {

        xDnsServerForwarder 'SetForwarders'
        {
            IsSingleInstance = 'Yes'
            IPAddresses      = @('192.168.0.10', '192.168.0.11')
            UseRootHint      = $false
        }
    }
}
