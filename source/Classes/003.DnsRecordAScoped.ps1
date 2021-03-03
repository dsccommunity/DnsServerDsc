<#
    .SYNOPSIS
        A DSC Resource for MS DNS Server that represents an SRV resource record.
    .PARAMETER ZoneName
        Specifies the name of a DNS zone. (Key Parameter)
    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
    .PARAMETER Name
        Specifies the name of a DNS server resource record object. (Key Parameter)
    .PARAMETER IPv4Address
       Specifies the IPv4 address of a host. (Key Parameter)
    .PARAMETER TimeToLive
        Specifies the TimeToLive value of the SRV record. Value must be in valid TimeSpan string format (i.e.: Days.Hours:Minutes:Seconds.Miliseconds or 30.23:59:59.999).
    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.
    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>

$script:localizedDataDnsRecordAScoped = Get-LocalizedData -DefaultUICulture en-US -FileName 'DnsRecordAScoped.strings.psd1'

[DscResource()]
class DnsRecordAScoped : DnsRecordA
{
    [DscProperty(Key)]
    [string] $ZoneScope

    [DnsRecordAScoped] Get()
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
        return ([DnsRecordA] $this).GetResourceRecord()
    }

    hidden [DnsRecordAScoped] NewDscResourceObjectFromRecord([ciminstance] $record)
    {
        $dscResourceObject = [DnsRecordAScoped] @{
            ZoneName    = $this.ZoneName
            ZoneScope   = $this.ZoneScope
            Name        = $this.Name
            IPv4Address = $this.IPv4Address
            TimeToLive  = $record.TimeToLive.ToString()
            DnsServer   = $this.DnsServer
            Ensure      = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        ([DnsRecordA] $this).AddResourceRecord()
    }
}
