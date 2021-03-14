<#
    .SYNOPSIS
        A DSC Resource for MS DNS Server that is not exposed to end users representing the common fields available to all resource records.

    .PARAMETER ZoneName
        Specifies the name of a DNS zone. (Key Parameter)

    .PARAMETER TimeToLive
        Specifies the TimeToLive value of the SRV record. Value must be in valid TimeSpan string format (i.e.: Days.Hours:Minutes:Seconds.Miliseconds or 30.23:59:59.999).

    .PARAMETER DnsServer
        Name of the DnsServer on which to create the record.

    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>

$script:localizedDataDnsRecordBase = Get-LocalizedData -DefaultUICulture 'en-US' -FileName 'DnsRecordBase.strings.psd1'

class DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $ZoneName

    [DscProperty()]
    [System.String]
    $TimeToLive

    [DscProperty()]
    [System.String]
    $DnsServer = 'localhost'

    [DscProperty()]
    [Ensure]
    $Ensure = [Ensure]::Present

    # Hidden property to determine whether the class is a scoped version
    hidden [bool] $isScoped

    # Default constructor sets the $isScoped variable
    DnsRecordBase()
    {
        $this.isScoped = $this.PSObject.Properties.Name -contains 'ZoneScope'
    }

    #region Generic DSC methods -- DO NOT OVERRIDE

    [DnsRecordBase] Get()
    {
        Write-Verbose -Message ($script:localizedDataDnsRecordBase.GettingDscResourceObject -f $this.GetType().Name)

        $dscResourceObject = $null

        $record = $this.GetResourceRecord()

        if ($null -eq $record)
        {
            Write-Verbose -Message $script:localizedDataDnsRecordBase.RecordNotFound

            <#
                Create an object of the correct type (i.e.: the subclassed resource type)
                and set its values to those specified in the object, but set Ensure to Absent
            #>
            $dscResourceObject = [System.Activator]::CreateInstance($this.GetType())

            foreach ($propertyName in $this.PSObject.Properties.Name)
            {
                $dscResourceObject.$propertyName = $this.$propertyName
            }

            $dscResourceObject.Ensure = 'Absent'
        }
        else
        {
            Write-Verbose -Message $script:localizedDataDnsRecordBase.RecordFound

            # Build an object reflecting the current state based on the record found
            $dscResourceObject = $this.NewDscResourceObjectFromRecord($record)
        }

        return $dscResourceObject
    }

    [void] Set()
    {
        # Initialize dns cmdlet Parameters for removing a record
        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
        }

        # Accomodate for scoped records as well
        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = ($this.PSObject.Properties | Where-Object -FilterScript { $_.Name -eq 'ZoneScope' }).Value
        }

        $existingRecord = $this.GetResourceRecord()

        if ($this.Ensure -eq 'Present')
        {
            if ($null -ne $existingRecord)
            {
                Write-Verbose -Message $script:localizedDataDnsRecordBase.RemovingExistingRecord

                # Removing existing record (required for compatibility with AgeRecord if implemented in the future)
                $existingRecord | Remove-DnsServerResourceRecord @dnsParameters -Force
            }

            Write-Verbose -Message ($script:localizedDataDnsRecordBase.AddingNewRecord -f $this.GetType().Name)

            # Adding record
            $this.AddResourceRecord()
        }
        elseif ($this.Ensure -eq 'Absent')
        {
            if ($null -ne $existingRecord)
            {
                Write-Verbose -Message $script:localizedDataDnsRecordBase.RemovingExistingRecord

                # Removing existing record
                $existingRecord | Remove-DnsServerResourceRecord @dnsParameters -Force
            }
        }
    }

    [bool] Test()
    {
        $isInDesiredState = $true

        $currentState = $this.Get() | ConvertTo-HashTableFromObject
        $desiredState = $this | ConvertTo-HashTableFromObject

        if ($this.Ensure -eq 'Present')
        {
            foreach ($property in $desiredState.Keys)
            {
                # Don't compare properties unless they have been specified in this object
                if ($null -ne $desiredState[$property] -and $currentState[$property] -ne $desiredState[$property])
                {
                    Write-Verbose -Message ($script:localizedDataDnsRecordBase.PropertyIsNotInDesiredState -f $property, $desiredState[$property], $currentState[$property])

                    $isInDesiredState = $false
                }
            }
        }

        if ($this.Ensure -eq 'Absent')
        {
            if ($currentState['Ensure'] -eq 'Present')
            {
                Write-Verbose -Message ($script:localizedDataDnsRecordBase.PropertyIsNotInDesiredState -f 'Ensure', $desiredState['Ensure'], $currentState['Ensure'])

                $isInDesiredState = $false
            }
        }

        if ($isInDesiredState)
        {
            Write-Verbose -Message $script:localizedDataDnsRecordBase.ObjectInDesiredState
        }
        else
        {
            Write-Verbose -Message $script:localizedDataDnsRecordBase.ObjectNotInDesiredState
        }

        return $isInDesiredState
    }

    #endregion

    #region Methods to override

    # Using the values supplied to $this, query the DNS server for a resource record and return it
    hidden [ciminstance] GetResourceRecord()
    {
        throw 'GetResourceRecord() not implemented'
    }

    # Add a resource record using the properties of this object.
    hidden [void] AddResourceRecord()
    {
        throw 'AddResourceRecord() not implemented'
    }

    # Given a resource record object, create an instance of this class with the appropriate data
    hidden [DnsRecordBase] NewDscResourceObjectFromRecord($record)
    {
        throw 'NewResourceObjectFromRecord() not implemented'
    }

    #endregion
}
