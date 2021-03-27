<#PSScriptInfo

.VERSION 1.0.0

.GUID 688044b2-8b87-4141-bb59-199f543096ed

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
        This configuration will add a file-backed primary zone using the resource
        default parameter values.
#>
Configuration xDnsServerPrimaryZone_AddPrimaryZoneWithSpecificValues_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        xDnsServerPrimaryZone 'AddPrimaryZone'
        {
            Ensure        = 'Present'
            Name          = 'demo.contoso.com'
            ZoneFile      = 'demo.contoso.com.dns'
            DynamicUpdate = 'NonSecureAndSecure'
        }
    }
}
