<#PSScriptInfo

.VERSION 1.0.0

.GUID e3aeafd4-b41a-48e0-b9be-9b5c01f904d3

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
        This configuration will enable scavenging on the DNS server, using
        the default interval values.
#>

Configuration EnableScavenging_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerScavenging 'EnableScavenging'
        {
            DnsServer       = 'localhost'
            ScavengingState = $true
        }
    }
}
