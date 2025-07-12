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
        but special RFC compliant regex is used for validation to prevent undesirable behavior when value is malformatted.
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
        # Per RFC 1035 DNS standards, this regex ensures valid FQDN format requiring a terminating dot (based on AI verification)
        $HostNameAliasRegex = '^(?!.{254})(?:(?!-)[a-z0-9-]{1,63}(?<!-)\.)+(?:(?!-)[a-z0-9-]{1,63}(?<!-))\.$'
        # If HostNameAlias provided without dot at the end and not match RFC regex, then throwing
        if ($this.HostNameAlias -notmatch $HostNameAliasRegex)
        {
            $errorMessage = $script:localizedData.HostNameAliasMalformattedMessage -f $HostNameAliasRegex
            New-ArgumentException -ArgumentName 'HostNameAliasRegex' -Message $errorMessage
        }
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
            $_.RecordData.HostNameAlias -eq $this.HostnameAlias
        }

        return $record
    }

    hidden [DnsRecordCname] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
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
