<#PSScriptInfo

.VERSION 1.0.1

.GUID bbf58485-9b5f-4b67-865a-195f0c32c4df

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
        This configuration will manage a DNS MX record
#>

Configuration xDnsRecordMx_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecordMx 'TestRecord'
        {
            Name       = '.'
            Target     = 'mail.contoso.com'
            Zone       = 'contoso.com'
            Priority   = 10
            TTL        = '01:00:00'
            Ensure     = 'Present'
        }
    }
}
