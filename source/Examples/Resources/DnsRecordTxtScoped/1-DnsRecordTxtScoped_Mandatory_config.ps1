<#PSScriptInfo

.VERSION 1.0.1

.GUID 1a19d4c0-f2ef-4d7b-af4d-0240846bc3d4

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
        This configuration will ensure a DNS TXT scoped record exists when only the mandatory properties are specified.
#>

Configuration DnsRecordTxtScoped_Mandatory_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordTxtScoped 'TestRecord'
        {
            ZoneName        = 'contoso.com'
            ZoneScope       = 'external'
            Name            = 'test'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
            Ensure          = 'Present'
        }
    }
}
