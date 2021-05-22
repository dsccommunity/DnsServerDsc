$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceFriendlyName = 'DnsServerSetting'
$script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

try
{
    #region Integration Tests
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"

            # This will be used to set the settings back to the original values.
            $originalConfigurationData = @{
                AllNodes = @()
            }
        }

        Context ('When using Invoke-DscResource to get current state') {
            It 'Should get the values of the current state without throwing' {
                {
                    $invokeDscResourceParameters = @{
                        Name        = $script:dscResourceFriendlyName
                        ModuleName  = $script:dscModuleName
                        Method      = 'Get'
                        Property    = @{
                            DnsServer = 'localhost'
                        }
                        ErrorAction = 'Stop'
                    }

                    $originalPropertyValues = Invoke-DscResource @invokeDscResourceParameters

                    $originalPropertyText = ($originalPropertyValues | Out-String) -replace '\r?\n', "`n"

                    Write-Verbose -Message ("Current state values:`n{0}" -f $originalPropertyText) -Verbose

                    # Save all current values so that they can be set back at the end of the test.
                    $originalConfigurationData.AllNodes += @{
                        NodeName                                = 'localhost'
                        CertificateFile                         = $env:DscPublicCertificatePath
                        DnsServer                               = 'localhost'

                        AddressAnswerLimit                      = $originalPropertyValues.AddressAnswerLimit
                        AllowUpdate                             = $originalPropertyValues.AllowUpdate
                        AutoCacheUpdate                         = $originalPropertyValues.AutoCacheUpdate
                        AutoConfigFileZones                     = $originalPropertyValues.AutoConfigFileZones
                        BindSecondaries                         = $originalPropertyValues.BindSecondaries
                        BootMethod                              = $originalPropertyValues.BootMethod
                        DisableAutoReverseZone                  = $originalPropertyValues.DisableAutoReverseZone
                        EnableDirectoryPartitions               = $originalPropertyValues.EnableDirectoryPartitions
                        EnableDnsSec                            = $originalPropertyValues.EnableDnsSec
                        ForwardDelegations                      = $originalPropertyValues.ForwardDelegations
                        ListeningIPAddress                      = $originalPropertyValues.ListeningIPAddress
                        LocalNetPriority                        = $originalPropertyValues.LocalNetPriority
                        LooseWildcarding                        = $originalPropertyValues.LooseWildcarding
                        NameCheckFlag                           = $originalPropertyValues.NameCheckFlag
                        RoundRobin                              = $originalPropertyValues.RoundRobin
                        RpcProtocol                             = $originalPropertyValues.RpcProtocol
                        SendPort                                = $originalPropertyValues.SendPort
                        StrictFileParsing                       = $originalPropertyValues.StrictFileParsing
                        UpdateOptions                           = $originalPropertyValues.UpdateOptions
                        WriteAuthorityNS                        = $originalPropertyValues.WriteAuthorityNS
                        XfrConnectTimeout                       = $originalPropertyValues.XfrConnectTimeout
                        ServerLevelPluginDll                    = $originalPropertyValues.ServerLevelPluginDll
                        AdminConfigured                         = $originalPropertyValues.AdminConfigured
                        AllowCnameAtNs                          = $originalPropertyValues.AllowCnameAtNs
                        AllowReadOnlyZoneTransfer               = $originalPropertyValues.AllowReadOnlyZoneTransfer
                        AppendMsZoneTransferTag                 = $originalPropertyValues.AppendMsZoneTransferTag
                        AutoCreateDelegation                    = $originalPropertyValues.AutoCreateDelegation
                        DeleteOutsideGlue                       = $originalPropertyValues.DeleteOutsideGlue
                        EnableDuplicateQuerySuppression         = $originalPropertyValues.EnableDuplicateQuerySuppression
                        EnableIPv6                              = $originalPropertyValues.EnableIPv6
                        EnableIQueryResponseGeneration          = $originalPropertyValues.EnableIQueryResponseGeneration
                        EnableOnlineSigning                     = $originalPropertyValues.EnableOnlineSigning
                        EnableRsoForRodc                        = $originalPropertyValues.EnableRsoForRodc
                        EnableSendErrorSuppression              = $originalPropertyValues.EnableSendErrorSuppression
                        EnableUpdateForwarding                  = $originalPropertyValues.EnableUpdateForwarding
                        EnableVersionQuery                      = $originalPropertyValues.EnableVersionQuery
                        EnableWinsR                             = $originalPropertyValues.EnableWinsR
                        IgnoreAllPolicies                       = $originalPropertyValues.IgnoreAllPolicies
                        IgnoreServerLevelPolicies               = $originalPropertyValues.IgnoreServerLevelPolicies
                        IsReadOnlyDC                            = $originalPropertyValues.IsReadOnlyDC
                        LameDelegationTTL                       = $originalPropertyValues.LameDelegationTTL
                        LocalNetPriorityMask                    = $originalPropertyValues.LocalNetPriorityMask
                        MaximumRodcRsoAttemptsPerCycle          = $originalPropertyValues.MaximumRodcRsoAttemptsPerCycle
                        MaximumRodcRsoQueueLength               = $originalPropertyValues.MaximumRodcRsoQueueLength
                        MaximumSignatureScanPeriod              = $originalPropertyValues.MaximumSignatureScanPeriod
                        MaximumTrustAnchorActiveRefreshInterval = $originalPropertyValues.MaximumTrustAnchorActiveRefreshInterval
                        MaximumUdpPacketSize                    = $originalPropertyValues.MaximumUdpPacketSize
                        MaxResourceRecordsInNonSecureUpdate     = $originalPropertyValues.MaxResourceRecordsInNonSecureUpdate
                        NoUpdateDelegations                     = $originalPropertyValues.NoUpdateDelegations
                        OpenAclOnProxyUpdates                   = $originalPropertyValues.OpenAclOnProxyUpdates
                        PublishAutoNet                          = $originalPropertyValues.PublishAutoNet
                        QuietRecvFaultInterval                  = $originalPropertyValues.QuietRecvFaultInterval
                        QuietRecvLogInterval                    = $originalPropertyValues.QuietRecvLogInterval
                        ReloadException                         = $originalPropertyValues.ReloadException
                        RemoteIPv4RankBoost                     = $originalPropertyValues.RemoteIPv4RankBoost
                        RemoteIPv6RankBoost                     = $originalPropertyValues.RemoteIPv6RankBoost
                        RootTrustAnchorsURL                     = $originalPropertyValues.RootTrustAnchorsURL
                        ScopeOptionValue                        = $originalPropertyValues.ScopeOptionValue
                        SelfTest                                = $originalPropertyValues.SelfTest
                        SilentlyIgnoreCnameUpdateConflicts      = $originalPropertyValues.SilentlyIgnoreCnameUpdateConflicts
                        SocketPoolExcludedPortRanges            = $originalPropertyValues.SocketPoolExcludedPortRanges
                        SocketPoolSize                          = $originalPropertyValues.SocketPoolSize
                        SyncDsZoneSerial                        = $originalPropertyValues.SyncDsZoneSerial
                        TcpReceivePacketSize                    = $originalPropertyValues.TcpReceivePacketSize
                        VirtualizationInstanceOptionValue       = $originalPropertyValues.VirtualizationInstanceOptionValue
                        XfrThrottleMultiplier                   = $originalPropertyValues.XfrThrottleMultiplier
                        ZoneWritebackInterval                   = $originalPropertyValues.ZoneWritebackInterval
                    }
                } | Should -Not -Throw
            }
        }

        Wait-ForIdleLcm -Clear

        $configurationName = "$($script:dscResourceName)_SetSettings_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.DnsServer                               | Should -Be $ConfigurationData.AllNodes.DnsServer
                $resourceCurrentState.AddressAnswerLimit                      | Should -Be $ConfigurationData.AllNodes.AddressAnswerLimit
                $resourceCurrentState.AllowUpdate                             | Should -Be $ConfigurationData.AllNodes.AllowUpdate
                $resourceCurrentState.AutoCacheUpdate                         | Should -Be $ConfigurationData.AllNodes.AutoCacheUpdate
                $resourceCurrentState.AutoConfigFileZones                     | Should -Be $ConfigurationData.AllNodes.AutoConfigFileZones
                $resourceCurrentState.BindSecondaries                         | Should -Be $ConfigurationData.AllNodes.BindSecondaries
                $resourceCurrentState.BootMethod                              | Should -Be $ConfigurationData.AllNodes.BootMethod
                $resourceCurrentState.DisableAutoReverseZone                  | Should -Be $ConfigurationData.AllNodes.DisableAutoReverseZone
                $resourceCurrentState.EnableDirectoryPartitions               | Should -Be $ConfigurationData.AllNodes.EnableDirectoryPartitions
                $resourceCurrentState.EnableDnsSec                            | Should -Be $ConfigurationData.AllNodes.EnableDnsSec
                $resourceCurrentState.ListeningIPAddress                      | Should -Be $ConfigurationData.AllNodes.ListeningIPAddress
                $resourceCurrentState.ForwardDelegations                      | Should -Be $ConfigurationData.AllNodes.ForwardDelegations
                $resourceCurrentState.LocalNetPriority                        | Should -Be $ConfigurationData.AllNodes.LocalNetPriority
                $resourceCurrentState.LooseWildcarding                        | Should -Be $ConfigurationData.AllNodes.LooseWildcarding
                $resourceCurrentState.NameCheckFlag                           | Should -Be $ConfigurationData.AllNodes.NameCheckFlag
                $resourceCurrentState.RoundRobin                              | Should -Be $ConfigurationData.AllNodes.RoundRobin
                $resourceCurrentState.RpcProtocol                             | Should -Be $ConfigurationData.AllNodes.RpcProtocol
                $resourceCurrentState.SendPort                                | Should -Be $ConfigurationData.AllNodes.SendPort
                $resourceCurrentState.StrictFileParsing                       | Should -Be $ConfigurationData.AllNodes.StrictFileParsing
                $resourceCurrentState.UpdateOptions                           | Should -Be $ConfigurationData.AllNodes.UpdateOptions
                $resourceCurrentState.WriteAuthorityNS                        | Should -Be $ConfigurationData.AllNodes.WriteAuthorityNS
                $resourceCurrentState.XfrConnectTimeout                       | Should -Be $ConfigurationData.AllNodes.XfrConnectTimeout
                $resourceCurrentState.ServerLevelPluginDll                    | Should -Be $ConfigurationData.AllNodes.ServerLevelPluginDll
                $resourceCurrentState.AdminConfigured                         | Should -Be $ConfigurationData.AllNodes.AllowCnameAtNs
                $resourceCurrentState.AllowCnameAtNs                          | Should -Be $ConfigurationData.AllNodes.ServerLevelPluginDll
                $resourceCurrentState.AllowReadOnlyZoneTransfer               | Should -Be $ConfigurationData.AllNodes.AllowReadOnlyZoneTransfer
                $resourceCurrentState.AppendMsZoneTransferTag                 | Should -Be $ConfigurationData.AllNodes.AppendMsZoneTransferTag
                $resourceCurrentState.AutoCreateDelegation                    | Should -Be $ConfigurationData.AllNodes.AutoCreateDelegation
                $resourceCurrentState.DeleteOutsideGlue                       | Should -Be $ConfigurationData.AllNodes.DeleteOutsideGlue
                $resourceCurrentState.EnableDuplicateQuerySuppression         | Should -Be $ConfigurationData.AllNodes.EnableDuplicateQuerySuppression
                $resourceCurrentState.EnableIPv6                              | Should -Be $ConfigurationData.AllNodes.EnableIPv6
                $resourceCurrentState.EnableIQueryResponseGeneration          | Should -Be $ConfigurationData.AllNodes.EnableIQueryResponseGeneration
                $resourceCurrentState.EnableOnlineSigning                     | Should -Be $ConfigurationData.AllNodes.EnableOnlineSigning
                $resourceCurrentState.EnableRsoForRodc                        | Should -Be $ConfigurationData.AllNodes.EnableRsoForRodc
                $resourceCurrentState.EnableSendErrorSuppression              | Should -Be $ConfigurationData.AllNodes.EnableSendErrorSuppression
                $resourceCurrentState.EnableUpdateForwarding                  | Should -Be $ConfigurationData.AllNodes.EnableUpdateForwarding
                $resourceCurrentState.EnableVersionQuery                      | Should -Be $ConfigurationData.AllNodes.EnableVersionQuery
                $resourceCurrentState.EnableWinsR                             | Should -Be $ConfigurationData.AllNodes.EnableWinsR
                $resourceCurrentState.IgnoreAllPolicies                       | Should -Be $ConfigurationData.AllNodes.IgnoreAllPolicies
                $resourceCurrentState.IgnoreServerLevelPolicies               | Should -Be $ConfigurationData.AllNodes.IgnoreServerLevelPolicies
                $resourceCurrentState.IsReadOnlyDC                            | Should -Be $ConfigurationData.AllNodes.IsReadOnlyDC
                $resourceCurrentState.LameDelegationTTL                       | Should -Be $ConfigurationData.AllNodes.LameDelegationTTL
                $resourceCurrentState.LocalNetPriorityMask                    | Should -Be $ConfigurationData.AllNodes.LocalNetPriorityMask
                $resourceCurrentState.MaximumRodcRsoAttemptsPerCycle          | Should -Be $ConfigurationData.AllNodes.MaximumRodcRsoAttemptsPerCycle
                $resourceCurrentState.MaximumRodcRsoQueueLength               | Should -Be $ConfigurationData.AllNodes.MaximumRodcRsoQueueLength
                $resourceCurrentState.MaximumSignatureScanPeriod              | Should -Be $ConfigurationData.AllNodes.MaximumSignatureScanPeriod
                $resourceCurrentState.MaximumTrustAnchorActiveRefreshInterval | Should -Be $ConfigurationData.AllNodes.MaximumTrustAnchorActiveRefreshInterval
                $resourceCurrentState.MaximumUdpPacketSize                    | Should -Be $ConfigurationData.AllNodes.MaximumUdpPacketSize
                $resourceCurrentState.MaxResourceRecordsInNonSecureUpdate     | Should -Be $ConfigurationData.AllNodes.MaxResourceRecordsInNonSecureUpdate
                $resourceCurrentState.NoUpdateDelegations                     | Should -Be $ConfigurationData.AllNodes.NoUpdateDelegations
                $resourceCurrentState.OpenAclOnProxyUpdates                   | Should -Be $ConfigurationData.AllNodes.OpenAclOnProxyUpdates
                $resourceCurrentState.PublishAutoNet                          | Should -Be $ConfigurationData.AllNodes.PublishAutoNet
                $resourceCurrentState.QuietRecvFaultInterval                  | Should -Be $ConfigurationData.AllNodes.QuietRecvFaultInterval
                $resourceCurrentState.QuietRecvLogInterval                    | Should -Be $ConfigurationData.AllNodes.QuietRecvLogInterval
                $resourceCurrentState.ReloadException                         | Should -Be $ConfigurationData.AllNodes.ReloadException
                $resourceCurrentState.RemoteIPv4RankBoost                     | Should -Be $ConfigurationData.AllNodes.RemoteIPv4RankBoost
                $resourceCurrentState.RemoteIPv6RankBoost                     | Should -Be $ConfigurationData.AllNodes.RemoteIPv6RankBoost
                $resourceCurrentState.RootTrustAnchorsURL                     | Should -Be $ConfigurationData.AllNodes.RootTrustAnchorsURL
                $resourceCurrentState.ScopeOptionValue                        | Should -Be $ConfigurationData.AllNodes.ScopeOptionValue
                $resourceCurrentState.SelfTest                                | Should -Be $ConfigurationData.AllNodes.SelfTest
                $resourceCurrentState.SilentlyIgnoreCnameUpdateConflicts      | Should -Be $ConfigurationData.AllNodes.SilentlyIgnoreCnameUpdateConflicts
                $resourceCurrentState.SocketPoolExcludedPortRanges            | Should -Be $ConfigurationData.AllNodes.SocketPoolExcludedPortRanges
                $resourceCurrentState.SocketPoolSize                          | Should -Be $ConfigurationData.AllNodes.SocketPoolSize
                $resourceCurrentState.SyncDsZoneSerial                        | Should -Be $ConfigurationData.AllNodes.SyncDsZoneSerial
                $resourceCurrentState.TcpReceivePacketSize                    | Should -Be $ConfigurationData.AllNodes.TcpReceivePacketSize
                $resourceCurrentState.VirtualizationInstanceOptionValue       | Should -Be $ConfigurationData.AllNodes.VirtualizationInstanceOptionValue
                $resourceCurrentState.XfrThrottleMultiplier                   | Should -Be $ConfigurationData.AllNodes.XfrThrottleMultiplier
                $resourceCurrentState.ZoneWritebackInterval                   | Should -Be $ConfigurationData.AllNodes.ZoneWritebackInterval
            }

            It 'Should return ''True'' when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Wait-ForIdleLcm -Clear

        <#
            This is using the same configuration, but the configuration data is
            switch before running the configuration, to be able to revert back
            to the original values! NOTE: This must always be the
            last test for this resource!
        #>
        Context ('When using configuration {0} to revert to original values' -f $configurationName) {
            BeforeAll {
                # Switch to configuration data that holds the original values.
                $ConfigurationData = $originalConfigurationData
            }

            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.DnsServer                               | Should -Be $ConfigurationData.AllNodes.DnsServer
                $resourceCurrentState.AddressAnswerLimit                      | Should -Be $ConfigurationData.AllNodes.AddressAnswerLimit
                $resourceCurrentState.AllowUpdate                             | Should -Be $ConfigurationData.AllNodes.AllowUpdate
                $resourceCurrentState.AutoCacheUpdate                         | Should -Be $ConfigurationData.AllNodes.AutoCacheUpdate
                $resourceCurrentState.AutoConfigFileZones                     | Should -Be $ConfigurationData.AllNodes.AutoConfigFileZones
                $resourceCurrentState.BindSecondaries                         | Should -Be $ConfigurationData.AllNodes.BindSecondaries
                $resourceCurrentState.BootMethod                              | Should -Be $ConfigurationData.AllNodes.BootMethod
                $resourceCurrentState.DisableAutoReverseZone                  | Should -Be $ConfigurationData.AllNodes.DisableAutoReverseZone
                $resourceCurrentState.EnableDirectoryPartitions               | Should -Be $ConfigurationData.AllNodes.EnableDirectoryPartitions
                $resourceCurrentState.EnableDnsSec                            | Should -Be $ConfigurationData.AllNodes.EnableDnsSec
                $resourceCurrentState.ListeningIPAddress                      | Should -Be $ConfigurationData.AllNodes.ListeningIPAddress
                $resourceCurrentState.ForwardDelegations                      | Should -Be $ConfigurationData.AllNodes.ForwardDelegations
                $resourceCurrentState.LocalNetPriority                        | Should -Be $ConfigurationData.AllNodes.LocalNetPriority
                $resourceCurrentState.LooseWildcarding                        | Should -Be $ConfigurationData.AllNodes.LooseWildcarding
                $resourceCurrentState.NameCheckFlag                           | Should -Be $ConfigurationData.AllNodes.NameCheckFlag
                $resourceCurrentState.RoundRobin                              | Should -Be $ConfigurationData.AllNodes.RoundRobin
                $resourceCurrentState.RpcProtocol                             | Should -Be $ConfigurationData.AllNodes.RpcProtocol
                $resourceCurrentState.SendPort                                | Should -Be $ConfigurationData.AllNodes.SendPort
                $resourceCurrentState.StrictFileParsing                       | Should -Be $ConfigurationData.AllNodes.StrictFileParsing
                $resourceCurrentState.UpdateOptions                           | Should -Be $ConfigurationData.AllNodes.UpdateOptions
                $resourceCurrentState.WriteAuthorityNS                        | Should -Be $ConfigurationData.AllNodes.WriteAuthorityNS
                $resourceCurrentState.XfrConnectTimeout                       | Should -Be $ConfigurationData.AllNodes.XfrConnectTimeout
                $resourceCurrentState.ServerLevelPluginDll                    | Should -Be $ConfigurationData.AllNodes.ServerLevelPluginDll
                $resourceCurrentState.AdminConfigured                         | Should -Be $ConfigurationData.AllNodes.AllowCnameAtNs
                $resourceCurrentState.AllowCnameAtNs                          | Should -Be $ConfigurationData.AllNodes.ServerLevelPluginDll
                $resourceCurrentState.AllowReadOnlyZoneTransfer               | Should -Be $ConfigurationData.AllNodes.AllowReadOnlyZoneTransfer
                $resourceCurrentState.AppendMsZoneTransferTag                 | Should -Be $ConfigurationData.AllNodes.AppendMsZoneTransferTag
                $resourceCurrentState.AutoCreateDelegation                    | Should -Be $ConfigurationData.AllNodes.AutoCreateDelegation
                $resourceCurrentState.DeleteOutsideGlue                       | Should -Be $ConfigurationData.AllNodes.DeleteOutsideGlue
                $resourceCurrentState.EnableDuplicateQuerySuppression         | Should -Be $ConfigurationData.AllNodes.EnableDuplicateQuerySuppression
                $resourceCurrentState.EnableIPv6                              | Should -Be $ConfigurationData.AllNodes.EnableIPv6
                $resourceCurrentState.EnableIQueryResponseGeneration          | Should -Be $ConfigurationData.AllNodes.EnableIQueryResponseGeneration
                $resourceCurrentState.EnableOnlineSigning                     | Should -Be $ConfigurationData.AllNodes.EnableOnlineSigning
                $resourceCurrentState.EnableRsoForRodc                        | Should -Be $ConfigurationData.AllNodes.EnableRsoForRodc
                $resourceCurrentState.EnableSendErrorSuppression              | Should -Be $ConfigurationData.AllNodes.EnableSendErrorSuppression
                $resourceCurrentState.EnableUpdateForwarding                  | Should -Be $ConfigurationData.AllNodes.EnableUpdateForwarding
                $resourceCurrentState.EnableVersionQuery                      | Should -Be $ConfigurationData.AllNodes.EnableVersionQuery
                $resourceCurrentState.EnableWinsR                             | Should -Be $ConfigurationData.AllNodes.EnableWinsR
                $resourceCurrentState.IgnoreAllPolicies                       | Should -Be $ConfigurationData.AllNodes.IgnoreAllPolicies
                $resourceCurrentState.IgnoreServerLevelPolicies               | Should -Be $ConfigurationData.AllNodes.IgnoreServerLevelPolicies
                $resourceCurrentState.IsReadOnlyDC                            | Should -Be $ConfigurationData.AllNodes.IsReadOnlyDC
                $resourceCurrentState.LameDelegationTTL                       | Should -Be $ConfigurationData.AllNodes.LameDelegationTTL
                $resourceCurrentState.LocalNetPriorityMask                    | Should -Be $ConfigurationData.AllNodes.LocalNetPriorityMask
                $resourceCurrentState.MaximumRodcRsoAttemptsPerCycle          | Should -Be $ConfigurationData.AllNodes.MaximumRodcRsoAttemptsPerCycle
                $resourceCurrentState.MaximumRodcRsoQueueLength               | Should -Be $ConfigurationData.AllNodes.MaximumRodcRsoQueueLength
                $resourceCurrentState.MaximumSignatureScanPeriod              | Should -Be $ConfigurationData.AllNodes.MaximumSignatureScanPeriod
                $resourceCurrentState.MaximumTrustAnchorActiveRefreshInterval | Should -Be $ConfigurationData.AllNodes.MaximumTrustAnchorActiveRefreshInterval
                $resourceCurrentState.MaximumUdpPacketSize                    | Should -Be $ConfigurationData.AllNodes.MaximumUdpPacketSize
                $resourceCurrentState.MaxResourceRecordsInNonSecureUpdate     | Should -Be $ConfigurationData.AllNodes.MaxResourceRecordsInNonSecureUpdate
                $resourceCurrentState.NoUpdateDelegations                     | Should -Be $ConfigurationData.AllNodes.NoUpdateDelegations
                $resourceCurrentState.OpenAclOnProxyUpdates                   | Should -Be $ConfigurationData.AllNodes.OpenAclOnProxyUpdates
                $resourceCurrentState.PublishAutoNet                          | Should -Be $ConfigurationData.AllNodes.PublishAutoNet
                $resourceCurrentState.QuietRecvFaultInterval                  | Should -Be $ConfigurationData.AllNodes.QuietRecvFaultInterval
                $resourceCurrentState.QuietRecvLogInterval                    | Should -Be $ConfigurationData.AllNodes.QuietRecvLogInterval
                $resourceCurrentState.ReloadException                         | Should -Be $ConfigurationData.AllNodes.ReloadException
                $resourceCurrentState.RemoteIPv4RankBoost                     | Should -Be $ConfigurationData.AllNodes.RemoteIPv4RankBoost
                $resourceCurrentState.RemoteIPv6RankBoost                     | Should -Be $ConfigurationData.AllNodes.RemoteIPv6RankBoost
                $resourceCurrentState.RootTrustAnchorsURL                     | Should -Be $ConfigurationData.AllNodes.RootTrustAnchorsURL
                $resourceCurrentState.ScopeOptionValue                        | Should -Be $ConfigurationData.AllNodes.ScopeOptionValue
                $resourceCurrentState.SelfTest                                | Should -Be $ConfigurationData.AllNodes.SelfTest
                $resourceCurrentState.SilentlyIgnoreCnameUpdateConflicts      | Should -Be $ConfigurationData.AllNodes.SilentlyIgnoreCnameUpdateConflicts
                $resourceCurrentState.SocketPoolExcludedPortRanges            | Should -Be $ConfigurationData.AllNodes.SocketPoolExcludedPortRanges
                $resourceCurrentState.SocketPoolSize                          | Should -Be $ConfigurationData.AllNodes.SocketPoolSize
                $resourceCurrentState.SyncDsZoneSerial                        | Should -Be $ConfigurationData.AllNodes.SyncDsZoneSerial
                $resourceCurrentState.TcpReceivePacketSize                    | Should -Be $ConfigurationData.AllNodes.TcpReceivePacketSize
                $resourceCurrentState.VirtualizationInstanceOptionValue       | Should -Be $ConfigurationData.AllNodes.VirtualizationInstanceOptionValue
                $resourceCurrentState.XfrThrottleMultiplier                   | Should -Be $ConfigurationData.AllNodes.XfrThrottleMultiplier
                $resourceCurrentState.ZoneWritebackInterval                   | Should -Be $ConfigurationData.AllNodes.ZoneWritebackInterval
            }

            It 'Should return ''True'' when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Wait-ForIdleLcm -Clear
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
