<#PSScriptInfo

.VERSION 1.0.1

.GUID 73611f8c-d592-4b11-9058-d6209313e85b

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
        This configuration will ensure a DNS CNAME record exists when all properties are specified.
#>

Configuration DnsRecordCname_Full_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsRecordCname 'TestRecord'
        {
            ZoneName      = 'contoso.com'
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
            TimeToLive    = '01:00:00'
            DnsServer     = 'localhost'
            Ensure        = 'Present'
        }
    }
}
