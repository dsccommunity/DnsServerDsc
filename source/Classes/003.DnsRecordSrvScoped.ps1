<#
    .SYNOPSIS
        A DSC Resource for MS DNS Server that represents an SRV resource record in a named scope in a split-brain configuration.

    .PARAMETER SymbolicName
        Service name for the SRV record. eg: xmpp, ldap, etc. (Key Parameter)

    .PARAMETER Protocol
        Service transmission protocol ('TCP' or 'UDP') (Key Parameter)

    .PARAMETER Port
        The TCP or UDP port on which the service is found (Key Parameter)

    .PARAMETER Target
        Specifies the Target Hostname or IP Address. (Key Parameter)

    .PARAMETER Priority
        Specifies the Priority value of the SRV record. (Mandatory Parameter)

    .PARAMETER Weight
        Specifies the weight of the SRV record. (Mandatory Parameter)

    .PARAMETER ZoneName
        Specifies the name of a DNS zone. (Key Parameter)

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)

    .PARAMETER TimeToLive
        Specifies the TimeToLive value of the SRV record. Value must be in valid TimeSpan string format (i.e.: Days.Hours:Minutes:Seconds.Miliseconds or 30.23:59:59.999).

    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.

    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>

$script:localizedDataDnsRecordSrvScoped = Get-LocalizedData -DefaultUICulture 'en-US' -FileName 'DnsRecordSrvScoped.strings.psd1'

[DscResource()]
class DnsRecordSrvScoped : DnsRecordSrv
{
    [DscProperty(Key)]
    [string] $ZoneScope

    [DnsRecordSrvScoped] Get()
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
        return ([DnsRecordSrv] $this).GetResourceRecord()
    }

    hidden [DnsRecordSrvScoped] NewDscResourceObjectFromRecord([ciminstance] $record)
    {
        $dscResourceObject = [DnsRecordSrvScoped] @{
            ZoneName     = $this.ZoneName
            ZoneScope    = $this.ZoneScope
            SymbolicName = $this.SymbolicName
            Protocol     = $this.Protocol.ToLower()
            Port         = $this.Port
            Target       = ($record.RecordData.DomainName).TrimEnd('.')
            Priority     = $record.RecordData.Priority
            Weight       = $record.RecordData.Weight
            TimeToLive   = $record.TimeToLive.ToString()
            DnsServer    = $this.DnsServer
            Ensure       = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        ([DnsRecordSrv] $this).AddResourceRecord()
    }
}
