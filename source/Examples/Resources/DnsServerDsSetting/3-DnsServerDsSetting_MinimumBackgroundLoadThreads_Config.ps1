<#PSScriptInfo

.VERSION 1.0.0

.GUID 0feef9f4-1d8f-4d56-be15-7599cf2ed3b2

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
First version.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module DnsServerDsc

<#
    .DESCRIPTION
        This configuration will change the Minimum Background Load Threads
        in Active Directory.
#>

configuration DnsServerDsSetting_MinimumBackgroundLoadThreads_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node localhost
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer       = 'localhost'
            MinimumBackgroundLoadThreads = 1
        }
    }
}
