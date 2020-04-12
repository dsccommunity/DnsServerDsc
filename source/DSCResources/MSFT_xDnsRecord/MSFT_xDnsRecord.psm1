$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        This will return the current state of the resource.

    .PARAMETER Name
        Specifies the name of the DNS server resource record object.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER Type
        Specifies the type of DNS record.

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.

    .PARAMETER TimeToLive
        Specifies the Time-To-Live for the record created.

    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Zone,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ARecord", "CName", "Ptr")]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.String]
        $DnsServer = "localhost",

        [Parameter()]
        [System.String]
        $TimeToLive,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ($script:localizedData.GettingDnsRecordMessage -f $Name, $Type, $Zone, $DnsServer)
    $record = Get-DnsServerResourceRecord -ZoneName $Zone -Name $Name -ComputerName $DnsServer -ErrorAction SilentlyContinue

    if ($null -eq $record)
    {
        return @{
            Name       = $Name.HostName
            Zone       = $Zone
            Target     = $Target
            DnsServer  = $DnsServer
            TimeToLive = $null
            Ensure     = 'Absent'
        }
    }
    if ($Type -eq "CName")
    {
        $recordData = ($record.RecordData.hostnamealias).TrimEnd('.')
    }
    if ($Type -eq "ARecord")
    {
        $recordData = $record.RecordData.IPv4address.IPAddressToString
    }
    if ($Type -eq "PTR")
    {
        $recordData = ($record.RecordData.PtrDomainName).TrimEnd('.')
    }

    return @{
        Name       = $record.HostName
        Zone       = $Zone
        Target     = $recordData
        DnsServer  = $DnsServer
        TimeToLive = $record.TimeToLive.ToString()
        Ensure     = 'Present'
    }
} #end function Get-TargetResource

<#
    .SYNOPSIS
        This will set the resource to the desired state.

    .PARAMETER Name
        Specifies the name of the DNS server resource record object.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER Type
        Specifies the type of DNS record.

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.

    .PARAMETER TimeToLive
        Specifies the Time-To-Live for the record created.

    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Zone,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ARecord", "CName", "Ptr")]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.String]
        $DnsServer = "localhost",

        [Parameter()]
        [System.String]
        $TimeToLive,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $DNSParameters = @{
        Name         = $Name
        ZoneName     = $Zone
        ComputerName = $DnsServer
    }

    if ($Ensure -eq 'Present')
    {
        if ($Type -eq "ARecord")
        {
            $record = Get-DnsServerResourceRecord @DNSParameters -RRType A -ErrorAction SilentlyContinue
            $DNSParameters.Add('A',$true)
            $DNSParameters.Add('IPv4Address',$target)
        }
        if ($Type -eq "CName")
        {
            $record = Get-DnsServerResourceRecord @DNSParameters -RRType CName -ErrorAction SilentlyContinue
            $DNSParameters.Add('CName',$true)
            $DNSParameters.Add('HostNameAlias',$Target)
        }
        if ($Type -eq "PTR")
        {
            $record = Get-DnsServerResourceRecord @DNSParameters -RRType Ptr -ErrorAction SilentlyContinue
            $DNSParameters.Add('Ptr',$true)
            $DNSParameters.Add('PtrDomainName',$Target)
        }
        if ($TimeToLive)
        {
            $DNSParameters.Add('TimeToLive',$TimeToLive)
        }

        if ($record -and $TimeToLive)
        {
            $timeSpanParams = @{}
            if ($TimeToLive -contains '.')
            {
                $days = $TimeToLive.Split('.')[0]
                $hours = $TimeToLive.Split(':')[0].Split('.')[1]

                $timeSpanParams.Add('Days',$days)
            }
            else
            {
                $hours = $TimeToLive.Split(':')[0]
            }

            $minutes = $TimeToLive.Split(':')[1]
            $seconds = $TimeToLive.Split(':')[2]

            $timeSpanParams.Add('Hours',$hours)
            $timeSpanParams.Add('Minutes',$minutes)
            $timeSpanParams.Add('Seconds',$seconds)

            Write-Verbose -Message ($script:localizedData.CreatingTimespan -f $days, $hours, $minutes, $seconds)
            $newTimeSpan = New-TimeSpan @timeSpanParams

            $newRecord = $record.Clone()
            $newRecord.TimeToLive = $newTimeSpan

            Write-Verbose -Message ($script:localizedData.UpdatingTtl -f $Type, $Target, $Zone, $DnsServer, $TimeToLive)
            Set-DnsServerResourceRecord -NewInputObject $newRecord -OldInputObject $record -ZoneName $Zone -ComputerName $DnsServer
        }
        else
        {
            Write-Verbose -Message ($script:localizedData.CreatingDnsRecordMessage -f $Type, $Target, $Zone, $DnsServer, $TimeToLive)
            Add-DnsServerResourceRecord @DNSParameters
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        $DNSParameters.Add('Force',$true)

        if ($Type -eq "ARecord")
        {
            $DNSParameters.Add('RRType','A')
        }
        if ($Type -eq "CName")
        {
            $DNSParameters.Add('RRType','CName')
        }
        if ($Type -eq "PTR")
        {
            $DNSParameters.Add('RRType','Ptr')
        }
        Write-Verbose -Message ($script:localizedData.RemovingDnsRecordMessage -f $Type, $Target, $Zone, $DnsServer)
        Remove-DnsServerResourceRecord @DNSParameters
    }
} #end function Set-TargetResource

<#
    .SYNOPSIS
        This will return whether the resource is in desired state.

    .PARAMETER Name
        Specifies the name of the DNS server resource record object.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER Type
        Specifies the type of DNS record.

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.

    .PARAMETER TimeToLive
        Specifies the Time-To-Live for the record created.

    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Zone,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ARecord", "CName", "Ptr")]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.String]
        $DnsServer = "localhost",

        [Parameter()]
        [System.String]
        $TimeToLive,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $result = @(Get-TargetResource @PSBoundParameters)
    if ($Ensure -ne $result.Ensure)
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', $Ensure, $result.Ensure)
        Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $Name)
        return $false
    }
    elseif ($Ensure -eq 'Present')
    {
        if ($result.Target -notcontains $Target)
        {
            $resultTargetString = $result.Target
            if ($resultTargetString -is [System.Array])
            {
                ## We have an array, create a single string for verbose output
                $resultTargetString = $result.Target -join ','
            }
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f `
                'Target', $Target, $resultTargetString)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $Name)
            return $false
        }

        if ( $TimeToLive -and $result.TimeToLive -ne $TimeToLive)
        {
            Write-Verbose -Message ($LocalizedData.NotDesiredPropertyMessage -f 'TTL',$TimeToLive, $result.TimeToLive)
            return $false
        }
    }
    Write-Verbose -Message ($script:localizedData.InDesiredStateMessage -f $Name)
    return $true
} #end function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
