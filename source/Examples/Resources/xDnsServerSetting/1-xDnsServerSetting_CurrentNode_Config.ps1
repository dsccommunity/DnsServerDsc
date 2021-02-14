<#PSScriptInfo

.VERSION 1.0.1

.GUID 1d48864f-a258-4e2a-b67a-b5374c29520c

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/xDnsServer/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/xDnsServer

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module xDnsServer


<#
    .DESCRIPTION
        This configuration will manage the DNS server settings on the current
        node.
#>

Configuration xDnsServerSetting_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerSetting 'DnsServerProperties'
        {
            DnsServer           = 'localhost'
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
