<#
    .SYNOPSIS
        The DnsRecordTxtScoped DSC resource manages TXT DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordTxtScoped DSC resource manages TXT DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
#>

[DscResource()]
class DnsRecordTxtScoped : DnsRecordTxt
{
    [DscProperty(Key)]
    [System.String]
    $ZoneScope

    DnsRecordTxtScoped ()
    {
    }

    [DnsRecordTxtScoped] Get()
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
        return ([DnsRecordTxt] $this).GetResourceRecord()
    }

    hidden [DnsRecordTxtScoped] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordTxtScoped] @{
            ZoneName        = $this.ZoneName
            ZoneScope       = $this.ZoneScope
            Name            = $this.Name
            DescriptiveText = $this.DescriptiveText
            TimeToLive      = $record.TimeToLive.ToString()
            DnsServer       = $this.DnsServer
            Ensure          = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        ([DnsRecordTxt] $this).AddResourceRecord()
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        ([DnsRecordTxt] $this).ModifyResourceRecord($existingRecord, $propertiesNotInDesiredState)
    }
}
