<#PSScriptInfo

.VERSION 1.0.1

.GUID b156bf8d-688c-4648-9c91-12a3779d411f

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
        This configuration will ensure a DNS SRV record exists for
        XMPP that points to chat.contoso.com with a priority of 20,
        weight of 50 and TTL of 5 hours.
#>

Configuration xDnsRecordSrv_full_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecordSrv 'TestRecord Full'
        {
            Zone         = 'contoso.com'
            SymbolicName = 'xmpp'
            Protocol     = 'tcp'
            Port         = 5222
            Target       = 'chat.contoso.com'
            Priority     = 20
            Weight       = 50
            TTL          = '05:00:00'
            Ensure       = 'Present'
        }
    }
}
