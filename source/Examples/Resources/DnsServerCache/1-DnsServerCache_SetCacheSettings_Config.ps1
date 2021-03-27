<#PSScriptInfo

.VERSION 1.0.0

.GUID 111f4eb8-c85f-4112-b8f2-f014420ec1ce

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
First version.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module DnsServerDsc

<#
    .DESCRIPTION
        This configuration will change the cache settings on the DNS server.
#>

Configuration DnsServerCache_SetCacheSettings_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerCache 'SetCacheSettings'
        {
            DnsServer                        = 'localhost'
            EnablePollutionProtection        = $true
            StoreEmptyAuthenticationResponse = $true
            IgnorePolicies                   = $false
            LockingPercent                   = 100
            MaxKBSize                        = 0
            MaxNegativeTtl                   = '00:15:00'
            MaxTtl                           = '1.00:00:00'
        }
    }
}
