<#
    .SYNOPSIS
        The DnsRecordAaaaScoped DSC resource manages AAAA DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordAaaaScoped DSC resource manages AAAA DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
#>

[DscResource()]
class DnsRecordAaaaScoped : DnsRecordAaaa
{
    [DscProperty(Key)]
    [System.String]
    $ZoneScope

    DnsRecordAaaaScoped() {}

    [DnsRecordAaaaScoped] Get()
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
        return ([DnsRecordAaaa] $this).GetResourceRecord()
    }

    hidden [DnsRecordAaaaScoped] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordAaaaScoped] @{
            ZoneName    = $this.ZoneName
            ZoneScope   = $this.ZoneScope
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
        ([DnsRecordAaaa] $this).AddResourceRecord()
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        ([DnsRecordAaaa] $this).ModifyResourceRecord($existingRecord, $propertiesNotInDesiredState)
    }
}
