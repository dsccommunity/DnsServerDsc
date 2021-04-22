<#PSScriptInfo

.VERSION 1.0.1

.GUID 4f3e8876-fcae-4e1f-a879-fbde1b1fe56c

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
        This configuration will ensure a DNS NS record does not exist when mandatory properties are specified.

        Note that not all mandatory properties are necessarily key properties. Non-key property values will be ignored when determining whether the record is to be removed.
#>

Configuration DnsRecordNs_Remove_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordNs 'TestRecord'
        {
            ZoneName   = 'contoso.com'
            DomainName = 'contoso.com'
            NameServer = 'ns.contoso.com'
            Ensure     = 'Absent'
        }
    }
}
