<#PSScriptInfo
.VERSION 1.0.0
.GUID 5e7aa23a-52c8-494f-8118-dbec5cd22f76
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
        This configuration will remove all the DNS forwarders
#>

Configuration xDnsServerForwarder_remove_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerForwarder 'SetForwarders'
        {
            IsSingleInstance = 'Yes'
            IPAddresses      = @()
            UseRootHint      = $false
        }
    }
}
