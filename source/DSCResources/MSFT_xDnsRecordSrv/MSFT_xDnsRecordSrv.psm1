$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        This will return the current state of the resource.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER SymbolicName
        Service name for the SRV record. eg: xmpp, ldap, etc.

    .PARAMETER Protocol
        Service transmission protocol ('TCP' or 'UDP')

    .PARAMETER Port
        The TCP or UDP port on which the service is found

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER Priority
        Specifies the Priority value of the SRV record.

    .PARAMETER Weight
        Specifies the weight of the SRV record.

    .PARAMETER TTL
        Specifies the TTL value of the SRV record. Value must be in valid TimeSpan format.

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
        $Zone,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SymbolicName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP','UDP')]
        [System.String]
        $Protocol,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1,65535)]
        [System.UInt16]
        $Port,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.UInt16]
        $Priority=10,

        [Parameter()]
        [System.UInt16]
        $Weight=20,

        [Parameter()]
        [ValidateScript({$ts = New-TimeSpan; [system.timespan]::TryParse($_, [ref]$ts)})]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = 'localhost',

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )
    $recordHostName = "_$($SymbolicName)._$($Protocol)".ToLower()

    Write-Verbose -Message ($script:localizedData.GettingDnsRecordMessage -f $recordHostName, $target, 'SRV', $Zone, $DnsServer)

    $DNSParameters = @{
        Name         = $recordHostName
        ZoneName     = $Zone
        ComputerName = $DnsServer
        RRType       = 'SRV'
    }

    $record = Get-DnsServerResourceRecord @DNSParameters -ErrorAction SilentlyContinue | Where-Object { $_.RecordData.DomainName -eq "$($Target)." }

    if ($null -eq $record)
    {
        return @{
            Zone         = $Zone
            SymbolicName = $SymbolicName
            Protocol     = $Protocol
            Port         = $Port
            Target       = $Target
            Priority     = $Priority
            Weight       = $Weight
            TTL          = $TTL
            DnsServer    = $DnsServer
            Ensure       = 'Absent'
        }
    }

    return @{
        Zone         = $Zone
        SymbolicName = $SymbolicName
        Protocol     = $Protocol
        Port         = $Port
        Target       = ($record.RecordData.DomainName).TrimEnd('.')
        Priority     = $record.RecordData.Priority
        Weight       = $record.RecordData.Weight
        TTL          = $record.TimeToLive.ToString()
        DnsServer    = $DnsServer
        Ensure       = 'Present'
    }
} #end function Get-TargetResource

<#
    .SYNOPSIS
        This will set the resource to the desired state.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER SymbolicName
        Service name for the SRV record. eg: xmpp, ldap, etc.

    .PARAMETER Protocol
        Service transmission protocol ('TCP' or 'UDP')

    .PARAMETER Port
        The TCP or UDP port on which the service is found

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER Priority
        Specifies the Priority value of the SRV record.

    .PARAMETER Weight
        Specifies the weight of the SRV record.

    .PARAMETER TTL
        Specifies the TTL value of the SRV record. Value must be in valid TimeSpan format.

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
        $Zone,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SymbolicName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP','UDP')]
        [System.String]
        $Protocol,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1,65535)]
        [System.UInt16]
        $Port,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.UInt16]
        $Priority=10,

        [Parameter()]
        [System.UInt16]
        $Weight=20,

        [Parameter()]
        [ValidateScript({$ts = New-TimeSpan; [system.timespan]::TryParse($_, [ref]$ts)})]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = 'localhost',

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $DNSParameters = @{
        ZoneName     = $Zone
        ComputerName = $DnsServer
    }
    $recordHostName = "_$($SymbolicName)._$($Protocol)".ToLower()

    $OldObj = Get-DnsServerResourceRecord @DNSParameters -RRType 'SRV' -ErrorAction SilentlyContinue | Where-Object { $_.RecordData.DomainName -eq "$($Target)." }

    if ($Ensure -eq 'Present')
    {
        # If the entry exists, update it instead of adding a new one
        if ($null -ne $OldObj)
        {
            $NewObj = $OldObj.Clone()

            # Priority and weight will always have values
            $NewObj.RecordData.Priority = $Priority
            $NewObj.RecordData.Priority = $Weight

            # TTL may not have a value provided
            if (-not [string]::IsNullOrEmpty($TTL))
            {
                $NewObj.TimeToLive = $TTL
            }

            $DNSParameters.Add('OldInputObject', $OldObj)
            $DNSParameters.Add('NewInputObject', $NewObj)

            Write-Verbose -Message ($script:localizedData.UpdatingDnsRecordMessage -f 'SRV', $recordHostName, $Target, $Zone, $DnsServer)
            Set-DnsServerResourceRecord @DNSParameters
        }
        else
        {
            $DNSParameters.Add('Name',$recordHostName)
            $DNSParameters.Add('Srv',$true)
            $DNSParameters.Add('DomainName', $Target)
            $DNSParameters.Add('Port', $Port)
            $DNSParameters.Add('Priority', $Priority)
            $DNSParameters.Add('Weight', $Weight)

            if ($null -ne $TTL)
            {
                $DNSParameters.Add('TimeToLive', $TTL)
            }

            Write-Verbose -Message ($script:localizedData.CreatingDnsRecordMessage -f 'SRV', $recordHostName, $Target, $Zone, $DnsServer)
            Add-DnsServerResourceRecord @DNSParameters
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        if ($null -ne $OldObj)
        {
            Write-Verbose -Message ($script:localizedData.RemovingDnsRecordMessage -f 'SRV', $recordHostName, $Target, $Zone, $DnsServer)
            $OldObj | Remove-DnsServerResourceRecord @DNSParameters
        }
    }
} #end function Set-TargetResource

<#
    .SYNOPSIS
        This will return whether the resource is in desired state.

    .PARAMETER Zone
        Specifies the name of a DNS zone.

    .PARAMETER SymbolicName
        Service name for the SRV record. eg: xmpp, ldap, etc.

    .PARAMETER Protocol
        Service transmission protocol ('TCP' or 'UDP')

    .PARAMETER Port
        The TCP or UDP port on which the service is found

    .PARAMETER Target
        Specifies the Target Hostname or IP Address.

    .PARAMETER Priority
        Specifies the Priority value of the SRV record.

    .PARAMETER Weight
        Specifies the weight of the SRV record.

    .PARAMETER TTL
        Specifies the TTL value of the SRV record. Value must be in valid TimeSpan format.

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
        $Zone,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SymbolicName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP','UDP')]
        [System.String]
        $Protocol,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1,65535)]
        [System.UInt16]
        $Port,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.UInt16]
        $Priority=10,

        [Parameter()]
        [System.UInt16]
        $Weight=20,

        [Parameter()]
        [ValidateScript({$ts = New-TimeSpan; [system.timespan]::TryParse($_, [ref]$ts)})]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = 'localhost',

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $result = @(Get-TargetResource @PSBoundParameters)

    $resultHostName = "_$($result.SymbolicName)._$($result.Protocol)"

    if ($Ensure -ne $result.Ensure)
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', $Ensure, $result.Ensure)
        Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
        return $false
    }
    elseif ($Ensure -eq 'Present')
    {
        if ($result.SymbolicName -ne $SymbolicName)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'SymbolicName', $Priority, $result.SymbolicName)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
            return $false
        }
        elseif ($result.Protocol -ne $Protocol)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Protocol', $Priority, $result.Protocol)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
            return $false
        }
        elseif ($result.Port -ne $Port)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Port', $Priority, $result.Port)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
            return $false
        }
        elseif ($result.Target -ne $Target)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Target', $Target, $result.Target)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
            return $false
        }
        elseif ($result.Priority -ne $Priority)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Priority', $Priority, $result.Priority)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
            return $false
        }
        elseif ($result.Weight -ne $Weight)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Weight', $Priority, $result.Weight)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
            return $false
        }
        elseif (-not [string]::IsNullOrEmpty($TTL) -and $result.TTL -ne $TTL)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'TTL', $TTL, $result.TTL)
            Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
            return $false
        }
    }
    Write-Verbose -Message ($script:localizedData.InDesiredStateMessage -f $resultHostName)
    return $true
} #end function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
