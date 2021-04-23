<#PSScriptInfo

.VERSION 1.0.1

.GUID deff6e75-397f-46c8-b52c-9f60c6418783

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
        This configuration will ensure a DNS NS record exists when only the mandatory properties are specified.
#>

Configuration DnsRecordNsScoped_Mandatory_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordNsScoped 'TestRecord'
        {
            ZoneName   = 'contoso.com'
            ZoneScope  = 'external'
            DomainName = 'contoso.com'
            NameServer = 'ns.contoso.com'
            Ensure     = 'Present'
        }
    }
}
