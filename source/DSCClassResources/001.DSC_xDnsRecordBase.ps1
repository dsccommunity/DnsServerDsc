<#
    .SYNOPSIS
        A DSC Resource for MS DNS Server that is not exposed to end users representing the common fields available to all resource records.
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

$script:localizedDataxDnsRecordBase = Get-LocalizedData -DefaultUICulture en-US -FileName 'DSC_xDnsRecordBase.strings.psd1'

[DscResource()]
class DSC_xDnsRecordBase
{
    # Specifies the name of a DNS zone.
    [DscProperty(Key)]
    [string] $ZoneName

    [DscProperty()]
    [TimeSpan] $TimeToLive

    [DscProperty()]
    [string] $DnsServer = 'localhost'

    [DscProperty()]
    [bool] $AgeRecord = $false

    [DscProperty()]
    [Ensure] $Ensure

    #region Generic DSC methods -- DO NOT OVERRIDE

    [DSC_xDnsRecordBase] Get()
    {
        $record = $this.GetResourceRecord()
        $dscResourceObject = $null
        if ($null -eq $record)
        {
            <#
                Create an object of the correct type (i.e.: the subclassed resource type)
                and set its values to those specified in the object, but set Ensure to Absent
            #>
            $dscResourceObject = [activator]::CreateInstance($this.GetType())
            foreach ($propertyName in $this.GetType().GetProperties().Name)
            {
                $dscResourceObject.$propertyName = $this.$propertyName
            }
            $dscResourceObject.Ensure = "Absent"
        } else {
            # Build an object reflecting the current state based on the record found
            $dscResourceObject = $this.NewDscResourceObjectFromRecord($record)
        }
        return $dscResourceObject
    }

    [void] Set()
    {
        throw "Set() not implemented"
    }

    [bool] Test()
    {
        throw "Test() not implemented"
    }

    #endregion

    #region Methods to override

    # Using the values supplied to $this, query the DNS server for a resource record and return it
    hidden [ciminstance] GetResourceRecord()
    {
        throw "GetResourceRecord() not implemented"
    }

    # Given a resource record object, create an instance of this class with the appropriate data
    hidden [DSC_xDnsRecordBase] NewDscResourceObjectFromRecord([ciminstance] $record)
    {
        throw "NewResourceObjectFromRecord() not implemented"
    }

    #endregion
}
