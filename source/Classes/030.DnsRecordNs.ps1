<#
    .SYNOPSIS
        The DnsRecordNs DSC resource manages NS DNS records against a specific zone on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordNs DSC resource manages NS DNS records against a specific zone on a Domain Name System (DNS) server.

    .PARAMETER DomainName
        Specifies the fully qualified DNS domain name for which the NameServer is authoritative. It must be a subdomain the zone or the zone itself. To specify all subdomains, use the '*' character (i.e.: *.contoso.com). (Key Parameter)

    .PARAMETER NameServer
        Specifies the name server of a domain. This should be a fully qualified domain name, not an IP address (Key Parameter)
#>

[DscResource()]
class DnsRecordNs : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $DomainName

    [DscProperty(Key)]
    [System.String]
    $NameServer

    DnsRecordNs()
    {
    }

    [DnsRecordNs] Get()
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

    [System.String] getRecordName()
    {
        $aRecordName = $null

        # Use regex matching to determine if the domain name provided is a subdomain of the ZoneName (ends in ZoneName).
        $regexMatch = $this.DomainName | Select-String -Pattern "^((.*?)\.){0,1}$($this.ZoneName)`$"

        if ($null -eq $regexMatch)
        {
            throw ($this.localizedData.DomainZoneMismatch -f $this.DomainName, $this.ZoneName)
        }
        else
        {
            # Match group 2 contains the value in which we are interested.
            $aRecordName = $regexMatch.Matches.Groups[2].Value
            if ($aRecordName -eq '')
            {
                $aRecordName = '.'
            }
        }
        return $aRecordName
    }

    hidden [Microsoft.Management.Infrastructure.CimInstance] GetResourceRecord()
    {
        Write-Verbose -Message ($this.localizedData.GettingDnsRecordMessage -f 'Ns', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'NS'
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $translatedRecordName = $this.getRecordName()
            if ($translatedRecordName -eq '.')
            {
                $translatedRecordName = '@'
            }
            $_.HostName -eq $translatedRecordName -and
            $_.RecordData.NameServer -eq "$($this.NameServer)."
        }

        return $record
    }

    hidden [DnsRecordNs] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordNs] @{
            ZoneName   = $this.ZoneName
            DomainName = $this.DomainName
            NameServer = $this.NameServer
            TimeToLive = $record.TimeToLive.ToString()
            DnsServer  = $this.DnsServer
            Ensure     = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            NS           = $true
            Name         = $this.getRecordName()
            NameServer   = $this.NameServer
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($this.localizedData.CreatingDnsRecordMessage -f 'NS', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

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
