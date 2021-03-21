<#PSScriptInfo

.VERSION 1.0.1

.GUID 954ac80d-0b21-43fa-911c-2bd875bfba36

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
        This configuration will ensure a DNS PTR record exists for an IPv6 address when only the mandatory properties are specified.
#>

Configuration DnsRecordPtr_Mandatory_v6_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsRecordPtr 'TestRecord'
        {
            ZoneName  = '0.0.d.f.ip6.arpa'
            IpAddress = 'fd00::515c:0:0:0d59'
            Name      = 'quarks.contoso.com'
            Ensure    = 'Present'
        }
    }
}
