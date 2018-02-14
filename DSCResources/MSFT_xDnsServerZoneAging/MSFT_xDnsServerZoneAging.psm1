
<#
    .SYNOPSIS
        Get the DNS zone aging settings.

    .PARAMETER Name
        Name of the DNS zone.

    .PARAMETER AgingEnabled
        Option to enable scavenge stale resource records on the zone.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $AgingEnabled
    )

    Write-Verbose -Message "Getting the DNS zone aging for $Name ..."

    # Get the current zone aging from the local DNS server
    $zoneAging = Get-DnsServerZoneAging -Name $Name

    return @{
        Name              = $Name
        AgingEnabled      = $zoneAging.AgingEnabled
        RefreshInterval   = $zoneAging.RefreshInterval.TotalHours
        NoRefreshInterval = $zoneAging.NoRefreshInterval.TotalHours
    }
}

<#
    .SYNOPSIS
        Set the DNS zone aging settings.

    .PARAMETER Name
        Name of the DNS zone.

    .PARAMETER AgingEnabled
        Option to enable scavenge stale resource records on the zone.

    .PARAMETER RefreshInterval
        Refresh interval for record scavencing in hours. Default value is 7 days.

    .PARAMETER NoRefreshInterval
        No-refresh interval for record scavencing in hours. Default value is 7 days.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $AgingEnabled,

        [Parameter()]
        [System.UInt32]
        $RefreshInterval = 168,

        [Parameter()]
        [System.UInt32]
        $NoRefreshInterval = 168
    )

    $currentConfiguration = Get-TargetResource -Name $Name -AgingEnabled $AgingEnabled

    # Enable or disable zone aging
    if ($currentConfiguration.AgingEnabled -ne $AgingEnabled)
    {
        Write-Verbose -Message "$() DNS zone aging on $Name ..."
        
        Set-DnsServerZoneAging -Name $Name -Aging $AgingEnabled -WarningAction 'SilentlyContinue'
    }

    # Update the refresh interval
    if ($currentConfiguration.RefreshInterval -ne $RefreshInterval)
    {
        Write-Verbose -Message "Set DNS zone refresh interval to $RefreshInterval hours ..."

        $refreshIntervalTimespan = [System.TimeSpan]::FromHours($RefreshInterval)
        Set-DnsServerZoneAging -Name $Name -RefreshInterval $refreshIntervalTimespan -WarningAction 'SilentlyContinue'
    }

    # Update the no refresh interval
    if ($currentConfiguration.NoRefreshInterval -ne $NoRefreshInterval)
    {
        Write-Verbose -Message "Set DNS zone no refresh interval to $NoRefreshInterval hours ..."

        $noRefreshIntervalTimespan = [System.TimeSpan]::FromHours($NoRefreshInterval)
        Set-DnsServerZoneAging -Name $Name -NoRefreshInterval $noRefreshIntervalTimespan -WarningAction 'SilentlyContinue'
    }
}

<#
    .SYNOPSIS
        Test the DNS zone aging settings.

    .PARAMETER Name
        Name of the DNS zone.

    .PARAMETER AgingEnabled
        Option to enable scavenge stale resource records on the zone.

    .PARAMETER RefreshInterval
        Refresh interval for record scavencing in hours. Default value is 7 days.

    .PARAMETER NoRefreshInterval
        No-refresh interval for record scavencing in hours. Default value is 7 days.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $AgingEnabled,

        [Parameter()]
        [System.UInt32]
        $RefreshInterval = 168,

        [Parameter()]
        [System.UInt32]
        $NoRefreshInterval = 168
    )

    Write-Verbose -Message "Testing the DNS zone aging for $Name ..."

    $currentConfiguration = Get-TargetResource -Name $Name -AgingEnabled $AgingEnabled

    return $currentConfiguration.AgingEnabled -eq $AgingEnabled -and
           $currentConfiguration.RefreshInterval -eq $RefreshInterval -and
           $currentConfiguration.NoRefreshInterval -eq $NoRefreshInterval
}
