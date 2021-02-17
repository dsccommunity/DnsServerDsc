<#PSScriptInfo

.VERSION 1.0.1

.GUID f8c91d9c-9463-4915-8e53-8f78d233148a

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/xDnsServer/blob/master/LICENSE

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
        This configuration will remove a DNS MX record
#>

Configuration xDnsRecordMx_Remove_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecordMx 'RemoveTestRecord'
        {
            Name     = '@'
            Target   = 'mail.contoso.com.'
            Zone     = 'contoso.com'
            Priority = 10
            Ensure   = 'Absent'
        }
    }
}
