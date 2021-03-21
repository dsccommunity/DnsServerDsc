<#PSScriptInfo

.VERSION 1.0.1

.GUID 5aa5cffa-4e3a-4861-b601-73f234015bc9

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
        This configuration will ensure a DNS PTR record exists when all properties are specified.
#>

Configuration DnsRecordPtr_Full_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsRecordPtr 'TestRecord'
        {
            ZoneName  = '0.168.192.in-addr.arpa'
            IpAddress = '192.168.0.9'
            Name      = 'quarks.contoso.com'
            TimeToLive = '01:00:00'
            DnsServer = 'localhost'
            Ensure    = 'Present'
        }
    }
}
