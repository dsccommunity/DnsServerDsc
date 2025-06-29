<#
    .SYNOPSIS
        The DnsRecordNsScoped DSC resource manages NS DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordNsScoped DSC resource manages NS DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
#>

using module DnsServerDsc

[DscResource()]
class DnsRecordNsScoped : DnsRecordNs
{
    [DscProperty(Key)]
    [System.String]
    $ZoneScope

    DnsRecordNsScoped()
    {
    }

    [DnsRecordNsScoped] Get()
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
        return ([DnsRecordNs] $this).GetResourceRecord()
    }

    hidden [DnsRecordNsScoped] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordNsScoped] @{
            ZoneName   = $this.ZoneName
            ZoneScope  = $this.ZoneScope
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
        ([DnsRecordNs] $this).AddResourceRecord()
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        ([DnsRecordNs] $this).ModifyResourceRecord($existingRecord, $propertiesNotInDesiredState)
    }
}
