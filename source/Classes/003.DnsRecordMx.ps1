<#
    .SYNOPSIS
        The DnsRecordMx DSC resource manages MX DNS records against a specific zone on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordMx DSC resource manages MX DNS records against a specific zone on a Domain Name System (DNS) server.

    .PARAMETER EmailDomain
       Everything after the '@' in the email addresses supported by this mail exchanger. It must be a subdomain the zone or the zone itself. To specify all subdomains, use the '*' character (i.e.: *.contoso.com). (Key Parameter)

    .PARAMETER MailExchange
       FQDN of the server handling email for the specified email domain. When setting the value, this FQDN must resolve to an IP address and cannot reference a CNAME record. (Key Parameter)

    .PARAMETER Priority
       Specifies the priority for this MX record among other MX records that belong to the same email domain, where a lower value has a higher priority. (Mandatory Parameter)
#>

[DscResource()]
class DnsRecordMx : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $EmailDomain

    [DscProperty(Key)]
    [System.String]
    $MailExchange

    [DscProperty(Mandatory)]
    [System.UInt16]
    $Priority

    [DnsRecordMx] Get()
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
        $recordName = $null
        $regexMatch = $this.EmailDomain | Select-String -Pattern "^((.*?)\.){0,1}$($this.ZoneName)`$"
        if ($null -eq $regexMatch)
        {
            throw ($this.localizedData.DomainZoneMismatch -f $this.EmailDomain, $this.ZoneName)
        }
        else
        {
            # Match group 2 contains the value in which we are interested.
            $recordName = $regexMatch.Matches.Groups[2].Value
            if ($recordName -eq '')
            {
                $recordName = '.'
            }
        }
        return $recordName
    }

    hidden [Microsoft.Management.Infrastructure.CimInstance] GetResourceRecord()
    {
        Write-Verbose -Message ($this.localizedData.GettingDnsRecordMessage -f 'Mx', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'MX'
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $recordName = $this.getRecordName()
            if ($recordName -eq '.')
            {
                $recordName = '@'
            }
            $_.HostName -eq $recordName -and
            $_.RecordData.MailExchange -eq "$($this.MailExchange)."
        }

        return $record
    }

    hidden [DnsRecordMx] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordMx] @{
            ZoneName     = $this.ZoneName
            EmailDomain  = $this.EmailDomain
            MailExchange = $this.MailExchange
            Priority     = $record.RecordData.Preference
            TimeToLive   = $record.TimeToLive.ToString()
            DnsServer    = $this.DnsServer
            Ensure       = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            MX           = $true
            Name         = $this.getRecordName()
            MailExchange = $this.MailExchange
            Preference   = $this.Priority
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($this.localizedData.CreatingDnsRecordMessage -f 'MX', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

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

                'Priority'
                {
                    $newRecord.RecordData.Preference = $propertyToChange.ExpectedValue
                }

                'TimeToLive'
                {
                    $newRecord.TimeToLive = [System.TimeSpan] $propertyToChange.ExpectedValue
                }

            }
        }

        Set-DnsServerResourceRecord @dnsParameters -OldInputObject $existingRecord -NewInputObject $newRecord -Verbose
    }
}
