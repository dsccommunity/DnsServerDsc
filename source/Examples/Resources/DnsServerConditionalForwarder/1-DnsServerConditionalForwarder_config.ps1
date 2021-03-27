<#PSScriptInfo

.VERSION 1.0.1

.GUID 0c684a3b-01fd-4759-8686-ea9a82d76aab

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
        This configuration will manage a DNS server conditional forwarder
#>

Configuration DnsServerConditionalForwarder_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerConditionalForwarder 'Forwarder1'
        {
            Name             = 'London'
            MasterServers    = @('10.0.1.10', '10.0.2.10')
            ReplicationScope = 'Forest'
            Ensure           = 'Present'
        }
    }
}
