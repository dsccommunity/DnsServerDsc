$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

$script:timeSpanProperties = @(
    'LameDelegationTTL'
    'MaximumSignatureScanPeriod'
    'MaximumTrustAnchorActiveRefreshInterval'
    'ZoneWritebackInterval'
)

<#
    .SYNOPSIS
        Returns the current state of the DNS server settings.

    .PARAMETER DnsServer
        Specifies the DNS server to connect to, or use 'localhost' for the current
        node.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer
    )

    Assert-Module -ModuleName 'DnsServer'

    Write-Verbose ($script:localizedData.GettingDnsServerSettings)

    $getDnsServerSettingParameters = @{
        All = $true
    }

    if ($DnsServer -ne 'localhost')
    {
        $getDnsServerSettingParameters['ComputerName'] = $DnsServer
    }

    $dnsServerInstance = Get-DnsServerSetting @getDnsServerSettingParameters

    $classProperties = @(
        'LocalNetPriority'
        'AutoConfigFileZones'
        'AddressAnswerLimit'
        'UpdateOptions'
        'DisableAutoReverseZone'
        'StrictFileParsing'
        'EnableDirectoryPartitions'
        'XfrConnectTimeout'
        'AllowUpdate'
        'BootMethod'
        'LooseWildcarding'
        'BindSecondaries'
        'AutoCacheUpdate'
        'EnableDnsSec'
        'NameCheckFlag'
        'SendPort'
        'WriteAuthorityNS'
        'ListeningIPAddress'
        'RpcProtocol'
        'RoundRobin'
        'ForwardDelegations'
        'EnableIPv6'
        'EnableOnlineSigning'
        'EnableDuplicateQuerySuppression'
        'AllowCnameAtNs'
        'EnableRsoForRodc'
        'OpenAclOnProxyUpdates'
        'NoUpdateDelegations'
        'EnableUpdateForwarding'
        'EnableWinsR'
        'DeleteOutsideGlue'
        'AppendMsZoneTransferTag'
        'AllowReadOnlyZoneTransfer'
        'EnableSendErrorSuppression'
        'SilentlyIgnoreCnameUpdateConflicts'
        'EnableIQueryResponseGeneration'
        'AdminConfigured'
        'PublishAutoNet'
        'ReloadException'
        'IgnoreServerLevelPolicies'
        'IgnoreAllPolicies'
        'EnableVersionQuery'
        'AutoCreateDelegation'
        'RemoteIPv4RankBoost'
        'RemoteIPv6RankBoost'
        'MaximumRodcRsoQueueLength'
        'MaximumRodcRsoAttemptsPerCycle'
        'MaxResourceRecordsInNonSecureUpdate'
        'LocalNetPriorityMask'
        'TcpReceivePacketSize'
        'SelfTest'
        'XfrThrottleMultiplier'
        'SocketPoolSize'
        'QuietRecvFaultInterval'
        'QuietRecvLogInterval'
        'SyncDsZoneSerial'
        'ScopeOptionValue'
        'VirtualizationInstanceOptionValue'
        'ServerLevelPluginDll'
        'RootTrustAnchorsURL'
        'SocketPoolExcludedPortRanges'
        'LameDelegationTTL'
        'MaximumSignatureScanPeriod'
        'MaximumTrustAnchorActiveRefreshInterval'
        'ZoneWritebackInterval'

        # Read-only properties
        'DsAvailable'
        'MajorVersion'
        'MinorVersion'
        'BuildNumber'
        'IsReadOnlyDC'
        'AllIPAddress'
        'ForestDirectoryPartitionBaseName'
        'DomainDirectoryPartitionBaseName'
        'MaximumUdpPacketSize'
    )

    $returnValue = @{}

    foreach ($property in $classProperties)
    {
        if ($property -in $script:timeSpanProperties)
        {
            $returnValue.Add($property, $dnsServerInstance.$property.ToString())
        }
        else
        {
            $returnValue.Add($property, $dnsServerInstance.$property)
        }
    }

    $returnValue.DnsServer = $DnsServer

    return $returnValue
}

<#
    .SYNOPSIS
        Set the desired state of the DNS server settings.

    .PARAMETER DnsServer
        Specifies the DNS server to connect to, or use 'localhost' for the current
        node.

    .PARAMETER AddressAnswerLimit
        See schema MOF.

    .PARAMETER AllowUpdate
        See schema MOF.

    .PARAMETER AutoCacheUpdate
        See schema MOF.

    .PARAMETER AutoConfigFileZones
        See schema MOF.

    .PARAMETER BindSecondaries
        See schema MOF.

    .PARAMETER BootMethod
        See schema MOF.

    .PARAMETER DisableAutoReverseZone
        See schema MOF.

    .PARAMETER EnableDirectoryPartitions
        See schema MOF.

    .PARAMETER EnableDnsSec
        See schema MOF.

    .PARAMETER ForwardDelegations
        See schema MOF.

    .PARAMETER ListeningIPAddress
        See schema MOF.

    .PARAMETER LocalNetPriority
        See schema MOF.

    .PARAMETER LooseWildcarding
        See schema MOF.

    .PARAMETER NameCheckFlag
        See schema MOF.

    .PARAMETER RoundRobin
        See schema MOF.

    .PARAMETER RpcProtocol
        See schema MOF.

    .PARAMETER SendPort
        See schema MOF.

    .PARAMETER StrictFileParsing
        See schema MOF.

    .PARAMETER UpdateOptions
        See schema MOF.

    .PARAMETER WriteAuthorityNS
        See schema MOF.

    .PARAMETER XfrConnectTimeout
        See schema MOF.

    .PARAMETER EnableIPv6
        See schema MOF.

    .PARAMETER EnableOnlineSigning
        See schema MOF.

    .PARAMETER EnableDuplicateQuerySuppression
        See schema MOF.

    .PARAMETER AllowCnameAtNs
        See schema MOF.

    .PARAMETER EnableRsoForRodc
        See schema MOF.

    .PARAMETER OpenAclOnProxyUpdates
        See schema MOF.

    .PARAMETER NoUpdateDelegations
        See schema MOF.

    .PARAMETER EnableUpdateForwarding
        See schema MOF.

    .PARAMETER EnableWinsR
        See schema MOF.

    .PARAMETER DeleteOutsideGlue
        See schema MOF.

    .PARAMETER AppendMsZoneTransferTag
        See schema MOF.

    .PARAMETER AllowReadOnlyZoneTransfer
        See schema MOF.

    .PARAMETER EnableSendErrorSuppression
        See schema MOF.

    .PARAMETER SilentlyIgnoreCnameUpdateConflicts
        See schema MOF.

    .PARAMETER EnableIQueryResponseGeneration
        See schema MOF.

    .PARAMETER AdminConfigured
        See schema MOF.

    .PARAMETER PublishAutoNet
        See schema MOF.

    .PARAMETER ReloadException
        See schema MOF.

    .PARAMETER IgnoreServerLevelPolicies
        See schema MOF.

    .PARAMETER IgnoreAllPolicies
        See schema MOF.

    .PARAMETER EnableVersionQuery
        See schema MOF.

    .PARAMETER AutoCreateDelegation
        See schema MOF.

    .PARAMETER RemoteIPv4RankBoost
        See schema MOF.

    .PARAMETER RemoteIPv6RankBoost
        See schema MOF.

    .PARAMETER MaximumRodcRsoQueueLength
        See schema MOF.

    .PARAMETER MaximumRodcRsoAttemptsPerCycle
        See schema MOF.

    .PARAMETER MaxResourceRecordsInNonSecureUpdate
        See schema MOF.

    .PARAMETER LocalNetPriorityMask
        See schema MOF.

    .PARAMETER TcpReceivePacketSize
        See schema MOF.

    .PARAMETER SelfTest
        See schema MOF.

    .PARAMETER XfrThrottleMultiplier
        See schema MOF.

    .PARAMETER SocketPoolSize
        See schema MOF.

    .PARAMETER QuietRecvFaultInterval
        See schema MOF.

    .PARAMETER QuietRecvLogInterval
        See schema MOF.

    .PARAMETER SyncDsZoneSerial
        See schema MOF.

    .PARAMETER ScopeOptionValue
        See schema MOF.

    .PARAMETER VirtualizationInstanceOptionValue
        See schema MOF.

    .PARAMETER ServerLevelPluginDll
        See schema MOF.

    .PARAMETER RootTrustAnchorsURL
        See schema MOF.

    .PARAMETER SocketPoolExcludedPortRanges
        See schema MOF.

    .PARAMETER LameDelegationTTL
        See schema MOF.

    .PARAMETER MaximumSignatureScanPeriod
        See schema MOF.

    .PARAMETER MaximumTrustAnchorActiveRefreshInterval
        See schema MOF.

    .PARAMETER ZoneWritebackInterval
        See schema MOF.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer,

        [Parameter()]
        [System.UInt32]
        $AddressAnswerLimit,

        [Parameter()]
        [System.Boolean]
        $AllowUpdate,

        [Parameter()]
        [System.Boolean]
        $AutoCacheUpdate,

        [Parameter()]
        [System.UInt32]
        $AutoConfigFileZones,

        [Parameter()]
        [System.Boolean]
        $BindSecondaries,

        [Parameter()]
        [System.UInt32]
        $BootMethod,

        [Parameter()]
        [System.Boolean]
        $DisableAutoReverseZone,

        [Parameter()]
        [System.Boolean]
        $EnableDirectoryPartitions,

        [Parameter()]
        [System.Boolean]
        $EnableDnsSec,

        [Parameter()]
        [System.Boolean]
        $ForwardDelegations,

        [Parameter()]
        [System.String[]]
        $ListeningIPAddress,

        [Parameter()]
        [System.Boolean]
        $LocalNetPriority,

        [Parameter()]
        [System.Boolean]
        $LooseWildcarding,

        [Parameter()]
        [System.UInt32]
        $NameCheckFlag,

        [Parameter()]
        [System.Boolean]
        $RoundRobin,

        [Parameter()]
        [System.UInt32]
        $RpcProtocol,

        [Parameter()]
        [System.UInt32]
        $SendPort,

        [Parameter()]
        [System.Boolean]
        $StrictFileParsing,

        [Parameter()]
        [System.UInt32]
        $UpdateOptions,

        [Parameter()]
        [System.Boolean]
        $WriteAuthorityNS,

        [Parameter()]
        [System.UInt32]
        $XfrConnectTimeout,

        [Parameter()]
        [System.Boolean]
        $EnableIPv6,

        [Parameter()]
        [System.Boolean]
        $EnableOnlineSigning,

        [Parameter()]
        [System.Boolean]
        $EnableDuplicateQuerySuppression,

        [Parameter()]
        [System.Boolean]
        $AllowCnameAtNs,

        [Parameter()]
        [System.Boolean]
        $EnableRsoForRodc,

        [Parameter()]
        [System.Boolean]
        $OpenAclOnProxyUpdates,

        [Parameter()]
        [System.Boolean]
        $NoUpdateDelegations,

        [Parameter()]
        [System.Boolean]
        $EnableUpdateForwarding,

        [Parameter()]
        [System.Boolean]
        $EnableWinsR,

        [Parameter()]
        [System.Boolean]
        $DeleteOutsideGlue,

        [Parameter()]
        [System.Boolean]
        $AppendMsZoneTransferTag,

        [Parameter()]
        [System.Boolean]
        $AllowReadOnlyZoneTransfer,

        [Parameter()]
        [System.Boolean]
        $EnableSendErrorSuppression,

        [Parameter()]
        [System.Boolean]
        $SilentlyIgnoreCnameUpdateConflicts,

        [Parameter()]
        [System.Boolean]
        $EnableIQueryResponseGeneration,

        [Parameter()]
        [System.Boolean]
        $AdminConfigured,

        [Parameter()]
        [System.Boolean]
        $PublishAutoNet,

        [Parameter()]
        [System.Boolean]
        $ReloadException,

        [Parameter()]
        [System.Boolean]
        $IgnoreServerLevelPolicies,

        [Parameter()]
        [System.Boolean]
        $IgnoreAllPolicies,

        [Parameter()]
        [System.UInt32]
        $EnableVersionQuery,

        [Parameter()]
        [System.UInt32]
        $AutoCreateDelegation,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv4RankBoost,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv6RankBoost,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoQueueLength,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoAttemptsPerCycle,

        [Parameter()]
        [System.UInt32]
        $MaxResourceRecordsInNonSecureUpdate,

        [Parameter()]
        [System.UInt32]
        $LocalNetPriorityMask,

        [Parameter()]
        [System.UInt32]
        $TcpReceivePacketSize,

        [Parameter()]
        [System.UInt32]
        $SelfTest,

        [Parameter()]
        [System.UInt32]
        $XfrThrottleMultiplier,

        [Parameter()]
        [System.UInt32]
        $SocketPoolSize,

        [Parameter()]
        [System.UInt32]
        $QuietRecvFaultInterval,

        [Parameter()]
        [System.UInt32]
        $QuietRecvLogInterval,

        [Parameter()]
        [System.UInt32]
        $SyncDsZoneSerial,

        [Parameter()]
        [System.UInt32]
        $ScopeOptionValue,

        [Parameter()]
        [System.UInt32]
        $VirtualizationInstanceOptionValue,

        [Parameter()]
        [System.String]
        $ServerLevelPluginDll,

        [Parameter()]
        [System.String]
        $RootTrustAnchorsURL,

        [Parameter()]
        [System.String[]]
        $SocketPoolExcludedPortRanges,

        [Parameter()]
        [System.String]
        $LameDelegationTTL,

        [Parameter()]
        [System.String]
        $MaximumSignatureScanPeriod,

        [Parameter()]
        [System.String]
        $MaximumTrustAnchorActiveRefreshInterval,

        [Parameter()]
        [System.String]
        $ZoneWritebackInterval
    )

    Assert-Module -ModuleName 'DnsServer'

    $PSBoundParameters.Remove('DnsServer')

    $dnsProperties = Remove-CommonParameter -Hashtable $PSBoundParameters

    $getDnServerSettingResult = Get-DnsServerSetting -All

    $propertiesInDesiredState = @()

    foreach ($property in $dnsProperties.keys)
    {
        if ($property -in ('ListeningIPAddress', 'SocketPoolExcludedPortRanges'))
        {
            # Compare array

            $compareObjectParameters = @{
                ReferenceObject  = $dnsProperties.$property
                DifferenceObject = $getDnServerSettingResult.$property
            }

            $isPropertyInDesiredState = -not (Compare-Object @compareObjectParameters)
        }
        else
        {
            $isPropertyInDesiredState = $dnsProperties.$property -eq $getDnServerSettingResult.$property
        }

        if ($isPropertyInDesiredState)
        {
            # Property in desired state.

            Write-Verbose -Message ($script:localizedData.PropertyInDesiredState -f $property)

            $propertiesInDesiredState += $property

        }
        else
        {
            # Property not in desired state.

            Write-Verbose -Message ($script:localizedData.SetDnsServerSetting -f $property, ($dnsProperties[$property] -join ', '))
        }
    }

    # Remove passed parameters that are in desired state.
    $propertiesInDesiredState | ForEach-Object -Process {
        $dnsProperties.Remove($_)
    }

    if ($dnsProperties.Keys.Count -eq 0)
    {
        Write-Verbose -Message $script:localizedData.SettingsInDesiredState
    }
    else
    {
        # Set all desired values for the properties that were not in desired state.
        $dnsProperties.Keys | ForEach-Object -Process {
            $property = $_

            if ($property -in $script:timeSpanProperties)
            {
                $timeSpan = New-TimeSpan

                <#
                    When this resource is converted to a class-based resource this should
                    be replaced by private function ConvertTo-TimeSpan.
                #>
                if (-not [System.TimeSpan]::TryParse($dnsProperties.$property, [ref] $timeSpan))
                {
                    throw ($script:localizedData.UnableToParseTimeSpan -f $dnsProperties.$property, $property )
                }

                $getDnServerSettingResult.$property = $timeSpan
            }
            else
            {
                $getDnServerSettingResult.$property = $dnsProperties.$property
            }
        }

        $setDnServerSettingParameters = @{
            ErrorAction = 'Stop'
        }

        if ($DnsServer -ne 'localhost')
        {
            $setDnServerSettingParameters['ComputerName'] = $DnsServer
        }

        $getDnServerSettingResult | Set-DnsServerSetting @setDnServerSettingParameters
    }
}

<#
    .SYNOPSIS
        Tests the desired state of the DNS server settings.

    .PARAMETER DnsServer
        Specifies the DNS server to connect to, or use 'localhost' for the current
        node.

    .PARAMETER AddressAnswerLimit
        See schema MOF.

    .PARAMETER AllowUpdate
        See schema MOF.

    .PARAMETER AutoCacheUpdate
        See schema MOF.

    .PARAMETER AutoConfigFileZones
        See schema MOF.

    .PARAMETER BindSecondaries
        See schema MOF.

    .PARAMETER BootMethod
        See schema MOF.

    .PARAMETER DisableAutoReverseZone
        See schema MOF.

    .PARAMETER EnableDirectoryPartitions
        See schema MOF.

    .PARAMETER EnableDnsSec
        See schema MOF.

    .PARAMETER ForwardDelegations
        See schema MOF.

    .PARAMETER ListeningIPAddress
        See schema MOF.

    .PARAMETER LocalNetPriority
        See schema MOF.

    .PARAMETER LooseWildcarding
        See schema MOF.

    .PARAMETER NameCheckFlag
        See schema MOF.

    .PARAMETER RoundRobin
        See schema MOF.

    .PARAMETER RpcProtocol
        See schema MOF.

    .PARAMETER SendPort
        See schema MOF.

    .PARAMETER StrictFileParsing
        See schema MOF.

    .PARAMETER UpdateOptions
        See schema MOF.

    .PARAMETER WriteAuthorityNS
        See schema MOF.

    .PARAMETER XfrConnectTimeout
        See schema MOF.

    .PARAMETER EnableIPv6
        See schema MOF.

    .PARAMETER EnableOnlineSigning
        See schema MOF.

    .PARAMETER EnableDuplicateQuerySuppression
        See schema MOF.

    .PARAMETER AllowCnameAtNs
        See schema MOF.

    .PARAMETER EnableRsoForRodc
        See schema MOF.

    .PARAMETER OpenAclOnProxyUpdates
        See schema MOF.

    .PARAMETER NoUpdateDelegations
        See schema MOF.

    .PARAMETER EnableUpdateForwarding
        See schema MOF.

    .PARAMETER EnableWinsR
        See schema MOF.

    .PARAMETER DeleteOutsideGlue
        See schema MOF.

    .PARAMETER AppendMsZoneTransferTag
        See schema MOF.

    .PARAMETER AllowReadOnlyZoneTransfer
        See schema MOF.

    .PARAMETER EnableSendErrorSuppression
        See schema MOF.

    .PARAMETER SilentlyIgnoreCnameUpdateConflicts
        See schema MOF.

    .PARAMETER EnableIQueryResponseGeneration
        See schema MOF.

    .PARAMETER AdminConfigured
        See schema MOF.

    .PARAMETER PublishAutoNet
        See schema MOF.

    .PARAMETER ReloadException
        See schema MOF.

    .PARAMETER IgnoreServerLevelPolicies
        See schema MOF.

    .PARAMETER IgnoreAllPolicies
        See schema MOF.

    .PARAMETER EnableVersionQuery
        See schema MOF.

    .PARAMETER AutoCreateDelegation
        See schema MOF.

    .PARAMETER RemoteIPv4RankBoost
        See schema MOF.

    .PARAMETER RemoteIPv6RankBoost
        See schema MOF.

    .PARAMETER MaximumRodcRsoQueueLength
        See schema MOF.

    .PARAMETER MaximumRodcRsoAttemptsPerCycle
        See schema MOF.

    .PARAMETER MaxResourceRecordsInNonSecureUpdate
        See schema MOF.

    .PARAMETER LocalNetPriorityMask
        See schema MOF.

    .PARAMETER TcpReceivePacketSize
        See schema MOF.

    .PARAMETER SelfTest
        See schema MOF.

    .PARAMETER XfrThrottleMultiplier
        See schema MOF.

    .PARAMETER SocketPoolSize
        See schema MOF.

    .PARAMETER QuietRecvFaultInterval
        See schema MOF.

    .PARAMETER QuietRecvLogInterval
        See schema MOF.

    .PARAMETER SyncDsZoneSerial
        See schema MOF.

    .PARAMETER ScopeOptionValue
        See schema MOF.

    .PARAMETER VirtualizationInstanceOptionValue
        See schema MOF.

    .PARAMETER ServerLevelPluginDll
        See schema MOF.

    .PARAMETER RootTrustAnchorsURL
        See schema MOF.

    .PARAMETER SocketPoolExcludedPortRanges
        See schema MOF.

    .PARAMETER LameDelegationTTL
        See schema MOF.

    .PARAMETER MaximumSignatureScanPeriod
        See schema MOF.

    .PARAMETER MaximumTrustAnchorActiveRefreshInterval
        See schema MOF.

    .PARAMETER ZoneWritebackInterval
        See schema MOF.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer,

        [Parameter()]
        [System.UInt32]
        $AddressAnswerLimit,

        [Parameter()]
        [System.Boolean]
        $AllowUpdate,

        [Parameter()]
        [System.Boolean]
        $AutoCacheUpdate,

        [Parameter()]
        [System.UInt32]
        $AutoConfigFileZones,

        [Parameter()]
        [System.Boolean]
        $BindSecondaries,

        [Parameter()]
        [System.UInt32]
        $BootMethod,

        [Parameter()]
        [System.Boolean]
        $DisableAutoReverseZone,

        [Parameter()]
        [System.Boolean]
        $EnableDirectoryPartitions,

        [Parameter()]
        [System.Boolean]
        $EnableDnsSec,

        [Parameter()]
        [System.Boolean]
        $ForwardDelegations,

        [Parameter()]
        [System.String[]]
        $ListeningIPAddress,

        [Parameter()]
        [System.Boolean]
        $LocalNetPriority,

        [Parameter()]
        [System.Boolean]
        $LooseWildcarding,

        [Parameter()]
        [System.UInt32]
        $NameCheckFlag,

        [Parameter()]
        [System.Boolean]
        $RoundRobin,

        [Parameter()]
        [System.UInt32]
        $RpcProtocol,

        [Parameter()]
        [System.UInt32]
        $SendPort,

        [Parameter()]
        [System.Boolean]
        $StrictFileParsing,

        [Parameter()]
        [System.UInt32]
        $UpdateOptions,

        [Parameter()]
        [System.Boolean]
        $WriteAuthorityNS,

        [Parameter()]
        [System.UInt32]
        $XfrConnectTimeout,

        [Parameter()]
        [System.Boolean]
        $EnableIPv6,

        [Parameter()]
        [System.Boolean]
        $EnableOnlineSigning,

        [Parameter()]
        [System.Boolean]
        $EnableDuplicateQuerySuppression,

        [Parameter()]
        [System.Boolean]
        $AllowCnameAtNs,

        [Parameter()]
        [System.Boolean]
        $EnableRsoForRodc,

        [Parameter()]
        [System.Boolean]
        $OpenAclOnProxyUpdates,

        [Parameter()]
        [System.Boolean]
        $NoUpdateDelegations,

        [Parameter()]
        [System.Boolean]
        $EnableUpdateForwarding,

        [Parameter()]
        [System.Boolean]
        $EnableWinsR,

        [Parameter()]
        [System.Boolean]
        $DeleteOutsideGlue,

        [Parameter()]
        [System.Boolean]
        $AppendMsZoneTransferTag,

        [Parameter()]
        [System.Boolean]
        $AllowReadOnlyZoneTransfer,

        [Parameter()]
        [System.Boolean]
        $EnableSendErrorSuppression,

        [Parameter()]
        [System.Boolean]
        $SilentlyIgnoreCnameUpdateConflicts,

        [Parameter()]
        [System.Boolean]
        $EnableIQueryResponseGeneration,

        [Parameter()]
        [System.Boolean]
        $AdminConfigured,

        [Parameter()]
        [System.Boolean]
        $PublishAutoNet,

        [Parameter()]
        [System.Boolean]
        $ReloadException,

        [Parameter()]
        [System.Boolean]
        $IgnoreServerLevelPolicies,

        [Parameter()]
        [System.Boolean]
        $IgnoreAllPolicies,

        [Parameter()]
        [System.UInt32]
        $EnableVersionQuery,

        [Parameter()]
        [System.UInt32]
        $AutoCreateDelegation,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv4RankBoost,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv6RankBoost,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoQueueLength,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoAttemptsPerCycle,

        [Parameter()]
        [System.UInt32]
        $MaxResourceRecordsInNonSecureUpdate,

        [Parameter()]
        [System.UInt32]
        $LocalNetPriorityMask,

        [Parameter()]
        [System.UInt32]
        $TcpReceivePacketSize,

        [Parameter()]
        [System.UInt32]
        $SelfTest,

        [Parameter()]
        [System.UInt32]
        $XfrThrottleMultiplier,

        [Parameter()]
        [System.UInt32]
        $SocketPoolSize,

        [Parameter()]
        [System.UInt32]
        $QuietRecvFaultInterval,

        [Parameter()]
        [System.UInt32]
        $QuietRecvLogInterval,

        [Parameter()]
        [System.UInt32]
        $SyncDsZoneSerial,

        [Parameter()]
        [System.UInt32]
        $ScopeOptionValue,

        [Parameter()]
        [System.UInt32]
        $VirtualizationInstanceOptionValue,

        [Parameter()]
        [System.String]
        $ServerLevelPluginDll,

        [Parameter()]
        [System.String]
        $RootTrustAnchorsURL,

        [Parameter()]
        [System.String[]]
        $SocketPoolExcludedPortRanges,

        [Parameter()]
        [System.String]
        $LameDelegationTTL,

        [Parameter()]
        [System.String]
        $MaximumSignatureScanPeriod,

        [Parameter()]
        [System.String]
        $MaximumTrustAnchorActiveRefreshInterval,

        [Parameter()]
        [System.String]
        $ZoneWritebackInterval
    )

    Write-Verbose -Message $script:localizedData.EvaluatingDnsServerSettings

    $currentState = Get-TargetResource -DnsServer $DnsServer

    $null = $PSBoundParameters.Remove('DnsServer')

    $result = $true

    # Returns an item for each property that is not in desired state.
    if (Compare-DscParameterState -CurrentValues $currentState -DesiredValues $PSBoundParameters -Verbose:$VerbosePreference)
    {
        $result = $false
    }

    return $result
}
