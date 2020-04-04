$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        This will return the current state of the resource.

    .PARAMETER Name
        Specifies the name of the DNS server resource record object. For records in the apex of the domain, use a period.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER Priority
        Specifies the Priority value of the MX record.

    .PARAMETER TTL
        Specifies the TTL value of the MX record. Value must be in valid TimeSpan format.

    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.

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
        [System.String]
        $Target,

        [Parameter()]
        [System.UInt16]
        $Priority,

        [Parameter()]
        [ValidateScript({$ts = New-TimeSpan; [system.timespan]::TryParse($_, [ref]$ts)})]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = "localhost",

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ($script:localizedData.GettingDnsRecordMessage -f $Name, 'MX', $Zone, $DnsServer)

    $DNSParameters = @{
        Name         = $Name
        ZoneName     = $Zone
        ComputerName = $DnsServer
        RRType       = 'Mx'
    }

    $record = Get-DnsServerResourceRecord @DNSParameters -ErrorAction SilentlyContinue

    if ($null -eq $record)
    {
        return @{
            Name      = $Name.HostName
            Zone      = $Zone
            Target    = $Target
            Priority  = $Priority
            TTL       = $TTL
            DnsServer = $DnsServer
            Ensure    = 'Absent'
        }
    }

    return @{
        Name      = $record.HostName
        Zone      = $Zone
        Target    = ($record.RecordData.MailExchange).TrimEnd('.')
        Priority  = $record.RecordData.Preference
        TTL       = $record.TimeToLive.ToString()
        DnsServer = $DnsServer
        Ensure    = 'Present'
    }
} #end function Get-TargetResource

<#
    .SYNOPSIS
        This will set the resource to the desired state.

    .PARAMETER Name
        Specifies the name of the DNS server resource record object. For records in the apex of the domain, use a period.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER Priority
        Specifies the Priority value of the MX record.

    .PARAMETER TTL
        Specifies the TTL value of the MX record. Value must be in valid TimeSpan format.

    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.

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
        [System.String]
        $Target,

        [Parameter()]
        [System.UInt16]
        $Priority,

        [Parameter()]
        [ValidateScript({$ts = New-TimeSpan; [system.timespan]::TryParse($_, [ref]$ts)})]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = "localhost",

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $DNSParameters = @{
        ZoneName     = $Zone
        ComputerName = $DnsServer
    }

    if ($Ensure -eq 'Present')
    {
        $DNSParameters = @{
            ZoneName     = $Zone
            ComputerName = $DnsServer
        }

        $OldObj = Get-DnsServerResourceRecord @DNSParameters -RRType 'Mx' -ErrorAction SilentlyContinue

        # If the entry exists, update it instead of adding a new one
        if ($null -ne $OldObj)
        {
            $NewObj = $OldObj.Clone()

            if (0 -ne $Priority)
            {
                $NewObj.RecordData.Preference = $Priority
            }
            if (-not [string]::IsNullOrEmpty($TTL))
            {
                $NewObj.TimeToLive = $TTL
            }

            $DNSParameters.Add('OldInputObject', $OldObj)
            $DNSParameters.Add('NewInputObject', $NewObj)

            Write-Verbose -Message ($script:localizedData.UpdatingDnsRecordMessage -f 'MX', $Target, $Zone, $DnsServer)
            Set-DnsServerResourceRecord @DNSParameters
        }
        else
        {
            $DNSParameters.Add('Name',$Name)
            $DNSParameters.Add('Mx',$true)
            $DNSParameters.Add('MailExchange', $Target)
            $DNSParameters.Add('Preference', $Priority)

            if ($null -ne $TTL)
            {
                $DNSParameters.Add('TimeToLive', $TTL)
            }

            Write-Verbose -Message ($script:localizedData.CreatingDnsRecordMessage -f 'MX', $Target, $Zone, $DnsServer)
            Add-DnsServerResourceRecord @DNSParameters
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        $DNSParameters.Add('Name',$Name)
        $DNSParameters.Add('Force',$true)
        $DNSParameters.Add('RRType','Mx')

        Write-Verbose -Message ($script:localizedData.RemovingDnsRecordMessage -f 'MX', $Target, $Zone, $DnsServer)
        Remove-DnsServerResourceRecord @DNSParameters
    }
} #end function Set-TargetResource

<#
    .SYNOPSIS
        This will return whether the resource is in desired state.

    .PARAMETER Name
        Specifies the name of the DNS server resource record object. For records in the apex of the domain, use a period.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER Priority
        Specifies the Priority value of the MX record.

    .PARAMETER TTL
        Specifies the TTL value of the MX record. Value must be in valid TimeSpan format.

    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.

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
        [System.String]
        $Target,

        [Parameter()]
        [System.UInt16]
        $Priority,

        [Parameter()]
        [ValidateScript({$ts = New-TimeSpan; [system.timespan]::TryParse($_, [ref]$ts)})]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = "localhost",

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
        elseif (0 -ne $Priority -and $result.Priority -ne $Priority)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f `
            'Priority', $Priority, $result.Priority)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $Name)
            return $false
        }
        elseif (-not [string]::IsNullOrEmpty($TTL) -and $result.TTL -ne $TTL)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f `
            'TTL', $TTL, $result.TTL)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $Name)
            return $false
        }
    }
    Write-Verbose -Message ($script:localizedData.InDesiredStateMessage -f $Name)
    return $true
} #end function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
