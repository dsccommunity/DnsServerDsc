<#PSScriptInfo
.VERSION 1.0.0
.GUID 1d48864f-a258-4e2a-b67a-b5374c29520c
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
        This configuration will manage the DNS server settings
#>

Configuration xDnsServerSetting_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerSetting 'DnsServerProperties'
        {
            Name               = 'DnsServerSetting'
            ListenAddresses    = '10.0.0.4'
            IsSlave            = $true
            Forwarders         = @('168.63.129.16', '168.63.129.18')
            RoundRobin         = $true
            LocalNetPriority   = $true
            SecureResponses    = $true
            NoRecursion        = $false
            BindSecondaries    = $false
            StrictFileParsing  = $false
            ScavengingInterval = 168
            LogLevel           = 50393905
        }
    }
}
