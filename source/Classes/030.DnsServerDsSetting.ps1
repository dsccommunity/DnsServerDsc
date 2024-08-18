<#
    .SYNOPSIS
        The DnsServerDsSetting DSC resource manages DNS Active Directory settings
        on a Microsoft Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsServerDsSetting DSC resource manages DNS Active Directory settings
        on a Microsoft Domain Name System (DNS) server.

    .PARAMETER DnsServer
        The host name of the Domain Name System (DNS) server, or use `'localhost'`
        for the current node.

    .PARAMETER DirectoryPartitionAutoEnlistInterval
        Specifies the interval, during which a DNS server tries to enlist itself
        in a DNS domain partition and DNS forest partition, if it is not already
        enlisted. We recommend that you limit this value to the range one hour to
        180 days, inclusive, but you can use any value. We recommend that you set
        the default value to one day. You must set the value 0 (zero) as a flag
        value for the default value. However, you can allow zero and treat it
        literally.

    .PARAMETER LazyUpdateInterval
        Specifies a value, in seconds, to determine how frequently the DNS server
        submits updates to the directory server without specifying the
        LDAP_SERVER_LAZY_COMMIT_OID control ([MS-ADTS] section 3.1.1.3.4.1.7) at
        the same time that it processes DNS dynamic update requests. We recommend
        that you limit this value to the range 0x00000000 to 0x0000003c. You must
        set the default value to 0x00000003. You must set the value zero to
        indicate that the DNS server does not specify the
        LDAP_SERVER_LAZY_COMMIT_OID control at the same time that it processes
        DNS dynamic update requests. For more information about
        LDAP_SERVER_LAZY_COMMIT_OID, see LDAP_SERVER_LAZY_COMMIT_OID control
        code. The LDAP_SERVER_LAZY_COMMIT_OID control instructs the DNS server
        to return the results of a directory service modification command after
        it is completed in memory but before it is committed to disk. In this
        way, the server can return results quickly and save data to disk without
        sacrificing performance. The DNS server must send this control only to
        the directory server that is attached to an LDAP update that the DNS
        server initiates in response to a DNS dynamic update request. If the
        value is nonzero, LDAP updates that occur during the processing of DNS
        dynamic update requests must not specify the LDAP_SERVER_LAZY_COMMIT_OID
        control if a period of less than DsLazyUpdateInterval seconds has passed
        since the last LDAP update that specifies this control. If a period that
        is greater than DsLazyUpdateInterval seconds passes, during which time
        the DNS server does not perform an LDAP update that specifies this
        control, the DNS server must specify this control on the next update.

    .PARAMETER MinimumBackgroundLoadThreads
        Specifies the minimum number of background threads that the DNS server
        uses to load zone data from the directory service. You must limit this
        value to the range 0x00000000 to 0x00000005, inclusive. You must set the
        default value to 0x00000001, and you must treat the value zero as a flag
        value for the default value.

    .PARAMETER PollingInterval
        Specifies how frequently the DNS server polls Active Directory Domain
        Services (AD DS) for changes in Active Directory-integrated zones. You
        must limit the value to the range 30 seconds to 3,600 seconds, inclusive.

    .PARAMETER RemoteReplicationDelay
        Specifies the minimum interval, in seconds, that the DNS server waits
        between the time that it determines that a single object has changed on
        a remote directory server, to the time that it tries to replicate a
        single object change. You must limit the value to the range 0x00000005
        to 0x00000E10, inclusive. You must set the default value to 0x0000001E,
        and you must treat the value zero as a flag value for the default value.

    .PARAMETER TombstoneInterval
        Specifies the amount of time that DNS keeps tombstoned records alive in
        Active Directory. We recommend that you limit this value to the range
        three days to eight weeks, inclusive, but you can set it to any value in
        the range 82 hours to 8 weeks. We recommend that you set the default
        value to 14 days and treat the value zero as a flag value for the
        default. However, you can allow the value zero and treat it literally.
        At 2:00 A.M. local time every day, the DNS server must search all
        directory service zones for nodes that have the Active Directory
        dnsTombstoned attribute set to True, and for a directory service
        EntombedTime (section 2.2.2.2.3.23 of MS-DNSP) value that is greater
        than previous directory service DSTombstoneInterval seconds. You must
        permanently delete all such nodes from the directory server.

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.
#>

[DscResource()]
class DnsServerDsSetting : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $DnsServer

    [DscProperty()]
    [System.String]
    $DirectoryPartitionAutoEnlistInterval

    [DscProperty()]
    [Nullable[System.UInt32]]
    $LazyUpdateInterval

    [DscProperty()]
    [Nullable[System.UInt32]]
    $MinimumBackgroundLoadThreads

    [DscProperty()]
    [System.String]
    $PollingInterval

    [DscProperty()]
    [Nullable[System.UInt32]]
    $RemoteReplicationDelay

    [DscProperty()]
    [System.String]
    $TombstoneInterval

    [DscProperty(NotConfigurable)]
    [DnsServerReason[]]
    $Reasons

    DnsServerDsSetting() : base ($PSScriptRoot)
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'DnsServer'
        )
    }

    [DnsServerDsSetting] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    # Base method Get() call this method to get the current state as a Hashtable.
    [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $getParameters = @{
            ComputerName = $properties.DnsServer
        }

        $getCurrentStateResult = Get-DnsServerDsSetting @getParameters

        $state = @{
            DnsServer                            = $properties.DnsServer
            DirectoryPartitionAutoEnlistInterval = $getCurrentStateResult.DirectoryPartitionAutoEnlistInterval
            LazyUpdateInterval                   = [System.UInt32] $getCurrentStateResult.LazyUpdateInterval
            MinimumBackgroundLoadThreads         = [System.UInt32] $getCurrentStateResult.MinimumBackgroundLoadThreads
            PollingInterval                      = $getCurrentStateResult.PollingInterval
            RemoteReplicationDelay               = [System.UInt32] $getCurrentStateResult.RemoteReplicationDelay
            TombstoneInterval                    = $getCurrentStateResult.TombstoneInterval
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
        Set-DnsServerDsSetting @properties
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        @(
            'DirectoryPartitionAutoEnlistInterval',
            'TombstoneInterval'
        ) | ForEach-Object -Process {

            # Only evaluate properties that have a value.
            if ($null -ne $properties.$_)
            {
                Assert-TimeSpan -PropertyName $_ -Value $properties.$_ -Minimum '0.00:00:00'
            }
        }
    }
}
