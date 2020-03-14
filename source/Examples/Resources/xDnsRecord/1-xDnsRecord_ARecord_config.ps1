<#PSScriptInfo

.VERSION 1.0.1

.GUID 5ce8253d-5de2-436b-a426-b28e56d396f2

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
        This configuration will manage a DNS A record
#>

Configuration xDnsRecord_ARecord_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecord 'TestRecord'
        {
            Name   = 'testArecord'
            Target = '192.168.0.123'
            Zone   = 'contoso.com'
            Type   = 'ARecord'
            Ensure = 'Present'
        }
    }
}
