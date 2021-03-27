<#PSScriptInfo

.VERSION 1.0.0

.GUID 00bc0e3f-ef18-41a1-94fd-940414e6abd2

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
        This configuration will add a file-backed classless reverse primary zone
        using the resource default parameter values.
#>
Configuration xDnsServerPrimaryZone_AddClasslessReversePrimaryZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        xDnsServerPrimaryZone 'AddPrimaryZone'
        {
            Name = '64-26.100.168.192.in-addr.arpa'
        }
    }
}
