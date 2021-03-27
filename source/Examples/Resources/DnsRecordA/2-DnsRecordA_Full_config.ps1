<#PSScriptInfo

.VERSION 1.0.1

.GUID 0a6f0709-abc7-4c00-8114-db016be73daf

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
        This configuration will ensure a DNS A record exists when all properties are specified.
#>

Configuration DnsRecordA_Full_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordA 'TestRecord'
        {
            ZoneName    = 'contoso.com'
            Name        = 'www'
            IPv4Address = '192.168.50.10'
            TimeToLive  = '01:00:00'
            DnsServer   = 'localhost'
            Ensure      = 'Present'
        }
    }
}
