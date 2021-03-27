<#PSScriptInfo

.VERSION 1.0.1

.GUID ea5de1b3-6167-4b3b-8de2-c57355d04202

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
        This configuration will ensure a DNS CNAME record exists when only the mandatory properties are specified.
#>

Configuration DnsRecordCname_Mandatory_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsRecordCname 'TestRecord'
        {
            ZoneName      = 'contoso.com'
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
            Ensure        = 'Present'
        }
    }
}
