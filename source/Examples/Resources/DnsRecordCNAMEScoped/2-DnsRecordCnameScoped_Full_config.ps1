<#PSScriptInfo

.VERSION 1.0.1

.GUID 581d5c23-0acd-4f3b-9281-2bcc86928db7

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
        This configuration will ensure a DNS CNAME record exists when all properties are specified.
#>

Configuration DnsRecordCnameScoped_Full_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordCnameScoped 'TestRecord'
        {
            ZoneName      = 'contoso.com'
            ZoneScope     = 'external'
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
            TimeToLive    = '01:00:00'
            DnsServer     = 'localhost'
            Ensure        = 'Present'
        }
    }
}
