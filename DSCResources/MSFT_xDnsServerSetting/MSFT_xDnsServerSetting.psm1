Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false

data LocalizedData
{
    ConvertFrom-StringData -StringData @'
NotInDesiredState="{0}" not in desired state. Expected: "{1}" Actual: "{2}".
DnsClassNotFound=MicrosoftDNS_Server class not found. DNS role is not installed.
ParameterExpectedNull={0} expected to be NULL nut is not.
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Name
    )

    Assert-Module -Name DnsServer
    
    $dnsServerInstance = Get-CimInstance -Namespace root\MicrosoftDNS -ClassName MicrosoftDNS_Server -ErrorAction Stop
    
    $returnValue = @{
        Name = $Name
        AddressAnswerLimit = $dnsServerInstance.AddressAnswerLimit
        AllowUpdate = $dnsServerInstance.AllowUpdate
        AutoCacheUpdate = $dnsServerInstance.AutoCacheUpdate
        AutoConfigFileZones = $dnsServerInstance.AutoConfigFileZones
        BindSecondaries = $dnsServerInstance.BindSecondaries
        BootMethod = $dnsServerInstance.BootMethod
        DefaultAgingState = $dnsServerInstance.DefaultAgingState
        DefaultNoRefreshInterval = $dnsServerInstance.DefaultNoRefreshInterval
        DefaultRefreshInterval = $dnsServerInstance.DefaultRefreshInterval
        DisableAutoReverseZones = $dnsServerInstance.DisableAutoReverseZones
        DisjointNets = $dnsServerInstance.DisjointNets
        DsPollingInterval = $dnsServerInstance.DsPollingInterval
        DsTombstoneInterval = $dnsServerInstance.DsTombstoneInterval
        EDnsCacheTimeout = $dnsServerInstance.EDnsCacheTimeout
        EnableDirectoryPartitions = $dnsServerInstance.EnableDirectoryPartitions
        EnableDnsSec = $dnsServerInstance.EnableDnsSec
        EnableEDnsProbes = $dnsServerInstance.EnableEDnsProbes
        EventLogLevel = $dnsServerInstance.EventLogLevel
        ForwardDelegations = $dnsServerInstance.ForwardDelegations
        Forwarders = $dnsServerInstance.Forwarders
        ForwardingTimeout = $dnsServerInstance.ForwardingTimeout
        IsSlave = $dnsServerInstance.IsSlave
        ListenAddresses = $dnsServerInstance.ListenAddresses
        LocalNetPriority = $dnsServerInstance.LocalNetPriority
        LogFileMaxSize = $dnsServerInstance.LogFileMaxSize
        LogFilePath = $dnsServerInstance.LogFilePath
        LogIPFilterList = (Get-PsDnsServerDiagnosticsClass).FilterIPAddressList
        LogLevel = $dnsServerInstance.LogLevel
        LooseWildcarding = $dnsServerInstance.LooseWildcarding
        MaxCacheTTL = $dnsServerInstance.MaxCacheTTL
        MaxNegativeCacheTTL = $dnsServerInstance.MaxNegativeCacheTTL
        NameCheckFlag = $dnsServerInstance.NameCheckFlag
        NoRecursion = $dnsServerInstance.NoRecursion
        RecursionRetry = $dnsServerInstance.RecursionRetry
        RecursionTimeout = $dnsServerInstance.RecursionTimeout
        RoundRobin = $dnsServerInstance.RoundRobin
        RpcProtocol = $dnsServerInstance.RpcProtocol
        ScavengingInterval = $dnsServerInstance.ScavengingInterval
        SecureResponses = $dnsServerInstance.SecureResponses
        SendPort = $dnsServerInstance.SendPort
        StrictFileParsing = $dnsServerInstance.StrictFileParsing
        UpdateOptions = $dnsServerInstance.UpdateOptions
        WriteAuthorityNS = $dnsServerInstance.WriteAuthorityNS
        XfrConnectTimeout = $dnsServerInstance.XfrConnectTimeout
    }

    $returnValue    
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Name,

        [uint32]
        $AddressAnswerLimit,

        [uint32]
        $AllowUpdate,

        [bool]
        $AutoCacheUpdate,

        [uint32]
        $AutoConfigFileZones,

        [bool]
        $BindSecondaries,

        [uint32]
        $BootMethod,

        [bool]
        $DefaultAgingState,

        [uint32]
        $DefaultNoRefreshInterval,

        [uint32]
        $DefaultRefreshInterval,

        [bool]
        $DisableAutoReverseZones,

        [bool]
        $DisjointNets,

        [uint32]
        $DsPollingInterval,

        [uint32]
        $DsTombstoneInterval,

        [uint32]
        $EDnsCacheTimeout,

        [bool]
        $EnableDirectoryPartitions,

        [uint32]
        $EnableDnsSec,

        [bool]
        $EnableEDnsProbes,

        [uint32]
        $EventLogLevel,

        [uint32]
        $ForwardDelegations,

        [string[]]
        $Forwarders,

        [uint32]
        $ForwardingTimeout,

        [bool]
        $IsSlave,

        [string[]]
        $ListenAddresses,

        [bool]
        $LocalNetPriority,

        [uint32]
        $LogFileMaxSize,

        [string]
        $LogFilePath,

        [string[]]
        $LogIPFilterList,

        [uint32]
        $LogLevel,

        [bool]
        $LooseWildcarding,

        [uint32]
        $MaxCacheTTL,

        [uint32]
        $MaxNegativeCacheTTL,

        [uint32]
        $NameCheckFlag,

        [bool]
        $NoRecursion,

        [uint32]
        $RecursionRetry,

        [uint32]
        $RecursionTimeout,

        [bool]
        $RoundRobin,

        [int16]
        $RpcProtocol,

        [uint32]
        $ScavengingInterval,

        [bool]
        $SecureResponses,

        [uint32]
        $SendPort,

        [bool]
        $StrictFileParsing,

        [uint32]
        $UpdateOptions,

        [bool]
        $WriteAuthorityNS,

        [uint32]
        $XfrConnectTimeout
    )
    
    Assert-Module -Name DnsServer

    $PSBoundParameters.Remove('Name')
    $dnsProperties = Remove-CommonParameter -Hashtable $PSBoundParameters 

    $dnsServerInstance = Get-CimInstance -Namespace root\MicrosoftDNS -ClassName MicrosoftDNS_Server

    try
    {
        Set-CimInstance -InputObject $dnsServerInstance -Property $dnsProperties -ErrorAction Stop
    }
    catch
    {
        throw $_
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Name,

        [uint32]
        $AddressAnswerLimit,

        [uint32]
        $AllowUpdate,

        [bool]
        $AutoCacheUpdate,

        [uint32]
        $AutoConfigFileZones,

        [bool]
        $BindSecondaries,

        [uint32]
        $BootMethod,

        [bool]
        $DefaultAgingState,

        [uint32]
        $DefaultNoRefreshInterval,

        [uint32]
        $DefaultRefreshInterval,

        [bool]
        $DisableAutoReverseZones,

        [bool]
        $DisjointNets,

        [uint32]
        $DsPollingInterval,

        [uint32]
        $DsTombstoneInterval,

        [uint32]
        $EDnsCacheTimeout,

        [bool]
        $EnableDirectoryPartitions,

        [uint32]
        $EnableDnsSec,

        [bool]
        $EnableEDnsProbes,

        [uint32]
        $EventLogLevel,

        [uint32]
        $ForwardDelegations,

        [string[]]
        $Forwarders,

        [uint32]
        $ForwardingTimeout,

        [bool]
        $IsSlave,

        [string[]]
        $ListenAddresses,

        [bool]
        $LocalNetPriority,

        [uint32]
        $LogFileMaxSize,

        [string]
        $LogFilePath,

        [string[]]
        $LogIPFilterList,

        [uint32]
        $LogLevel,

        [bool]
        $LooseWildcarding,

        [uint32]
        $MaxCacheTTL,

        [uint32]
        $MaxNegativeCacheTTL,

        [uint32]
        $NameCheckFlag,

        [bool]
        $NoRecursion,

        [uint32]
        $RecursionRetry,

        [uint32]
        $RecursionTimeout,

        [bool]
        $RoundRobin,

        [int16]
        $RpcProtocol,

        [uint32]
        $ScavengingInterval,

        [bool]
        $SecureResponses,

        [uint32]
        $SendPort,

        [bool]
        $StrictFileParsing,

        [uint32]
        $UpdateOptions,

        [bool]
        $WriteAuthorityNS,

        [uint32]
        $XfrConnectTimeout
    )

    $currentState = Get-TargetResource -Name $Name

    $desiredState = $PSBoundParameters
    $result = Test-DscParameterState -CurrentValues $currentState -DesiredValues $desiredState -TurnOffTypeChecking -Verbose:$VerbosePreference
    
    return $result
}

<#
        .SYNOPSIS    
        Internal function to get results from the PS_DnsServerDiagnostics.
        This is needed because LogIpFilterList is not returned by querying the MicrosoftDNS_Server class.
#>
function Get-PsDnsServerDiagnosticsClass
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]

    $invokeCimMethodParameters = @{
        NameSpace   = 'root/Microsoft/Windows/DNS'
        ClassName   = 'PS_DnsServerDiagnostics'
        MethodName  = 'Get'
        ErrorAction = 'Stop'
    }

    $cimDnsServerDiagnostics = Invoke-CimMethod @invokeCimMethodParameters
    $cimDnsServerDiagnostics.cmdletOutput

}

Export-ModuleMember -Function *-TargetResource
