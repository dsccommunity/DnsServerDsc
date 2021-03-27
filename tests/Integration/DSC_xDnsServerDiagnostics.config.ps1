$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                             = 'localhost'
            CertificateFile                      = $env:DscPublicCertificatePath

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
            EventLogLevel                        = 4
            FilterIPAddressList                  = @('192.168.1.1', '192.168.1.2')
            FullPackets                          = $true
            LogFilePath                          = 'C:\Windows\System32\DNS\DNSDiagnostics.log'
            MaxMBFileSize                        = 500000000
            Notifications                        = $true
            Queries                              = $true
            QuestionTransactions                 = $true
            ReceivePackets                       = $true
            SaveLogsToPersistentStorage          = $true
            SendPackets                          = $true
            TcpPackets                           = $true
            UdpPackets                           = $true
            UnmatchedResponse                    = $true
            Update                               = $true
            UseSystemEventLog                    = $true
            WriteThrough                         = $true
        }
    )
}

configuration DSC_xDnsServerDiagnostics_SetDiagnostics_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerDiagnostics 'Integration_Test'
        {
            DnsServer                            = $Node.DnsServer
            Answers                              = $Node.Answers
            EnableLogFileRollover                = $Node.EnableLogFileRollover
            EnableLoggingForLocalLookupEvent     = $Node.EnableLoggingForLocalLookupEvent
            EnableLoggingForPluginDllEvent       = $Node.EnableLoggingForPluginDllEvent
            EnableLoggingForRecursiveLookupEvent = $Node.EnableLoggingForRecursiveLookupEvent
            EnableLoggingForRemoteServerEvent    = $Node.EnableLoggingForRemoteServerEvent
            EnableLoggingForServerStartStopEvent = $Node.EnableLoggingForServerStartStopEvent
            EnableLoggingForTombstoneEvent       = $Node.EnableLoggingForTombstoneEvent
            EnableLoggingForZoneDataWriteEvent   = $Node.EnableLoggingForZoneDataWriteEvent
            EnableLoggingForZoneLoadingEvent     = $Node.EnableLoggingForZoneLoadingEvent
            EnableLoggingToFile                  = $Node.EnableLoggingToFile
            EventLogLevel                        = $Node.EventLogLevel
            FilterIPAddressList                  = $Node.FilterIPAddressList
            FullPackets                          = $Node.FullPackets
            LogFilePath                          = $Node.LogFilePath
            MaxMBFileSize                        = $Node.MaxMBFileSize
            Notifications                        = $Node.Notifications
            Queries                              = $Node.Queries
            QuestionTransactions                 = $Node.QuestionTransactions
            ReceivePackets                       = $Node.ReceivePackets
            SaveLogsToPersistentStorage          = $Node.SaveLogsToPersistentStorage
            SendPackets                          = $Node.SendPackets
            TcpPackets                           = $Node.TcpPackets
            UdpPackets                           = $Node.UdpPackets
            UnmatchedResponse                    = $Node.UnmatchedResponse
            Update                               = $Node.Update
            UseSystemEventLog                    = $Node.UseSystemEventLog
            WriteThrough                         = $Node.WriteThrough
        }
    }
}
