<#PSScriptInfo

.VERSION 1.0.1

.GUID b31b9086-2153-49c9-8c53-90a0901f4588

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
        This configuration will ensure a DNS CNAME record exists when only the mandatory properties are specified.
#>

Configuration DnsRecordCnameScoped_Mandatory_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsRecordCnameScoped 'TestRecord'
        {
            ZoneName      = 'contoso.com'
            ZoneScope     = 'external'
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
            Ensure        = 'Present'
        }
    }
}
