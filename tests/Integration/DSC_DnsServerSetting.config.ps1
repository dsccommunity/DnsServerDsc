$availableIpAddresses = Get-NetIPInterface -AddressFamily IPv4 -Dhcp Disabled |
    Get-NetIPAddress |
    Where-Object IPAddress -ne ([IPAddress]::Loopback)

Write-Verbose -Message ('Available IPv4 network interfaces on build worker: {0}' -f (($availableIpAddresses | Select-Object -Property IPAddress, InterfaceAlias, AddressFamily) | Out-String)) -Verbose

$firstIpAddress = $availableIpAddresses | Select-Object -ExpandProperty IPAddress -First 1

Write-Verbose -Message ('Using IP address ''{0}'' for the integration test as first listening IP address.' -f $firstIpAddress) -Verbose

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                  = 'localhost'
            CertificateFile           = $env:DscPublicCertificatePath
            DnsServer                 = 'localhost'
            AddressAnswerLimit        = 5
            AllowUpdate               = $false
            AutoCacheUpdate           = $true
            AutoConfigFileZones       = 2
            BindSecondaries           = $true
            BootMethod                = 2
            DisableAutoReverseZone    = $true
            EnableDirectoryPartitions = $true
            EnableDnsSec              = $false
            ForwardDelegations        = $true
            <#
                At least one of the listening IP addresses that is specified must
                be present on a network interface on the host running the test.
            #>
            ListeningIPAddress        = @($firstIpAddress, '10.0.0.10')
            LocalNetPriority          = $false
            LooseWildcarding          = $true
            NameCheckFlag             = 1
            RoundRobin                = $false
            RpcProtocol               = 4
            SendPort                  = 100
            StrictFileParsing         = $true
            UpdateOptions             = 784
            WriteAuthorityNS          = $true
            XfrConnectTimeout         = 40
            ServerLevelPluginDll      = 'C:\temp\plugin.dll'

            # AdminConfigured                         : True
            # AllowCnameAtNs                          : True
            # AllowReadOnlyZoneTransfer               : False
            # AppendMsZoneTransferTag                 : False
            # AutoCreateDelegation                    : 2
            # DeleteOutsideGlue                       : False
            # EnableDuplicateQuerySuppression         : True
            # EnableIPv6                              : True
            # EnableIQueryResponseGeneration          : False
            # EnableOnlineSigning                     : True
            # EnableRsoForRodc                        : True
            # EnableSendErrorSuppression              : True
            # EnableUpdateForwarding                  : False
            # EnableVersionQuery                      : 0
            # EnableWinsR                             : True
            # IgnoreAllPolicies                       : False
            # IgnoreServerLevelPolicies               : False
            # IsReadOnlyDC                            : False
            # LameDelegationTTL                       : 00:00:00
            # LocalNetPriorityMask                    : 255
            # MaximumRodcRsoAttemptsPerCycle          : 100
            # MaximumRodcRsoQueueLength               : 300
            # MaximumSignatureScanPeriod              : 2.00:00:00
            # MaximumTrustAnchorActiveRefreshInterval : 15.00:00:00
            # MaximumUdpPacketSize                    : 4000
            # MaxResourceRecordsInNonSecureUpdate     : 30
            # NoUpdateDelegations                     : False
            # OpenAclOnProxyUpdates                   : True
            # PublishAutoNet                          : False
            # QuietRecvFaultInterval                  : 0
            # QuietRecvLogInterval                    : 0
            # ReloadException                         : False
            # RemoteIPv4RankBoost                     : 5
            # RemoteIPv6RankBoost                     : 0
            # RootTrustAnchorsURL                     : https://data.iana.org/root-anchors/root-anchors.xml
            # ScopeOptionValue                        : 0
            # SelfTest                                : 4294967295
            # SilentlyIgnoreCnameUpdateConflicts      : False
            # SocketPoolExcludedPortRanges            : {}
            # SocketPoolSize                          : 2500
            # SyncDsZoneSerial                        : 2
            # TcpReceivePacketSize                    : 65536
            # VirtualizationInstanceOptionValue       : 0
            # XfrThrottleMultiplier                   : 10
            # ZoneWritebackInterval                   : 00:01:00
        }
    )
}

Configuration DSC_DnsServerSetting_SetSettings_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerSetting 'Integration_Test'
        {

            DnsServer                 = $Node.DnsServer
            AddressAnswerLimit        = $Node.AddressAnswerLimit
            AllowUpdate               = $Node.AllowUpdate
            AutoCacheUpdate           = $Node.AutoCacheUpdate
            AutoConfigFileZones       = $Node.AutoConfigFileZones
            BindSecondaries           = $Node.BindSecondaries
            BootMethod                = $Node.BootMethod
            DisableAutoReverseZone    = $Node.DisableAutoReverseZone
            EnableDirectoryPartitions = $Node.EnableDirectoryPartitions
            EnableDnsSec              = $Node.EnableDnsSec
            ForwardDelegations        = $Node.ForwardDelegations
            ListeningIPAddress        = $Node.ListeningIPAddress
            LocalNetPriority          = $Node.LocalNetPriority
            LooseWildcarding          = $Node.LooseWildcarding
            NameCheckFlag             = $Node.NameCheckFlag
            RoundRobin                = $Node.RoundRobin
            RpcProtocol               = $Node.RpcProtocol
            SendPort                  = $Node.SendPort
            StrictFileParsing         = $Node.StrictFileParsing
            UpdateOptions             = $Node.UpdateOptions
            WriteAuthorityNS          = $Node.WriteAuthorityNS
            XfrConnectTimeout         = $Node.XfrConnectTimeout
        }
    }
}
