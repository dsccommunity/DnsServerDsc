<#PSScriptInfo
.VERSION 1.0.0
.GUID 21a1ac4b-4e61-49fc-a279-416b9e06ea29
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
        This configuration will manage a DNS PTR record
#>

Configuration xDnsRecord_PTR_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecord 'TestPtrRecord'
        {
            Name   = '123'
            Target = 'TestA.contoso.com'
            Zone   = '0.168.192.in-addr.arpa'
            Type   = 'PTR'
            Ensure = 'Present'
        }
    }
}
