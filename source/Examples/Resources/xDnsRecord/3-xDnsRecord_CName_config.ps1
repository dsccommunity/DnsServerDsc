<#PSScriptInfo
.VERSION 1.0.0
.GUID aeaa77d8-04da-411a-947a-af5abb6249e8
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/xDnsServer/blob/master/LICENSE
.PROJECTURI https://github.com/Powershell/xDnsServer
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module xDnsServer

<#
    .DESCRIPTION
        This configuration will manage a DNS CName record
#>

Configuration xDnsRecord_CName_config
{
    Import-DscResource -Module xDnsServer

    Node localhost
    {
        xDnsRecord TestCNameRecord
        {
            Name   = "testCName"
            Target = "test.contoso.com"
            Zone   = "contoso.com"
            Type   = "CName"
            Ensure = "Present"
        }
    }
}
