<#
    .SYNOPSIS
        The DnsRecordTxt DSC resource manages TXT DNS records against a specific zone on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordTxt DSC resource manages TXT DNS records against a specific zone on a Domain Name System (DNS) server.

    .PARAMETER Name
        Specifies the name of a DNS server resource record object.

    .PARAMETER DescriptiveText
        Specifies additional text to describe a resource record on a DNS server. It is limited to 254 characters per line.

    .NOTES
        About long and muli-lined DNS TXT records.

        Microsoft DNS Server generally supports creating long multi-line TXT DNS records.
        For example, using the DNS MMC snap-in (which directly utilizes the DNS API), you can create a record containing multiple lines.
        However, when saving such a record, all lines will be truncated to 140 characters.

        Using the Add-DnsServerResourceRecord cmdlet (PowerShell/WMI), you can create a single-line record up to 254 characters long.
        However, it is not possible to create a multi-line DNS TXT record, thereby increasing the maximum possible record length beyond 254 characters.

        There is also a method to create records using DNSCMD.EXE, but this approach does not support Scoped DNS TXT records.

        For more details, refer to:
        https://learn.microsoft.com/en-us/answers/questions/1189058/how-to-set-multiline-txt-fields-with-add-dnsserver

        Another Important Consideration:
        When attempting to retrieve the value of a multi-line TXT record using:
        ```Powershell
        (Get-DnsServerResourceRecord -ZoneName $ZoneName -RRType TXT -Name $Name).RecordData.DescriptiveText
        ```
        only the first line is returned.
        To obtain the full multi-line record, you would need to use:
        ```Powershell
        Resolve-DnsName -Name $Name -Type TXT -Server $DnsServer
        ```
        then you would parse Strings[] parameter of returned object like `Strings[0], Strings[1]... etc`.

        Conclusion:
        Based on the above, this DSC resource only works with single-line DNS TXT records, limited to 254 characters maximum.

#>

[DscResource()]
class DnsRecordTxt : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $Name

    [DscProperty(Key)]
    [System.String]
    $DescriptiveText

    DnsRecordTxt ()
    {
    }

    [DnsRecordTxt] Get()
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
        Write-Verbose -Message ($this.localizedData.GettingDnsRecordMessage -f 'TXT', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'TXT'
            Name         = $this.Name
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_.RecordData.DescriptiveText -eq $this.DescriptiveText
        }

        return $record
    }

    hidden [DnsRecordTxt] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordTxt] @{
            ZoneName        = $this.ZoneName
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
        $dnsParameters = @{
            ZoneName        = $this.ZoneName
            ComputerName    = $this.DnsServer
            TXT             = $true
            Name            = $this.Name
            DescriptiveText = $this.DescriptiveText
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($this.localizedData.CreatingDnsRecordMessage -f 'TXT', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        Add-DnsServerResourceRecord @dnsParameters
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
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

    # Called by ResourceBase class in Get() Set() and Test() methods to assert that all properties are valid.
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        switch ($properties.keys)
        {
            'DescriptiveText'
            {
                if ($properties.DescriptiveText.Length -lt 1 -or $properties.DescriptiveText.Length -gt 254)
                {
                    $errorMessage = $this.localizedData.PropertyIsNotInValidRange -f 'DescriptiveText'
                    New-InvalidOperationException -Message $errorMessage
                }
            }
        }

    }
}
