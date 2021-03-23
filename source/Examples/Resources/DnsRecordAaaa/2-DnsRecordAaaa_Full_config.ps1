<#PSScriptInfo

.VERSION 1.0.1

.GUID 2cb7551d-fd78-4b6e-bf34-7034fde13f68

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
        This configuration will ensure a DNS AAAA record exists when all properties are specified.
#>

Configuration DnsRecordAaaa_Full_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsRecordAaaa 'TestRecord'
        {
            ZoneName    = 'contoso.com'
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
            TimeToLive  = '01:00:00'
            DnsServer   = 'localhost'
            Ensure      = 'Present'
        }
    }
}
