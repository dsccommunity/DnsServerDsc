<#PSScriptInfo

.VERSION 1.0.1

.GUID a43021db-e8e8-47c2-b1c7-ca777921b46b

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/xDnsServer/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/xDnsServer

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module xDnsServer


<#
    .DESCRIPTION
        This configuration will ensure a DNS AAAA record does not exist when mandatory properties are specified.

        Note that not all mandatory properties are necessarily key properties. Non-key property values will be ignored when determining whether the record is to be removed.
#>

Configuration DnsRecordAaaaScoped_Remove_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsRecordAaaaScoped 'TestRecord'
        {
            ZoneName    = 'contoso.com'
            ZoneScope   = 'external'
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
            Ensure      = 'Absent'
        }
    }
}
