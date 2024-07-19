<#
    .SYNOPSIS
        The DnsServerEDns DSC resource manages _extension mechanisms for DNS (EDNS)_
        on a Microsoft Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsServerEDns DSC resource manages _extension mechanisms for DNS (EDNS)_
        on a Microsoft Domain Name System (DNS) server.

    .PARAMETER DnsServer
        The host name of the Domain Name System (DNS) server, or use `'localhost'`
        for the current node.

    .PARAMETER CacheTimeout
        Specifies the number of seconds that the DNS server caches EDNS information.

    .PARAMETER EnableProbes
        Specifies whether to enable the server to probe other servers to determine
        whether they support EDNS.

    .PARAMETER EnableReception
        Specifies whether the DNS server accepts queries that contain an EDNS record.
#>

[DscResource()]
class DnsServerEDns : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $DnsServer

    [DscProperty()]
    [System.String]
    $CacheTimeout

    [DscProperty()]
    [Nullable[System.Boolean]]
    $EnableProbes

    [DscProperty()]
    [Nullable[System.Boolean]]
    $EnableReception

    [DnsServerEDns] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    # Base method Get() call this method to get the current state as a CimInstance.
    [Microsoft.Management.Infrastructure.CimInstance] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        return (Get-DnsServerEDns @properties)
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
        Set-DnsServerEDns @properties
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    hidden [void] AssertProperties()
    {
        @(
            'CacheTimeout'
        ) | ForEach-Object -Process {
            $valueToConvert = $this.$_

            # Only evaluate properties that have a value.
            if ($null -ne $valueToConvert)
            {
                Assert-TimeSpan -PropertyName $_ -Value $valueToConvert -Minimum '0.00:00:00'
            }
        }
    }
}
