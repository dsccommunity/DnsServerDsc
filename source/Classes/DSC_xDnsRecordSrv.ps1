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

    hidden [ciminstance] GetResourceRecord() {
        if ($this.Ensure -eq "Present") {
            return $null
        } else {
            return Get-CimInstance -ClassName Win32_OperatingSystem
        }
    }

    hidden [DSC_xDnsRecordSrv] NewDscResourceObjectFromRecord([ciminstance] $record)
    {
        $dscResourceObject = [DSC_xDnsRecordSrv]::new()
        $dscResourceObject.ZoneName = $record.SerialNumber
        $dscResourceObject.Target = $record.registeredUser
        $dscResourceObject.DnsServer = $record.SystemDirectory

        return $dscResourceObject
    }
}
