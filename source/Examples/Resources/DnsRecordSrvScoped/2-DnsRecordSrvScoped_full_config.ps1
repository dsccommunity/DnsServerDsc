<#PSScriptInfo

.VERSION 1.0.1

.GUID d8bc6d0b-3a0e-4929-944a-3b25bf0d6bc5

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
        This configuration will ensure a DNS SRV record exists in the
        external scope for XMPP that points to chat.contoso.com with
        a priority of 20, weight of 50 and Time To Live of 5 hours.
#>

Configuration DnsRecordSrvScoped_full_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordSrvScoped 'TestRecord Full'
        {
            ZoneName     = 'contoso.com'
            ZoneScope    = 'external'
            SymbolicName = 'xmpp'
            Protocol     = 'tcp'
            Port         = 5222
            Target       = 'chat.contoso.com'
            Priority     = 20
            Weight       = 50
            TimeToLive   = '05:00:00'
            Ensure       = 'Present'
        }
    }
}
