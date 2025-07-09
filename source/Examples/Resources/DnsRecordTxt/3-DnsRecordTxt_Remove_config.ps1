<#PSScriptInfo

.VERSION 1.0.1

.GUID ee3a6dd8-b64e-440e-9d66-866b6f83428a

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
        This configuration will ensure a DNS TXT record does not exist when mandatory properties are specified.

        Note that not all mandatory properties are necessarily key properties. Non-key property values will be ignored when determining whether the record is to be removed.
#>

Configuration DnsRecordTxt_Remove_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordTxt 'TestRecord'
        {
            ZoneName        = 'contoso.com'
            Name            = 'test'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
            Ensure          = 'Absent'
        }
    }
}
