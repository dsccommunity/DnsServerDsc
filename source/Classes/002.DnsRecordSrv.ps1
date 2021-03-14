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
        Specifies the TimeToLive value of the SRV record. Value must be in valid TimeSpan string format (i.e.: Days.Hours:Minutes:Seconds.Miliseconds or 30.23:59:59.999).

    .PARAMETER DnsServer
        Name of the DnsServer on which to create.

    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>

$script:localizedDataDnsRecordSrv = Get-LocalizedData -DefaultUICulture 'en-US' -FileName 'DnsRecordSrv.strings.psd1'

[DscResource()]
class DnsRecordSrv : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $SymbolicName

    [DscProperty(Key)]
    [ValidateSet('TCP', 'UDP')]
    [System.String]
    $Protocol

    [DscProperty(Key)]
    [ValidateRange(1, 65535)]
    [System.UInt16]
    $Port

    [DscProperty(Key)]
    [System.String]
    $Target

    [DscProperty(Mandatory)]
    [System.UInt16]
    $Priority

    [DscProperty(Mandatory)]
    [System.UInt16]
    $Weight

    hidden [System.String] getRecordHostName()
    {
        return "_$($this.SymbolicName)._$($this.Protocol)".ToLower()
    }

    [DnsRecordSrv] Get()
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
        $recordHostName = $this.getRecordHostName()

        Write-Verbose -Message ($script:localizedDataDnsRecordSrv.GettingDnsRecordMessage -f $recordHostName, $this.target, 'SRV', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            Name         = $recordHostName
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'SRV'
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object {
            $_.HostName -eq $recordHostName -and
            $_.RecordData.Port -eq $this.Port -and
            $_.RecordData.DomainName -eq "$($this.Target)."
        }

        return $record
    }

    hidden [DnsRecordSrv] NewDscResourceObjectFromRecord([ciminstance] $record)
    {
        $dscResourceObject = [DnsRecordSrv] @{
            ZoneName     = $this.ZoneName
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
        $recordHostName = $this.getRecordHostName()

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            Name         = $recordHostName
            Srv          = $true
            DomainName   = $this.Target
            Port         = $this.Port
            Priority     = $this.Priority
            Weight       = $this.Weight
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($script:localizedDataDnsRecordSrv.CreatingDnsRecordMessage -f 'SRV', $recordHostName, $this.Target, $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        Add-DnsServerResourceRecord @dnsParameters
    }
}
