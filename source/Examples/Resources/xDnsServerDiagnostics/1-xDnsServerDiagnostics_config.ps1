<#PSScriptInfo
.VERSION 1.0.0
.GUID 5078427f-0fae-40a6-af63-2601a96a832c
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
        This configuration will manage a DNS server's diagnostics settings
#>

Configuration xDnsServerDiagnostics_config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerDiagnostics 'Diagnostics'
        {
            Name                                 = 'Diagnostics'
            Answers                              = $true
            EnableLogFileRollover                = $true
            EnableLoggingForLocalLookupEvent     = $true
            EnableLoggingForPluginDllEvent       = $true
            EnableLoggingForRecursiveLookupEvent = $true
            EnableLoggingForRemoteServerEvent    = $true
            EnableLoggingForServerStartStopEvent = $true
            EnableLoggingForTombstoneEvent       = $true
            EnableLoggingForZoneDataWriteEvent   = $true
            EnableLoggingForZoneLoadingEvent     = $true
            EnableLoggingToFile                  = $true
            EventLogLevel                        = 7
            FilterIPAddressList                  = @('10.0.10.1', '10.0.10.2')
            FullPackets                          = $false
            LogFilePath                          = 'd:\dnslogs\dns.log'
            MaxMBFileSize                        = 500000000
            Notifications                        = $true
            Queries                              = $true
            QuestionTransactions                 = $true
            ReceivePackets                       = $false
            SaveLogsToPersistentStorage          = $true
            SendPackets                          = $false
            TcpPackets                           = $false
            UdpPackets                           = $false
            UnmatchedResponse                    = $false
            Update                               = $true
            UseSystemEventLog                    = $true
            WriteThrough                         = $true
        }
    }
}
