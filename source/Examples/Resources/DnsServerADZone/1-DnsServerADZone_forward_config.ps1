<#PSScriptInfo

.VERSION 1.0.1

.GUID 29742cc1-70f3-48e3-9494-f454afe77283

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
        This configuration will manage an AD integrated DNS forward lookup zone
#>

Configuration DnsServerADZone_forward_config
{
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerADZone 'AddForwardADZone'
        {
            Name             = 'MyDomainName.com'
            DynamicUpdate    = 'Secure'
            ReplicationScope = 'Forest'
            ComputerName     = 'MyDnsServer.MyDomain.com'
            Credential       = $Credential
            Ensure           = 'Present'
        }
    }
}
