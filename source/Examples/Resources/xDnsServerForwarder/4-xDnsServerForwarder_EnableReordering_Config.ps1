<#PSScriptInfo

.VERSION 1.0.0

.GUID 43671215-6adc-4a8f-89f4-5c8f53f8a622

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
        This configuration will set the DNS forwarders and enable dynamic reordering.
#>

Configuration DnsServerForwarder_EnableReordering_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerForwarder 'SetUseRootHints'
        {
            IsSingleInstance = 'Yes'
            IPAddresses      = @('192.168.0.10', '192.168.0.11')
            UseRootHint      = $false
            EnableReordering = $true
        }
    }
}
