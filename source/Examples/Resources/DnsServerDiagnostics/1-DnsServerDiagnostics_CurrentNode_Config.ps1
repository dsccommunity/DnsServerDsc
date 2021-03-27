<#PSScriptInfo

.VERSION 1.0.1

.GUID 5078427f-0fae-40a6-af63-2601a96a832c

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
        This configuration will manage a DNS server's diagnostics settings
#>

Configuration DnsServerDiagnostics_CurrentNode_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerDiagnostics 'Diagnostics'
        {
            DnsServer                            = 'localhost'
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
