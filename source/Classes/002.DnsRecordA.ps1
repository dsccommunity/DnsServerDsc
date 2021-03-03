<#
    .SYNOPSIS
        A DSC Resource for MS DNS Server that represents an A resource record.
    .PARAMETER ZoneName
        Specifies the name of a DNS zone. (Key Parameter)
    .PARAMETER Name
        Specifies the name of a DNS server resource record object. (Key Parameter)
    .PARAMETER IPv4Address
       Specifies the IPv4 address of a host. (Key Parameter)
    .PARAMETER TimeToLive
        Specifies the TimeToLive value of the A record. Value must be in valid TimeSpan string format (i.e.: Days.Hours:Minutes:Seconds.Miliseconds or 30.23:59:59.999).
    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.
    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>

$script:localizedDataDnsRecordA = Get-LocalizedData -DefaultUICulture en-US -FileName 'DnsRecordA.strings.psd1'

[DscResource()]
class DnsRecordA : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String] $Name

    [DscProperty(Key)]
    [System.String] $IPv4Address

    [DnsRecordA] Get()
    {
        return ([DnsRecordBase] $this).Get()
    }

    [void] Set()
    {
        ([DnsRecordBase] $this).Set()
    }

    [bool] Test()
    {
        return ([DnsRecordBase] $this).Test()
    }

    hidden [ciminstance] GetResourceRecord()
    {
        Write-Verbose -Message ($script:localizedDataDnsRecordA.GettingDnsRecordMessage -f 'A', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'A'
            # Add necessary Get-DnsServerResourceRecord parameters here and remove the throw below
        }
        throw "GetResourceRecord dnsParameters not implemented for $($this.GetType().Name)"

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object {
            <#
                Add any additional filtering criteria necessary here and remove the throw. Such as:
                $_.HostName -eq $recordHostName -and
                $_.RecordData.Port -eq $this.Port -and
                $_.RecordData.DomainName -eq "$($this.Target)."
            #>
            throw "GetResourceRecord Where-Object filter not implemented for $($this.GetType().Name)"
        }

        return $record
    }

    hidden [DnsRecordA] NewDscResourceObjectFromRecord([ciminstance] $record)
    {
        $dscResourceObject = [DnsRecordA] @{
            ZoneName     = $this.ZoneName
            # Apply values from $record as appropriate below
            Name        = throw 'NewDscResourceObjectFromRecord Name property not defined'
            IPv4Address = throw 'NewDscResourceObjectFromRecord IPv4Address property not defined'
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
            A          = $true
            # Add necessary Add-DnsServerResourceRecord parameters here and remove the throw below
        }
        throw "AddResourceRecord dnsParameters not implemented for $($this.GetType().Name)"

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($script:localizedDataDnsRecordA.CreatingDnsRecordMessage -f 'A', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        Add-DnsServerResourceRecord @dnsParameters
    }
}

