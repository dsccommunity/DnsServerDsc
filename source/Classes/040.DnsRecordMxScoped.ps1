<#
    .SYNOPSIS
        The DnsRecordMxScoped DSC resource manages MX DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordMxScoped DSC resource manages MX DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
#>

[DscResource()]
class DnsRecordMxScoped : DnsRecordMx
{
    [DscProperty(Key)]
    [System.String]
    $ZoneScope

    [DnsRecordMxScoped] Get()
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
        return ([DnsRecordMx] $this).GetResourceRecord()
    }

    hidden [DnsRecordMxScoped] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordMxScoped] @{
            ZoneName     = $this.ZoneName
            ZoneScope    = $this.ZoneScope
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
        ([DnsRecordMx] $this).AddResourceRecord()
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        ([DnsRecordMx] $this).ModifyResourceRecord($existingRecord, $propertiesNotInDesiredState)
    }
}
