<#PSScriptInfo

.VERSION 1.0.1

.GUID daed7803-24e2-4896-a366-37d061ae173d

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
        This configuration will manage the DNS server root hints
#>

Configuration xDnsServerRootHint_set_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerRootHint 'RootHints'
        {
            IsSingleInstance = 'Yes'
            NameServer       = @{
                'A.ROOT-SERVERS.NET.' = '2001:503:ba3e::2:30'
                'B.ROOT-SERVERS.NET.' = '2001:500:84::b'
                'C.ROOT-SERVERS.NET.' = '2001:500:2::c'
                'D.ROOT-SERVERS.NET.' = '2001:500:2d::d'
                'E.ROOT-SERVERS.NET.' = '192.203.230.10'
                'F.ROOT-SERVERS.NET.' = '2001:500:2f::f'
                'G.ROOT-SERVERS.NET.' = '192.112.36.4'
                'H.ROOT-SERVERS.NET.' = '2001:500:1::53'
                'I.ROOT-SERVERS.NET.' = '2001:7fe::53'
                'J.ROOT-SERVERS.NET.' = '2001:503:c27::2:30'
                'K.ROOT-SERVERS.NET.' = '2001:7fd::1'
                'L.ROOT-SERVERS.NET.' = '2001:500:9f::42'
                'M.ROOT-SERVERS.NET.' = '2001:dc3::353'
            }
        }
    }
}
