# Import the Helper module
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'
Import-Module -Name (Join-Path -Path $modulePath -ChildPath (Join-Path -Path Helper -ChildPath Helper.psm1))

# Import Localization Strings
$localizedData = Get-LocalizedData `
    -ResourceName 'MSFT_xDnsRecord' `
    -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)


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

    .PARAMETER Ensure
        Whether the host record should be present or removed.

    .PARAMETER TimeToLive
        Specifies the Time-To-Live for the record created.
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
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.TimeSpan]
        $TimeToLive
    )

    Write-Verbose -Message ($LocalizedData.GettingDnsRecordMessage -f $Name, $Type, $Zone, $DnsServer)
    $record = Get-DnsServerResourceRecord -ZoneName $Zone -Name $Name -ComputerName $DnsServer -ErrorAction SilentlyContinue

    if ($null -eq $record)
    {
        return @{
            Name       = $Name.HostName
            Zone       = $Zone
            Target     = $Target
            DnsServer  = $DnsServer
            TimetoLive = $null
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

    .PARAMETER Ensure
        Whether the host record should be present or removed.

    .PARAMETER TimeToLive
        Specifies the Time-To-Live for the record created.
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
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.TimeSpan]
        $TimeToLive
    )

    $DNSParameters = @{ Name = $Name; ZoneName = $Zone; ComputerName = $DnsServer; }

    if ($Ensure -eq 'Present')
    {
        if ($Type -eq "ARecord")
        {
            $DNSParameters.Add('A',$true)
            $DNSParameters.Add('IPv4Address',$target)
        }
        if ($Type -eq "CName")
        {
            $DNSParameters.Add('CName',$true)
            $DNSParameters.Add('HostNameAlias',$Target)
        }
        if ($Type -eq "PTR")
        {
            $DNSParameters.Add('Ptr',$true)
            $DNSParameters.Add('PtrDomainName',$Target)
        }
        if ($TimeToLive)
        {
            $DNSParameters.Add('TimeToLive',$TimeToLive)
        }

        $record = Get-DnsServerResourceRecord -ZoneName $Zone -Name $Name -ComputerName $DnsServer -ErrorAction SilentlyContinue

        #Should only hit set when the Resource Record exists and the TTL times do not match
        if ($record)
        {
            $newRecord = $record.Clone()
            $newRecord.TimeToLive = $TimeToLive

            Set-DnsServerResourceRecord -NewInputObject $newRecord -OldInputObject $record -ZoneName $Zone -ComputerName $DnsServer
        }
        else {

            Write-Verbose -Message ($LocalizedData.CreatingDnsRecordMessage -f $Type, $Target, $Zone, $DnsServer)
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
        Write-Verbose -Message ($LocalizedData.RemovingDnsRecordMessage -f $Type, $Target, $Zone, $DnsServer)
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

    .PARAMETER Ensure
        Whether the host record should be present or removed.

    .PARAMETER TimeToLive
        Specifies the Time-To-Live for the record created.
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
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.TimeSpan]
        $TimeToLive
    )

    $result = @(Get-TargetResource @PSBoundParameters)
    if ($Ensure -ne $result.Ensure)
    {
        Write-Verbose -Message ($LocalizedData.NotDesiredPropertyMessage -f 'Ensure', $Ensure, $result.Ensure)
        Write-Verbose -Message ($LocalizedData.NotInDesiredStateMessage -f $Name)
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
            Write-Verbose -Message ($LocalizedData.NotDesiredPropertyMessage -f 'Target', $Target, $resultTargetString)
            Write-Verbose -Message ($LocalizedData.NotInDesiredStateMessage -f $Name)
            return $false
        }

        if (($null -ne $TimeToLive) -and ($result.TimeToLive -ne $TimeToLive))
        {
            $stringActualTimeToLive = $result.TimeToLive.ToString()
            $stringExpectedTimeToLive = $TimeToLive.ToString()
            Write-Verbose -Message ($LocalizedData.IncorrectTtlMessage -f $stringExpectedTimeToLive, $stringActualTimeToLive)
            return $false
        }
    }
    Write-Verbose -Message ($LocalizedData.InDesiredStateMessage -f $Name)
    return $true
} #end function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
