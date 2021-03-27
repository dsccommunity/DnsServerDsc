<#PSScriptInfo

.VERSION 1.0.1

.GUID 7a72f2ec-1a64-4f78-8685-3f938639bd79

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
        This configuration will ensure a DNS A record does not exist when mandatory properties are specified.

        Note that not all mandatory properties are necessarily key properties. Non-key property values will be ignored when determining whether the record is to be removed.
#>

Configuration DnsRecordA_Remove_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordA 'TestRecord'
        {
            ZoneName    = 'contoso.com'
            Name        = 'www'
            IPv4Address = '192.168.50.10'
            Ensure      = 'Absent'
        }
    }
}
