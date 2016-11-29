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
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    try
    {
        $dnsServerInstance = Get-CimInstance -Namespace root\MicrosoftDNS -ClassName MicrosoftDNS_Server -ErrorAction Stop
    }
    catch
    {
        if ($_.Exception.Message -match "Invalid namespace")
        {
            throw ($localizedData.DnsClassNotFound)
        }
        else
        {
            throw $_
        }
    }
    
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
        DsAvailable = $dnsServerInstance.DsAvailable
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
        LogIPFilterList = $dnsServerInstance.LogIPFilterList
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
        [System.String]
        $Name,

        [System.UInt32]
        $AddressAnswerLimit,

        [System.UInt32]
        $AllowUpdate,

        [System.Boolean]
        $AutoCacheUpdate,

        [System.UInt32]
        $AutoConfigFileZones,

        [System.Boolean]
        $BindSecondaries,

        [System.UInt32]
        $BootMethod,

        [System.Boolean]
        $DefaultAgingState,

        [System.UInt32]
        $DefaultNoRefreshInterval,

        [System.UInt32]
        $DefaultRefreshInterval,

        [System.Boolean]
        $DisableAutoReverseZones,

        [System.Boolean]
        $DisjointNets,

        [System.Boolean]
        $DsAvailable,

        [System.UInt32]
        $DsPollingInterval,

        [System.UInt32]
        $DsTombstoneInterval,

        [System.UInt32]
        $EDnsCacheTimeout,

        [System.Boolean]
        $EnableDirectoryPartitions,

        [System.UInt32]
        $EnableDnsSec,

        [System.Boolean]
        $EnableEDnsProbes,

        [System.UInt32]
        $EventLogLevel,

        [System.UInt32]
        $ForwardDelegations,

        [System.String[]]
        $Forwarders,

        [System.UInt32]
        $ForwardingTimeout,

        [System.Boolean]
        $IsSlave,

        [System.String[]]
        $ListenAddresses,

        [System.Boolean]
        $LocalNetPriority,

        [System.UInt32]
        $LogFileMaxSize,

        [System.String]
        $LogFilePath,

        [System.String[]]
        $LogIPFilterList,

        [System.UInt32]
        $LogLevel,

        [System.Boolean]
        $LooseWildcarding,

        [System.UInt32]
        $MaxCacheTTL,

        [System.UInt32]
        $MaxNegativeCacheTTL,

        [System.UInt32]
        $NameCheckFlag,

        [System.Boolean]
        $NoRecursion,

        [System.UInt32]
        $RecursionRetry,

        [System.UInt32]
        $RecursionTimeout,

        [System.Boolean]
        $RoundRobin,

        [System.Int16]
        $RpcProtocol,

        [System.UInt32]
        $ScavengingInterval,

        [System.Boolean]
        $SecureResponses,

        [System.UInt32]
        $SendPort,

        [System.Boolean]
        $StrictFileParsing,

        [System.UInt32]
        $UpdateOptions,

        [System.Boolean]
        $WriteAuthorityNS,

        [System.UInt32]
        $XfrConnectTimeout
    )

    $PSBoundParameters.Remove('Name')
    $dnsProperties = Remove-CommonParameter -InputParameter $PSBoundParameters 

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
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.UInt32]
        $AddressAnswerLimit,

        [System.UInt32]
        $AllowUpdate,

        [System.Boolean]
        $AutoCacheUpdate,

        [System.UInt32]
        $AutoConfigFileZones,

        [System.Boolean]
        $BindSecondaries,

        [System.UInt32]
        $BootMethod,

        [System.Boolean]
        $DefaultAgingState,

        [System.UInt32]
        $DefaultNoRefreshInterval,

        [System.UInt32]
        $DefaultRefreshInterval,

        [System.Boolean]
        $DisableAutoReverseZones,

        [System.Boolean]
        $DisjointNets,

        [System.Boolean]
        $DsAvailable,

        [System.UInt32]
        $DsPollingInterval,

        [System.UInt32]
        $DsTombstoneInterval,

        [System.UInt32]
        $EDnsCacheTimeout,

        [System.Boolean]
        $EnableDirectoryPartitions,

        [System.UInt32]
        $EnableDnsSec,

        [System.Boolean]
        $EnableEDnsProbes,

        [System.UInt32]
        $EventLogLevel,

        [System.UInt32]
        $ForwardDelegations,

        [System.String[]]
        $Forwarders,

        [System.UInt32]
        $ForwardingTimeout,

        [System.Boolean]
        $IsSlave,

        [System.String[]]
        $ListenAddresses,

        [System.Boolean]
        $LocalNetPriority,

        [System.UInt32]
        $LogFileMaxSize,

        [System.String]
        $LogFilePath,

        [System.String[]]
        $LogIPFilterList,

        [System.UInt32]
        $LogLevel,

        [System.Boolean]
        $LooseWildcarding,

        [System.UInt32]
        $MaxCacheTTL,

        [System.UInt32]
        $MaxNegativeCacheTTL,

        [System.UInt32]
        $NameCheckFlag,

        [System.Boolean]
        $NoRecursion,

        [System.UInt32]
        $RecursionRetry,

        [System.UInt32]
        $RecursionTimeout,

        [System.Boolean]
        $RoundRobin,

        [System.Int16]
        $RpcProtocol,

        [System.UInt32]
        $ScavengingInterval,

        [System.Boolean]
        $SecureResponses,

        [System.UInt32]
        $SendPort,

        [System.Boolean]
        $StrictFileParsing,

        [System.UInt32]
        $UpdateOptions,

        [System.Boolean]
        $WriteAuthorityNS,

        [System.UInt32]
        $XfrConnectTimeout
    )

   
    $compareDnsSettingsResult = Compare-xDnsServerSetting @PSBoundParameters

    return $compareDnsSettingsResult
}

# Internal function to compare property values that are arrays
function Compare-Array
{
    [OutputType([System.Boolean])]
    [cmdletbinding()]
    param
    (
        [System.array]
        $ReferenceObject,

        [System.array]
        $DifferenceObject
    )

    if($null -ne $ReferenceObject -and $null -ne $DifferenceObject)
    {
        $compare = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject

        if ($compare)
        {    
            return $false
        }
        else
        {    
            return $true
        }
    }
    elseIf ($null -eq $ReferenceObject -and $null -eq $DifferenceObject)
    {
        return $true
    }
    else
    {
        return $false
    }


}

#Internal function to remove all common parameters from $PSBoundParameters before it is passed to Set-CimInstance
function Remove-CommonParameter
{
    [OutputType([System.Collections.Hashtable])]
    [cmdletbinding()]
    param
    (
        [hashtable]
        $InputParameter
    )

    $inputClone = $InputParameter.Clone()
    $commonParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
    $commonParameters += [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    foreach ($parameter in $InputParameter.Keys)
    {
        foreach ($commonParameter in $commonParameters)
        {
            if ($parameter -eq $commonParameter)
            {
                $inputClone.Remove($parameter)
            }
        }
    }

    $inputClone
}

# Internal function to compare desired settings with current settings
function Compare-xDnsServerSetting
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.UInt32]
        $AddressAnswerLimit,

        [System.UInt32]
        $AllowUpdate,

        [System.Boolean]
        $AutoCacheUpdate,

        [System.UInt32]
        $AutoConfigFileZones,

        [System.Boolean]
        $BindSecondaries,

        [System.UInt32]
        $BootMethod,

        [System.Boolean]
        $DefaultAgingState,

        [System.UInt32]
        $DefaultNoRefreshInterval,

        [System.UInt32]
        $DefaultRefreshInterval,

        [System.Boolean]
        $DisableAutoReverseZones,

        [System.Boolean]
        $DisjointNets,

        [System.Boolean]
        $DsAvailable,

        [System.UInt32]
        $DsPollingInterval,

        [System.UInt32]
        $DsTombstoneInterval,

        [System.UInt32]
        $EDnsCacheTimeout,

        [System.Boolean]
        $EnableDirectoryPartitions,

        [System.UInt32]
        $EnableDnsSec,

        [System.Boolean]
        $EnableEDnsProbes,

        [System.UInt32]
        $EventLogLevel,

        [System.UInt32]
        $ForwardDelegations,

        [System.String[]]
        $Forwarders,

        [System.UInt32]
        $ForwardingTimeout,

        [System.Boolean]
        $IsSlave,

        [System.String[]]
        $ListenAddresses,

        [System.Boolean]
        $LocalNetPriority,

        [System.UInt32]
        $LogFileMaxSize,

        [System.String]
        $LogFilePath,

        [System.String[]]
        $LogIPFilterList,

        [System.UInt32]
        $LogLevel,

        [System.Boolean]
        $LooseWildcarding,

        [System.UInt32]
        $MaxCacheTTL,

        [System.UInt32]
        $MaxNegativeCacheTTL,

        [System.UInt32]
        $NameCheckFlag,

        [System.Boolean]
        $NoRecursion,

        [System.UInt32]
        $RecursionRetry,

        [System.UInt32]
        $RecursionTimeout,

        [System.Boolean]
        $RoundRobin,

        [System.Int16]
        $RpcProtocol,

        [System.UInt32]
        $ScavengingInterval,

        [System.Boolean]
        $SecureResponses,

        [System.UInt32]
        $SendPort,

        [System.Boolean]
        $StrictFileParsing,

        [System.UInt32]
        $UpdateOptions,

        [System.Boolean]
        $WriteAuthorityNS,

        [System.UInt32]
        $XfrConnectTimeout
    )

    $PSBoundParameters.Remove('Name') | Out-Null
    $dnsProperties = Remove-CommonParameter -InputParameter $PSBoundParameters 

    try
    {
        $dnsServerInstance = Get-CimInstance -Namespace root\MicrosoftDNS -ClassName MicrosoftDNS_Server -ErrorAction Stop
    }
    catch
    {
        if ($_.Exception.Message -match "Invalid namespace")
        {
            throw ($localizedData.DnsClassNotFound)
        }
        else
        {
            throw $_
        }
    }

    foreach ($key in $dnsProperties.Keys)
    {
        if ($null -eq $dnsProperties[$key])
        {
            if ($null -ne $dnsServerInstance.$key)
            {
                Write-Verbose -Message ($localizedData.ParameterExpectedNull -f $key)
                return $false
            }          
        }
        elseIf ($dnsProperties[$key].GetType() -eq [string[]])
        {
            $compareResult = $null
            $compareResult = Compare-Array -ReferenceObject $dnsProperties.$key -DifferenceObject $dnsServerInstance.$key

            if ($compareResult -eq $false)
            {
                Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                    $key,
                    ($dnsProperties[$key] -join ',') ,
                    ($dnsServerInstance.$key -join ',')
                )

                return $false
            }            
        }
        else
        {
            if ($dnsProperties[$key] -ne $dnsServerInstance.$key)
            {
                Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                    $key,
                    $dnsProperties[$key],
                    $dnsServerInstance.$key
                )

                return $false
            }
        }
    }

    return $true
}

Export-ModuleMember -Function * #-TargetResource

