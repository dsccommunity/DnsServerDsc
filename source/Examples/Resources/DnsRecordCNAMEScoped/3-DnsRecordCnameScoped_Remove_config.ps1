<#PSScriptInfo

.VERSION 1.0.1

.GUID b9c01d28-d608-43ce-b5c1-4baf57ea3118

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
        This configuration will ensure a DNS CNAME record does not exist when mandatory properties are specified.
#>

Configuration DnsRecordCnameScoped_Remove_config
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
            Ensure        = 'Absent'
        }
    }
}
