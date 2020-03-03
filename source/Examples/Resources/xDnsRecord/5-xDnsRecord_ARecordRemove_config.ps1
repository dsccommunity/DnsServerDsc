<#PSScriptInfo

.VERSION 1.0.1

.GUID 7dfa3c15-9c74-4d87-a452-68cdb90b3742

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
        This configuration will remove a DNS A record
#>

Configuration xDnsRecord_ARecordRemove_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsRecord 'RemoveTestRecord'
        {
            Name   = 'testArecord'
            Target = '192.168.0.123'
            Zone   = 'contoso.com'
            Type   = 'ARecord'
            Ensure = 'Absent'
        }
    }
}
