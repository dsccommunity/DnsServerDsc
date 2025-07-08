<#
    .SYNOPSIS
        The DnsRecordPtr DSC resource manages PTR DNS records against a specific zone on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordPtr DSC resource manages PTR DNS records against a specific zone on a Domain Name System (DNS) server.

    .PARAMETER IpAddress
        Specifies the IP address to which the record is associated (Can be either IPv4 or IPv6. (Key Parameter)

    .PARAMETER Name
        Specifies the FQDN of the host when you add a PTR resource record. (Key Parameter)

    .NOTES
        Reverse lookup zones do not support scopes, so there should be no DnsRecordPtrScoped subclass created.
#>

[DscResource()]
class DnsRecordPtr : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $IpAddress

    [DscProperty(Key)]
    [System.String]
    $Name

    hidden [System.String] $recordHostName

    DnsRecordPtr()
    {
    }

    [DnsRecordPtr] Get()
    {
        # Ensure $recordHostName is set
        $this.recordHostName = $this.getRecordHostName($this.IpAddress)

        return ([DnsRecordBase] $this).Get()
    }

    [void] Set()
    {
        # Ensure $recordHostName is set
        $this.recordHostName = $this.getRecordHostName($this.IpAddress)

        ([DnsRecordBase] $this).Set()
    }

    [System.Boolean] Test()
    {
        # Ensure $recordHostName is set
        $this.recordHostName = $this.getRecordHostName($this.IpAddress)

        return ([DnsRecordBase] $this).Test()
    }

    hidden [Microsoft.Management.Infrastructure.CimInstance] GetResourceRecord()
    {
        Write-Verbose -Message ($this.localizedData.GettingDnsRecordMessage -f 'Ptr', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'PTR'
            Name         = $this.recordHostName
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_.RecordData.PtrDomainName -eq "$($this.Name)."
        }

        return $record
    }

    hidden [DnsRecordPtr] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordPtr] @{
            ZoneName   = $this.ZoneName
            IpAddress  = $this.IpAddress
            Name       = $this.Name
            TimeToLive = $record.TimeToLive.ToString()
            DnsServer  = $this.DnsServer
            Ensure     = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        $dnsParameters = @{
            ZoneName      = $this.ZoneName
            ComputerName  = $this.DnsServer
            PTR           = $true
            Name          = $this.recordHostName
            PtrDomainName = $this.Name
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($this.localizedData.CreatingDnsRecordMessage -f 'PTR', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        Add-DnsServerResourceRecord @dnsParameters
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
        }

        # Copy the existing record and modify values as appropriate
        $newRecord = [Microsoft.Management.Infrastructure.CimInstance]::new($existingRecord)

        foreach ($propertyToChange in $propertiesNotInDesiredState)
        {
            switch ($propertyToChange.Property)
            {
                # Key parameters will never be affected, so only include Mandatory and Optional values in the switch statement
                'TimeToLive'
                {
                    $newRecord.TimeToLive = [System.TimeSpan] $propertyToChange.ExpectedValue
                }

            }
        }

        Set-DnsServerResourceRecord @dnsParameters -OldInputObject $existingRecord -NewInputObject $newRecord -Verbose
    }

    # Take a compressed IPv6 string (i.e.: fd00::1) and expand it out to the full notation (i.e.: fd00:0000:0000:0000:0000:0000:0000:0001)
    hidden [System.String] expandIPv6String($string)
    {
        # Split the string on the colons
        $segments = [System.Collections.ArrayList]::new(($string -split ':'))

        # Determine how many segments need to be added to reach the 8 required
        $blankSegmentCount = 8 - $segments.count

        # Hold the expanded segments
        $newSegments = [System.Collections.ArrayList]::new()

        # Insert missing segments
        foreach ($segment in $segments)
        {
            if ([System.String]::IsNullOrEmpty($segment))
            {
                for ($i = 0; $i -le $blankSegmentCount; $i++)
                {
                    $newSegments.Add('0000')
                }
            }
            else
            {
                $newSegments.Add($segment)
            }
        }

        # Pad out all segments with leading zeros
        $paddedSegments = $newSegments | ForEach-Object {
            $_.PadLeft(4, '0')
        }
        return ($paddedSegments -join ':')
    }

    # Translate the IP address to the reverse notation used by the DNS server
    hidden [System.String] getReverseNotation([System.Net.IpAddress] $IPAddressObj)
    {
        $significantData = [System.Collections.ArrayList]::New()

        switch ($ipAddressObj.AddressFamily)
        {
            'InterNetwork'
            {
                $significantData.AddRange(($ipAddressObj.IPAddressToString -split '\.'))
                break
            }

            'InterNetworkV6'
            {
                # Get the hex values into an ArrayList
                $significantData.AddRange(($this.expandIPv6String($ipAddressObj.IPAddressToString) -replace ':', '' -split ''))
                break
            }
        }

        $significantData.Reverse()

        # The reverse lookup notation puts a '.' between each hex value
        return ($significantData -join '.').Trim('.')
    }

    # Determine the record host name
    hidden [System.String] getRecordHostName([System.String] $IPAddress)
    {
        Assert-IPAddress -Address $IPAddress
        $ipAddressObj = [System.Net.IpAddress] $IPAddress

        $reverseLookupAddressComponent = ''

        switch ($ipAddressObj.AddressFamily)
        {
            'InterNetwork'
            {
                if (-not $this.ZoneName.ToLower().EndsWith('.in-addr.arpa'))
                {
                    throw ($this.localizedData.NotAnIPv4Zone -f $this.ZoneName)
                }
                $reverseLookupAddressComponent = $this.ZoneName.Replace('.in-addr.arpa', '')
                break
            }

            'InterNetworkV6'
            {
                if (-not $this.ZoneName.ToLower().EndsWith('.ip6.arpa'))
                {
                    throw ($this.localizedData.NotAnIPv6Zone -f $this.ZoneName)
                }
                $reverseLookupAddressComponent = $this.ZoneName.Replace('.ip6.arpa', '')
                break
            }
        }

        $reverseNotation = $this.getReverseNotation($ipAddressObj)

        # Check to make sure that the ip address actually belongs in this zone
        if ($reverseNotation -notmatch "$($reverseLookupAddressComponent)`$")
        {
            throw $this.localizedData.WrongZone -f $ipAddressObj.IPAddressToString, $this.ZoneName
        }

        # Strip the zone name from the reversed IP using a regular expression
        $ptrRecordHostName = $reverseNotation -replace "\.$([System.Text.RegularExpressions.Regex]::Escape($reverseLookupAddressComponent))`$", ''

        return $ptrRecordHostName
    }
}
