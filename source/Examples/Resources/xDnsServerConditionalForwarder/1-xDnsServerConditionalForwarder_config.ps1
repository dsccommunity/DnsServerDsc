<#PSScriptInfo
.VERSION 1.0.0
.GUID 0c684a3b-01fd-4759-8686-ea9a82d76aab
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
        This configuration will manage a DNS server conditional forwarder
#>

Configuration xDnsServerConditionalForwarder_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerConditionalForwarder 'Forwarder1'
        {
            Name             = 'London'
            MasterServers    = @('10.0.1.10', '10.0.2.10')
            ReplicationScope = 'Forest'
            Ensure           = 'Present'
        }
    }
}
