<#PSScriptInfo

.VERSION 1.0.0

.GUID 57cdc411-d737-4dc2-9ede-86ffea596094

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
        This configuration will change the Lazy Update
        Interval in Active Directory.
#>

configuration DnsServerDsSetting_LazyUpdateInterval_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node localhost
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer    = 'localhost'
            LazyUpdateInterval = 3
        }
    }
}
