<#PSScriptInfo

.VERSION 1.0.1

.GUID 35660425-c657-4d31-a89e-a163013b726a

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/DnsServerDsc/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/DnsServerDsc

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module DnsServerDsc


<#
    .DESCRIPTION
        This configuration will manage an AD integrated DNS reverse lookup zone
#>

Configuration xDnsServerADZone_reverse_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        xDnsServerADZone 'addReverseADZone'
        {
            Name             = '1.168.192.in-addr.arpa'
            DynamicUpdate    = 'Secure'
            ReplicationScope = 'Forest'
            Ensure           = 'Present'
        }
    }
}
