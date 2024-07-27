<#
    .SYNOPSIS
        The DnsServerScavenging DSC resource manages scavenging on a Microsoft
        Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsServerScavenging DSC resource manages scavenging on a Microsoft
        Domain Name System (DNS) server.

    .PARAMETER DnsServer
        The host name of the Domain Name System (DNS) server, or use 'localhost'
        for the current node.

    .PARAMETER ScavengingState
        Specifies whether to Enable automatic scavenging of stale records.
        `ScavengingState` determines whether the DNS scavenging feature is enabled
        by default on newly created zones.

    .PARAMETER ScavengingInterval
        Specifies a length of time as a value that can be converted to a `[TimeSpan]`
        object. `ScavengingInterval` determines whether the scavenging feature for
        the DNS server is enabled and sets the number of hours between scavenging
        cycles. The value `0` disables scavenging for the DNS server. A setting
        greater than `0` enables scavenging for the server and sets the number of
        days, hours, minutes, and seconds (formatted as dd.hh:mm:ss) between
        scavenging cycles. The minimum value is 0. The maximum value is 365.00:00:00
        (1 year).

    .PARAMETER RefreshInterval
        Specifies the refresh interval as a value that can be converted to a `[TimeSpan]`
        object (formatted as dd.hh:mm:ss). During this interval, a DNS server can
        refresh a resource record that has a non-zero time stamp. Zones on the server
        inherit this value automatically. If a DNS server does not refresh a resource
        record that has a non-zero time stamp, the DNS server can remove that record
        during the next scavenging. Do not select a value smaller than the longest
        refresh period of a resource record registered in the zone. The minimum value
        is `0`. The maximum value is 365.00:00:00 (1 year).

    .PARAMETER NoRefreshInterval
        Specifies a length of time as a value that can be converted to a `[TimeSpan]`
        object (formatted as dd.hh:mm:ss). `NoRefreshInterval` sets a period of time
        in which no refreshes are accepted for dynamically updated records. Zones on
        the server inherit this value automatically. This value is the interval between
        the last update of a timestamp for a record and the earliest time when the
        timestamp can be refreshed. The minimum value is 0. The maximum value is
        365.00:00:00 (1 year).

    .PARAMETER LastScavengeTime
        The time when the last scavenging cycle was executed.
#>

[DscResource()]
class DnsServerScavenging : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $DnsServer

    [DscProperty()]
    [Nullable[System.Boolean]]
    $ScavengingState

    [DscProperty()]
    [System.String]
    $ScavengingInterval

    [DscProperty()]
    [System.String]
    $RefreshInterval

    [DscProperty()]
    [System.String]
    $NoRefreshInterval

    [DscProperty(NotConfigurable)]
    [Nullable[System.DateTime]]
    $LastScavengeTime

    DnsServerScavenging()
    {
    }

    [DnsServerScavenging] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    # Base method Get() call this method to get the current state as a CimInstance.
    [Microsoft.Management.Infrastructure.CimInstance] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        return (Get-DnsServerScavenging @properties)
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced and that are not in desired state.
    #>
    [void] Modify([System.Collections.Hashtable] $properties)
    {
        Set-DnsServerScavenging @properties
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    hidden [void] AssertProperties()
    {
        @(
            'ScavengingInterval'
            'RefreshInterval'
            'NoRefreshInterval'
        ) | ForEach-Object -Process {
            $valueToConvert = $this.$_

            # Only evaluate properties that have a value.
            if ($null -ne $valueToConvert)
            {
                Assert-TimeSpan -PropertyName $_ -Value $valueToConvert -Maximum '365.00:00:00' -Minimum '0.00:00:00'
            }
        }
    }
}
