<#PSScriptInfo

.VERSION 1.0.0

.GUID 939afc66-89ba-40c1-8c46-831a97ccde29

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
        This configuration will remove a file-backed primary zone.
#>
Configuration xDnsServerPrimaryZone_RemovePrimaryZone_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerPrimaryZone 'RemovePrimaryZone'
        {
            Ensure        = 'Absent'
            Name          = 'demo.contoso.com'
        }
    }
}
