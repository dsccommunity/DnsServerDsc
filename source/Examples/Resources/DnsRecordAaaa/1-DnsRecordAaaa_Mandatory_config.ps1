<#PSScriptInfo

.VERSION 1.0.1

.GUID 61ba3071-04b7-42cd-93f5-96c29de7660a

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
        This configuration will ensure a DNS AAAA record exists when only the mandatory properties are specified.
#>

Configuration DnsRecordAaaa_Mandatory_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordAaaa 'TestRecord'
        {
            ZoneName    = 'contoso.com'
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
            Ensure      = 'Present'
        }
    }
}
