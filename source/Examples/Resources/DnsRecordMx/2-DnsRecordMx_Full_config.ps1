<#PSScriptInfo

.VERSION 1.0.1

.GUID e82270f4-80a0-4860-821c-2a2d59ce5e66

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

Configuration DnsRecordMx_Full_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordMx 'TestRecord'
        {
            ZoneName     = 'contoso.com'
            EmailDomain  = 'contoso.com'
            MailExchange = 'mailserver1.contoso.com'
            Priority     = 20
            TimeToLive   = '01:00:00'
            DnsServer    = 'localhost'
            Ensure       = 'Present'
        }
    }
}
