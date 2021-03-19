<#
    .SYNOPSIS
        The DnsRecordCnameScoped DSC resource manages CNAME DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordCnameScoped DSC resource manages CNAME DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
#>

[DscResource()]
class DnsRecordCnameScoped : DnsRecordCname
{
    [DscProperty(Key)]
    [System.String]
    $ZoneScope

    [DnsRecordCnameScoped] Get()
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
        return ([DnsRecordCname] $this).GetResourceRecord()
    }

    hidden [DnsRecordCnameScoped] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordCnameScoped] @{
            ZoneName      = $this.ZoneName
            ZoneScope     = $this.ZoneScope
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
        ([DnsRecordCname] $this).AddResourceRecord()
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        ([DnsRecordCname] $this).ModifyResourceRecord($existingRecord, $propertiesNotInDesiredState)
    }
}
