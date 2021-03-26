<#PSScriptInfo

.VERSION 1.0.1

.GUID 6de18004-af6f-4e04-9ca3-bb7af84b09c3

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
        This configuration will ensure a DNS MX record does not exist when mandatory properties are specified.

        Note that the 'Priority' property value will be ignored when determining whether the record is to be removed.
#>

Configuration DnsRecordMx_Remove_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsRecordMx 'TestRecord'
        {
            ZoneName     = 'contoso.com'
            EmailDomain  = 'contoso.com'
            MailExchange = 'mailserver1.contoso.com'
            Priority     = 20
            Ensure       = 'Absent'
        }
    }
}
