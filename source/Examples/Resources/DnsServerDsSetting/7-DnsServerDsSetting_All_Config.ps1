<#PSScriptInfo

.VERSION 1.0.0

.GUID b20e9d5c-ba74-4686-9293-08077e53cb8f

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
        This configuration will set all Active Directory-based DNS settings on
        the specified server.
#>

configuration DnsServerDsSetting_All_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node localhost
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer    = 'localhost'
            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
            LazyUpdateInterval = 3
            MinimumBackgroundLoadThreads = 1
            PollingInterval = 180
            RemoteReplicationDelay = 30
            TombstoneInterval = '14.00:00:00'
        }
    }
}
