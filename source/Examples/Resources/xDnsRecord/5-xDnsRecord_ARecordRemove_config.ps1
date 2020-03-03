<#PSScriptInfo
.VERSION 1.0.0
.GUID 7dfa3c15-9c74-4d87-a452-68cdb90b3742
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
        This configuration will remove a DNS A record
#>

Configuration xDnsRecord_ARecordRemove_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecord 'RemoveTestRecord'
        {
            Name   = 'testArecord'
            Target = '192.168.0.123'
            Zone   = 'contoso.com'
            Type   = 'ARecord'
            Ensure = 'Absent'
        }
    }
}
