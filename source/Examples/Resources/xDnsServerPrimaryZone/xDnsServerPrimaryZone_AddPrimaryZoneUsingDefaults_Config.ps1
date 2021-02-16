<#PSScriptInfo

.VERSION 1.0.1

.GUID 11891a8c-6535-4535-a9b1-8c00792d8574

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
        This configuration will add a file-backed primary zone using the resource
        default parameter values.
#>
Configuration xDnsServerPrimaryZone_AddPrimaryZoneUsingDefaults_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerPrimaryZone 'AddPrimaryZone'
        {
            Name = 'demo.contoso.com'
        }
    }
}
