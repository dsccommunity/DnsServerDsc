<#
    .SYNOPSIS
        The DnsRecordAaaa DSC resource manages AAAA DNS records against a specific zone on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordAaaa DSC resource manages AAAA DNS records against a specific zone on a Domain Name System (DNS) server.

    .PARAMETER Name
        Specifies the name of a DNS server resource record object. (Key Parameter)

    .PARAMETER IPv6Address
        Specifies the IPv6 address of a host. (Key Parameter)
#>

[DscResource()]
class DnsRecordAaaa : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $Name

    [DscProperty(Key)]
    [System.String]
    $IPv6Address

    [DnsRecordAaaa] Get()
    {
        return ([DnsRecordBase] $this).Get()
    }

    [void] Set()
    {
        ([DnsRecordBase] $this).Set()
    }

    [System.Boolean] Test()
    {
        return ([DnsRecordBase] $this).Test()
    }

    hidden [Microsoft.Management.Infrastructure.CimInstance] GetResourceRecord()
    {
        Write-Verbose -Message ($this.localizedData.GettingDnsRecordMessage -f 'Aaaa', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'AAAA'
            Name         = $this.Name
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
                $_.RecordData.IPv6Address -eq $this.IPv6Address
        }

        return $record
    }

    hidden [DnsRecordAaaa] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordAaaa] @{
            ZoneName    = $this.ZoneName
            Name        = $this.Name
            IPv6Address = $this.IPv6Address
            TimeToLive  = $record.TimeToLive.ToString()
            DnsServer   = $this.DnsServer
            Ensure      = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            AAAA         = $true
            Name         = $this.name
            IPv6Address  = $this.IPv6Address
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($this.localizedData.CreatingDnsRecordMessage -f 'AAAA', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        Add-DnsServerResourceRecord @dnsParameters
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        # Copy the existing record and modify values as appropriate
        $newRecord = [Microsoft.Management.Infrastructure.CimInstance]::new($existingRecord)

        foreach ($propertyToChange in $propertiesNotInDesiredState)
        {
            switch ($propertyToChange.Property)
            {
                # Key parameters will never be affected, so only include Mandatory and Optional values in the switch statement
                'TimeToLive'
                {
                    $newRecord.TimeToLive = [System.TimeSpan] $propertyToChange.ExpectedValue
                }

            }
        }

        Set-DnsServerResourceRecord @dnsParameters -OldInputObject $existingRecord -NewInputObject $newRecord -Verbose
    }
}
