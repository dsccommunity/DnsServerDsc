<#PSScriptInfo

.VERSION 1.0.1

.GUID 6b886caa-43ec-4a39-a9d5-84d819c5192b

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

Configuration DnsServerDiagnostics_RemoteNode_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerDiagnostics 'Diagnostics'
        {
            DnsServer                            = 'dns1.company.local'
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
