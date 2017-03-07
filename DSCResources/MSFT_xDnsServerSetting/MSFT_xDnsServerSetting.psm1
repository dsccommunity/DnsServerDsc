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
        [string]
        $Name
    )

    try
    {
        $dnsServerInstance = Get-CimInstance -Namespace root\MicrosoftDNS -ClassName MicrosoftDNS_Server -ErrorAction Stop        
    }
    catch
    {
        if ($_.Exception.Message -match 'Invalid namespace')
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

   
    $compareDnsSettingsResult = Compare-xDnsServerSetting @PSBoundParameters

    return $compareDnsSettingsResult
}

# Internal function to compare property values that are arrays
function Compare-Array
{
    [OutputType([bool])]
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

    $PSBoundParameters.Remove('Name') | Out-Null
    $dnsProperties = Remove-CommonParameter -InputParameter $PSBoundParameters 

    try
    {
        $dnsServerInstance = Get-TargetResource -Name $Name
    }
    catch
    {
        if ($_.Exception.Message -match 'Invalid namespace')
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

<#
        .SYNOPSIS
        Internal function to compare property values that are arrays
#>
function Compare-Array
{
    [OutputType([bool])]
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

<#
        .SYNOPSIS
        Internal function to remove all common parameters from $PSBoundParameters before it is passed to Set-CimInstance
#>
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

<#
        .SYNOPSIS
        Internal function to compare desired settings with current settings
#>
function Compare-xDnsServerSetting
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

        [string[]]
        $LogIPFilterList,

        [bool]
        $LocalNetPriority,

        [uint32]
        $LogFileMaxSize,

        [string]
        $LogFilePath,

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

    $PSBoundParameters.Remove('Name') | Out-Null
    $dnsProperties = Remove-CommonParameter -InputParameter $PSBoundParameters 

    try
    {
        $dnsServerInstance = Get-TargetResource -Name $Name
    }
    catch
    {
        if ($_.Exception.Message -match 'Invalid namespace')
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

Export-ModuleMember -Function *-TargetResource
