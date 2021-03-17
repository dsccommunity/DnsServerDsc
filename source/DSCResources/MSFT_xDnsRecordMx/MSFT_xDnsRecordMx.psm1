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

    .PARAMETER DnsServer
        Name of the DnsServer to create the record on.
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

        [Parameter(Mandatory = $true)]
        [System.UInt16]
        $Priority,

        [Parameter()]
        [System.String]
        $DnsServer = 'localhost'
    )

    $Target = $Target | ConvertTo-FollowRfc1034

    Write-Verbose -Message ($script:localizedData.GettingDnsRecordMessage -f $Target, 'MX', $Zone, $DnsServer)

    $dnsParameters = @{
        Name         = $Name
        ZoneName     = $Zone
        ComputerName = $DnsServer
        RRType       = 'Mx'
    }

    $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
        $_.RecordData.MailExchange -eq $Target -and
        $_.RecordData.Preference -eq $Priority
    }

    if ($null -eq $record)
    {
        return @{
            Name      = $Name
            Zone      = $Zone
            Target    = $Target
            Priority  = $Priority
            TTL       = $null
            DnsServer = $DnsServer
            Ensure    = 'Absent'
        }
    }

    return @{
        Name      = $record.HostName
        Zone      = $Zone
        Target    = $record.RecordData.MailExchange
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

        [Parameter(Mandatory = $true)]
        [System.UInt16]
        $Priority,

        [Parameter()]
        [ValidateScript( { $ts = New-TimeSpan; [System.TimeSpan]::TryParse($_, [ref]$ts) })]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = 'localhost',

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $Target = $Target | ConvertTo-FollowRfc1034

    $dnsParameters = @{
        ZoneName     = $Zone
        ComputerName = $DnsServer
    }

    $existingMxRecord = Get-DnsServerResourceRecord @dnsParameters -Name $Name -RRType 'Mx' -ErrorAction SilentlyContinue | Where-Object -FilterScript {
        $_.RecordData.MailExchange -eq $Target -and
        $_.RecordData.Preference -eq $Priority
    }

    if ($Ensure -eq 'Present')
    {
        # If the entry exists, update it instead of adding a new one
        if ($null -ne $existingMxRecord)
        {
            $newMxRecord = [Microsoft.Management.Infrastructure.CimInstance]::new($existingMxRecord)

            if ($PSBoundParameters.ContainsKey('TTL'))
            {
                $newMxRecord.TimeToLive = [System.TimeSpan]::Parse($TTL)
            }

            $dnsParameters.Add('OldInputObject', $existingMxRecord)
            $dnsParameters.Add('NewInputObject', $newMxRecord)

            Write-Verbose -Message ($script:localizedData.UpdatingDnsRecordMessage -f 'MX', $Target, $Zone, $DnsServer)

            Set-DnsServerResourceRecord @dnsParameters
        }
        else
        {
            $dnsParameters.Add('Name', $Name)
            $dnsParameters.Add('Mx', $true)
            $dnsParameters.Add('MailExchange', $Target)
            $dnsParameters.Add('Preference', $Priority)

            if ($PSBoundParameters.ContainsKey('TTL'))
            {
                $dnsParameters.Add('TimeToLive', $TTL)
            }

            Write-Verbose -Message ($script:localizedData.CreatingDnsRecordMessage -f 'MX', $Target, $Zone, $DnsServer)

            Add-DnsServerResourceRecord @dnsParameters
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        if ($null -ne $existingMxRecord)
        {
            Write-Verbose -Message ($script:localizedData.RemovingDnsRecordMessage -f 'MX', $Target, $Zone, $DnsServer)

            $existingMxRecord | Remove-DnsServerResourceRecord @dnsParameters
        }
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

        [Parameter(Mandatory = $true)]
        [System.UInt16]
        $Priority,

        [Parameter()]
        [ValidateScript( { $ts = New-TimeSpan; [System.TimeSpan]::TryParse($_, [ref]$ts) })]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = 'localhost',

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    # Get-TargetResource does not take the full set of arguments
    $getTargetResourceParams = @{
        Name         = $Name
        Zone         = $Zone
        Target       = $Target
        Priority     = $Priority
        DnsServer    = $DnsServer
    }

    $result = @(Get-TargetResource @getTargetResourceParams)

    if ($Ensure -ne $result.Ensure)
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', $Ensure, $result.Ensure)
        Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $Name)

        return $false
    }
    elseif ($Ensure -eq 'Present')
    {
        if ($PSBoundParameters.ContainsKey('TTL') -and $result.TTL -ne $TTL)
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
