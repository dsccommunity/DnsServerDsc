<#PSScriptInfo

.VERSION 1.0.1

.GUID 4345433b-17e1-4c0f-a59e-8a1f03947dea

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
        This configuration will manage a DNS zone transfer
#>

Configuration xDnsServerZoneTransfer_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    xDnsServerZoneTransfer 'TransferToAnyServer'
    {
        Name = 'demo.contoso.com'
        Type = 'Any'
    }
}
