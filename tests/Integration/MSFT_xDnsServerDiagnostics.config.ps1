
$ConfigurationData = @{
    AllNodes    = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath

            Name                                 = 'xDnsServerDiagnostics_Integration'
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

configuration MSFT_xDnsServerDiagnostics_SetDiagnostics_Config
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerDiagnostics 'Integration_Test'
        {
            Name                                 = $ConfigurationData.AllNodes.Name
            Answers                              = $ConfigurationData.AllNodes.Answers
            EnableLogFileRollover                = $ConfigurationData.AllNodes.EnableLogFileRollover
            EnableLoggingForLocalLookupEvent     = $ConfigurationData.AllNodes.EnableLoggingForLocalLookupEvent
            EnableLoggingForPluginDllEvent       = $ConfigurationData.AllNodes.EnableLoggingForPluginDllEvent
            EnableLoggingForRecursiveLookupEvent = $ConfigurationData.AllNodes.EnableLoggingForRecursiveLookupEvent
            EnableLoggingForRemoteServerEvent    = $ConfigurationData.AllNodes.EnableLoggingForRemoteServerEvent
            EnableLoggingForServerStartStopEvent = $ConfigurationData.AllNodes.EnableLoggingForServerStartStopEvent
            EnableLoggingForTombstoneEvent       = $ConfigurationData.AllNodes.EnableLoggingForTombstoneEvent
            EnableLoggingForZoneDataWriteEvent   = $ConfigurationData.AllNodes.EnableLoggingForZoneDataWriteEvent
            EnableLoggingForZoneLoadingEvent     = $ConfigurationData.AllNodes.EnableLoggingForZoneLoadingEvent
            EnableLoggingToFile                  = $ConfigurationData.AllNodes.EnableLoggingToFile
            EventLogLevel                        = $ConfigurationData.AllNodes.EventLogLevel
            FilterIPAddressList                  = $ConfigurationData.AllNodes.FilterIPAddressList
            FullPackets                          = $ConfigurationData.AllNodes.FullPackets
            LogFilePath                          = $ConfigurationData.AllNodes.LogFilePath
            MaxMBFileSize                        = $ConfigurationData.AllNodes.MaxMBFileSize
            Notifications                        = $ConfigurationData.AllNodes.Notifications
            Queries                              = $ConfigurationData.AllNodes.Queries
            QuestionTransactions                 = $ConfigurationData.AllNodes.QuestionTransactions
            ReceivePackets                       = $ConfigurationData.AllNodes.ReceivePackets
            SaveLogsToPersistentStorage          = $ConfigurationData.AllNodes.SaveLogsToPersistentStorage
            SendPackets                          = $ConfigurationData.AllNodes.SendPackets
            TcpPackets                           = $ConfigurationData.AllNodes.TcpPackets
            UdpPackets                           = $ConfigurationData.AllNodes.UdpPackets
            UnmatchedResponse                    = $ConfigurationData.AllNodes.UnmatchedResponse
            Update                               = $ConfigurationData.AllNodes.Update
            UseSystemEventLog                    = $ConfigurationData.AllNodes.UseSystemEventLog
            WriteThrough                         = $ConfigurationData.AllNodes.WriteThrough
        }
    }
}
