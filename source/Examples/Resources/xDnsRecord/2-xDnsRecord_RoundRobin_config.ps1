<#PSScriptInfo

.VERSION 1.0.1

.GUID bff42db0-ad9c-4900-98d2-c59b9718dfc9

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
        This configuration will manage a pair of round-robin DNS A records
#>

Configuration xDnsRecord_RoundRobin_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecord 'TestRecord1'
        {
            Name   = 'testArecord'
            Target = '192.168.0.123'
            Zone   = 'contoso.com'
            Type   = 'ARecord'
            Ensure = 'Present'
        }

        xDnsRecord 'TestRecord2'
        {
            Name   = 'testArecord'
            Target = '192.168.0.124'
            Zone   = 'contoso.com'
            Type   = 'ARecord'
            Ensure = 'Present'
        }
    }
}
