<#PSScriptInfo

.VERSION 1.0.1

.GUID e42d790f-5d6e-4ce8-ac4f-3b3a25a8afac

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
        This configuration will remove a specified DNS SRV record
#>

Configuration xDnsRecordSrv_Remove_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecordSrv 'RemoveTestRecord'
        {
            Zone         = 'contoso.com'
            SymbolicName = 'xmpp'
            Protocol     = 'tcp'
            Port         = 5222
            Target       = 'chat.contoso.com'
            Ensure       = 'Absent'
        }
    }
}
