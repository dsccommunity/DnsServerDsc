<#PSScriptInfo
.VERSION 1.0.0
.GUID 5ce8253d-5de2-436b-a426-b28e56d396f2
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
        This configuration will manage a DNS A record
#>

Configuration xDnsRecord_ARecord_config
{
    Import-DscResource -Module xDnsServer

    Node localhost
    {
        xDnsRecord TestRecord
        {
            Name   = "testArecord"
            Target = "192.168.0.123"
            Zone   = "contoso.com"
            Type   = "ARecord"
            Ensure = "Present"
        }
    }
}
