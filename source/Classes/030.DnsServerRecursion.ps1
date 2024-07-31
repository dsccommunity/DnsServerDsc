<#
    .SYNOPSIS
        The DnsServerRecursion DSC resource manages recursion settings on a Microsoft
        Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsServerRecursion DSC resource manages recursion settings on a Microsoft
        Domain Name System (DNS) server. Recursion occurs when a DNS server queries
        other DNS servers on behalf of a requesting client, and then sends the answer
        back to the client.

        The property `SecureResponse` that can be set by the cmdlet `Set-DnsServerRecursion`
        changes the same value as `EnablePollutionProtection` in the resource _DnsServerCache_
        does. Use the property `EnablePollutionProtection` in the resource _DnsServerCache_
        to enforce pollution protection.

    .PARAMETER DnsServer
        The host name of the Domain Name System (DNS) server, or use `'localhost'`
        for the current node.

    .PARAMETER Enable
        Specifies whether the server enables recursion.

    .PARAMETER AdditionalTimeout
        Specifies the time interval, in seconds, that a DNS server waits as it uses
        recursion to get resource records from a remote DNS server. Valid values are
        in the range of `1` second to `15` seconds. See recommendation in the documentation
        of [Set-DnsServerRecursion](https://docs.microsoft.com/en-us/powershell/module/dnsserver/set-dnsserverrecursion).

    .PARAMETER RetryInterval
        Specifies elapsed seconds before a DNS server retries a recursive lookup.
        Valid values are in the range of `1` second to `15` seconds. The
        recommendation is that in general this value should not be change. However,
        under a few circumstances it can be considered changing the value. For
        example, if a DNS server contacts a remote DNS server over a slow link and
        retries the lookup before it gets a response, it could help to raise the
        retry interval to be slightly longer than the observed response time.
        See recommendation in the documentation of [Set-DnsServerRecursion](https://docs.microsoft.com/en-us/powershell/module/dnsserver/set-dnsserverrecursion).

    .PARAMETER Timeout
        Specifies the number of seconds that a DNS server waits before it stops
        trying to contact a remote server. The valid value is in the range of `1`
        second to `15` seconds. Recommendation is to increase this value when
        recursion occurs over a slow link. See recommendation in the documentation
        of [Set-DnsServerRecursion](https://docs.microsoft.com/en-us/powershell/module/dnsserver/set-dnsserverrecursion).

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.

    .NOTES
        The cmdlet Set-DsnServerRecursion allows to set the value 0 (zero) for the
        properties AdditionalTimeout, RetryInterval, and Timeout, but setting the
        value 0 reverts the property to its respectively default value. The default
        value for the properties on Windows Server 2016 is 4 seconds for property
        AdditionalTimeout, 3 seconds for RetryInterval, and 8 seconds for property
        Timeout. If it was allowed to set 0 (zero) as the value in this resource
        for these properties then the state would never become in desired state.
#>

[DscResource()]
class DnsServerRecursion : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $DnsServer

    [DscProperty()]
    [Nullable[System.Boolean]]
    $Enable

    [DscProperty()]
    [Nullable[System.UInt32]]
    $AdditionalTimeout

    [DscProperty()]
    [Nullable[System.UInt32]]
    $RetryInterval

    [DscProperty()]
    [Nullable[System.UInt32]]
    $Timeout

    [DscProperty(NotConfigurable)]
    [Reason[]]
    $Reasons

    DnsServerRecursion() : base ($PSScriptRoot)
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'DnsServer'
        )
    }

    [DnsServerRecursion] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    # Base method Get() call this method to get the current state as a Hashtable.
    [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $getParameters = @{
            ComputerName = 'localhost'
        }

        # Set ComputerName depending on value of DnsServer.
        if ($properties.DnsServer -ne 'localhost')
        {
            $getParameters.ComputerName = $properties.DnsServer
        }

        $getCurrentStateResult = Get-DnsServerRecursion @getParameters

        $state = @{
            DnsServer         = $properties.DnsServer
            Enable            = $getCurrentStateResult.Enable
            AdditionalTimeout = [System.UInt32] $getCurrentStateResult.AdditionalTimeout
            RetryInterval     = [System.UInt32] $getCurrentStateResult.RetryInterval
            Timeout           = [System.UInt32] $getCurrentStateResult.Timeout
        }

        return $state
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
        Set-DnsServerRecursion @properties
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    # Called by the base method Set() and Test() to assert that all properties are valid.
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        @(
            'AdditionalTimeout'
            'RetryInterval'
            'Timeout'
        ) | ForEach-Object -Process {
            $propertyValue = $this.$_

            # Only evaluate properties that have a value.
            if ($null -ne $propertyValue -and $propertyValue -notin (1..15))
            {
                $errorMessage = $this.localizedData.PropertyIsNotInValidRange -f $_, $propertyValue

                New-InvalidOperationException -Message $errorMessage
            }
        }
    }
}
