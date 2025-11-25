<#PSScriptInfo

.VERSION 1.0.1

.GUID 69b26e36-d45d-4621-b5d2-5bfed0503c10

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
        This configuration will ensure a DNS TXT record exists when all properties are specified.
#>

Configuration DnsRecordTxt_Full_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordTxt 'TestRecord Multiline Full'
        {
            ZoneName        = 'contoso.com'
            Name            = 'sea2048._domainkey'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
            TimeToLive      = '01:00:00'
            DnsServer       = 'localhost'
            Ensure          = 'Present'
        }
    }
}
