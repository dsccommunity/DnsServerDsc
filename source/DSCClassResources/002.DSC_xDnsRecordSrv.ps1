
<#
    .SYNOPSIS
        A DSC Resource for MS DNS Server that represents an SRV resource record.
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
    .PARAMETER TimeToLive
        Specifies the TimeToLive value of the SRV record. Value must be in valid TimeSpan format.
    .PARAMETER AgeRecord
        Indicates that the DNS server uses a time stamp for the resource record that this cmdlet adds. A DNS server can scavenge resource records that have become stale based on a time stamp.
    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.
    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>

$script:localizedDataxDnsRecordSrv = Get-LocalizedData -DefaultUICulture en-US -FileName 'DSC_xDnsRecordSrv.strings.psd1'

[DscResource()]
class DSC_xDnsRecordSrv : DSC_xDnsRecordBase
{
    [DscProperty(Key)]
    [System.String] $SymbolicName

    [DscProperty(Key)]
    [ValidateSet('TCP', 'UDP')]
    [System.String] $Protocol

    [DscProperty(Key)]
    [ValidateRange(1, 65535)]
    [System.UInt16] $Port

    [DscProperty(Key)]
    [System.String] $Target

    [DscProperty(Mandatory)]
    [System.UInt16] $Priority

    [DscProperty(Mandatory)]
    [System.UInt16] $Weight

    hidden [ciminstance] GetResourceRecord()
    {
        $recordHostName = "_$($this.SymbolicName)._$($this.Protocol)".ToLower()

        # Write-Verbose -Message ($script:localizedData.GettingDnsRecordMessage -f $recordHostName, $this.target, 'SRV', $this.Zone, $this.DnsServer)

        $dnsParameters = @{
            Name         = $recordHostName
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'SRV'
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object {
            $_.HostName -eq $recordHostName -and
            $_.RecordData.Port -eq $this.Port -and
            $_.RecordData.DomainName -eq "$($this.Target)."
        }

        return $record
    }

    hidden [DSC_xDnsRecordSrv] NewDscResourceObjectFromRecord([ciminstance] $record)
    {
        $dscResourceObject = [DSC_xDnsRecordSrv]::new()

        $dscResourceObject.ZoneName     = $this.ZoneName
        $dscResourceObject.SymbolicName = $this.SymbolicName
        $dscResourceObject.Protocol     = $this.Protocol.ToLower()
        $dscResourceObject.Port         = $this.Port
        $dscResourceObject.Target       = ($record.RecordData.DomainName).TrimEnd('.')
        $dscResourceObject.Priority     = $record.RecordData.Priority
        $dscResourceObject.Weight       = $record.RecordData.Weight
        $dscResourceObject.TimeToLive   = $record.TimeToLive.ToString()
        $dscResourceObject.DnsServer    = $this.DnsServer
        $dscResourceObject.Ensure       = 'Present'

        return $dscResourceObject
    }
}
