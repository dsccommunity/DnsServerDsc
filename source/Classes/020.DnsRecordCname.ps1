<#
    .SYNOPSIS
        The DnsRecordCname DSC resource manages CNAME DNS records against a specific zone on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordCname DSC resource manages CNAME DNS records against a specific zone on a Domain Name System (DNS) server.

    .PARAMETER Name
        Specifies the name of a DNS server resource record object. (Key Parameter)

    .PARAMETER HostNameAlias
        Specifies a a canonical name target for a CNAME record. This must be a fully qualified domain name (FQDN). (Key Parameter)
        Dot at the end of provided value will be added automatically by DNS itself,
        but you can still write it in configuration for clarity.

    .NOTES
        When creating a CNAME record using Get-DnsServerResourceRecord, the required trailing dot in the FQDN is added automatically.
        Therefore, in the DSC configuration, we can use either format (with or without a trailing dot),
        but the returned result will always include the dot.
#>

[DscResource()]
class DnsRecordCname : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $Name

    [DscProperty(Key)]
    [System.String]
    $HostNameAlias

    DnsRecordCname()
    {
    }

    [DnsRecordCname] Get()
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
        # If HostNameAlias provided without dot at the end, then adding it.
        if (-not $this.HostNameAlias.EndsWith('.'))
        {
            $this.HostNameAlias = $this.HostNameAlias + '.'
        }

        Write-Verbose -Message ($this.localizedData.GettingDnsRecordMessage -f 'CNAME', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'CNAME'
            Name         = $this.Name
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_.RecordData.HostNameAlias -eq "$($this.HostnameAlias)."
        }

        return $record
    }

    hidden [DnsRecordCname] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        # If HostNameAlias provided without dot at the end, then adding it.
        if (-not $this.HostNameAlias.EndsWith('.'))
        {
            $this.HostNameAlias = $this.HostNameAlias + '.'
        }

        $dscResourceObject = [DnsRecordCname] @{
            ZoneName      = $this.ZoneName
            Name          = $this.Name
            HostNameAlias = $this.HostNameAlias
            TimeToLive    = $record.TimeToLive.ToString()
            DnsServer     = $this.DnsServer
            Ensure        = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        # If HostNameAlias provided without dot at the end, then adding it.
        if (-not $this.HostNameAlias.EndsWith('.'))
        {
            $this.HostNameAlias = $this.HostNameAlias + '.'
        }

        $dnsParameters = @{
            ZoneName      = $this.ZoneName
            ComputerName  = $this.DnsServer
            CNAME         = $true
            Name          = $this.Name
            HostNameAlias = $this.HostNameAlias
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($this.localizedData.CreatingDnsRecordMessage -f 'CNAME', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        Add-DnsServerResourceRecord @dnsParameters
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        # If HostNameAlias provided without dot at the end, then adding it.
        if (-not $this.HostNameAlias.EndsWith('.'))
        {
            $this.HostNameAlias = $this.HostNameAlias + '.'
        }

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
