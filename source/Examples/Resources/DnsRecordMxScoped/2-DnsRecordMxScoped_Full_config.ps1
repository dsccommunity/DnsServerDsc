<#PSScriptInfo

.VERSION 1.0.1

.GUID d03cdd7e-495c-4e74-be28-1dda705bb1be

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
        This configuration will ensure a DNS MX record exists when all properties are specified.
#>

Configuration DnsRecordMxScoped_Full_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordMxScoped 'TestRecord'
        {
            ZoneName     = 'contoso.com'
            ZoneScope    = 'external'
            EmailDomain  = 'contoso.com'
            MailExchange = 'mailserver1.contoso.com'
            Priority     = 20
            TimeToLive   = '01:00:00'
            DnsServer    = 'localhost'
            Ensure       = 'Present'
        }
    }
}
