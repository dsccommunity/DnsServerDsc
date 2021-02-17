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
