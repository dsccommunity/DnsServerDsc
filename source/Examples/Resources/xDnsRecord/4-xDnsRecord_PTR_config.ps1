<#PSScriptInfo

.VERSION 1.0.1

.GUID 21a1ac4b-4e61-49fc-a279-416b9e06ea29

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
        This configuration will manage a DNS PTR record
#>

Configuration xDnsRecord_PTR_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecord 'TestPtrRecord'
        {
            Name   = '123'
            Target = 'TestA.contoso.com'
            Zone   = '0.168.192.in-addr.arpa'
            Type   = 'PTR'
            Ensure = 'Present'
        }
    }
}
