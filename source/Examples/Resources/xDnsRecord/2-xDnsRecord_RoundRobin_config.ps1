<#PSScriptInfo
.VERSION 1.0.0
.GUID bff42db0-ad9c-4900-98d2-c59b9718dfc9
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
        This configuration will manage a pair of round-robin DNS A records
#>

Configuration xDnsRecord_RoundRobin_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecord 'TestRecord1'
        {
            Name   = 'testArecord'
            Target = '192.168.0.123'
            Zone   = 'contoso.com'
            Type   = 'ARecord'
            Ensure = 'Present'
        }

        xDnsRecord 'TestRecord2'
        {
            Name   = 'testArecord'
            Target = '192.168.0.124'
            Zone   = 'contoso.com'
            Type   = 'ARecord'
            Ensure = 'Present'
        }
    }
}
