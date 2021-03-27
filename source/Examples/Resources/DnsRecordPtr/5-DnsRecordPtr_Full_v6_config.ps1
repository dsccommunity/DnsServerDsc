<#PSScriptInfo

.VERSION 1.0.1

.GUID f8172f8a-c8bd-4be3-a0ca-c636472ca31c

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
        This configuration will ensure a DNS PTR record exists for an IPv6 address when all properties are specified.
#>

Configuration DnsRecordPtr_Full_v6_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordPtr 'TestRecord'
        {
            ZoneName  = '0.0.d.f.ip6.arpa'
            IpAddress = 'fd00::515c:0:0:d59'
            Name      = 'quarks.contoso.com'
            TimeToLive = '01:00:00'
            DnsServer = 'localhost'
            Ensure    = 'Present'
        }
    }
}
