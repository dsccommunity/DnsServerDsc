<#PSScriptInfo

.VERSION 1.0.0

.GUID a822d4a5-c575-45f9-ba1a-aaea21a43c00

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
        This configuration will change the Directory Partition Auto Enlist
        Interval in Active Directory.
#>

configuration DnsServerDsSetting_DirectoryPartitionAutoEnlistInterval_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node localhost
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer    = 'localhost'
            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
        }
    }
}
