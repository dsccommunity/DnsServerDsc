<#PSScriptInfo
.VERSION 1.0.0
.GUID 4345433b-17e1-4c0f-a59e-8a1f03947dea
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
        This configuration will manage an AD integrated DNS forward lookup zone
#>

Configuration XDnsServerADZone_forward_config
{
    param
    (
        [pscredential]$Credential
    )

    Import-DscResource -Module xDnsServer

    Node localhost
    {

        xDnsServerADZone addForwardADZone
        {
            Name             = 'MyDomainName.com'
            DynamicUpdate    = 'Secure'
            ReplicationScope = 'Forest'
            ComputerName     = 'MyDnsServer.MyDomain.com'
            Credential       = $Credential
            Ensure           = 'Present'
        }
    }
}
