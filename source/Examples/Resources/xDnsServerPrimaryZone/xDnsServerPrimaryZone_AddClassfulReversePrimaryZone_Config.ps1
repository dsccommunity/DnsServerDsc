<#PSScriptInfo

.VERSION 1.0.0

.GUID e1c43a56-e5b2-4755-aa08-d81c72530fc6

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
        This configuration will add a file-backed classful reverse primary zone
        using the resource default parameter values.
#>
Configuration xDnsServerPrimaryZone_AddClassfulReversePrimaryZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        xDnsServerPrimaryZone 'AddPrimaryZone'
        {
            Name = '1.168.192.in-addr.arpa'
        }
    }
}
