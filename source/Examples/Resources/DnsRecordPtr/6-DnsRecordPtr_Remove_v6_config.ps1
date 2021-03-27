<#PSScriptInfo

.VERSION 1.0.1

.GUID 6f460efd-2757-442e-82ad-b28c78c0746a

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
        This configuration will ensure a DNS PTR record does not exist for an IPv6 address when mandatory properties are specified.
#>

Configuration DnsRecordPtr_Remove_v6_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordPtr 'TestRecord'
        {
            ZoneName  = '0.0.d.f.ip6.arpa'
            IpAddress = 'fd00::515c:0:0:d59'
            Name      = 'quarks.contoso.com'
            Ensure    = 'Absent'
        }
    }
}
