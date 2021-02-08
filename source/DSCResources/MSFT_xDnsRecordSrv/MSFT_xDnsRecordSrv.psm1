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
        [ValidateSet('TCP', 'UDP')]
        [System.String]
        $Protocol,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 65535)]
        [System.UInt16]
        $Port,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.String]
        $DnsServer = (Get-ComputerName)
    )

    $recordHostName = "_$($SymbolicName)._$($Protocol)".ToLower()

    Write-Verbose -Message ($script:localizedData.GettingDnsRecordMessage -f $recordHostName, $target, 'SRV', $Zone, $DnsServer)

    $dnsParameters = @{
        Name         = $recordHostName
        ZoneName     = $Zone
        ComputerName = $DnsServer
        RRType       = 'SRV'
    }

    $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object {
        $_.HostName -eq $recordHostName -and
        $_.RecordData.Port -eq $Port -and
        $_.RecordData.DomainName -eq "$($Target)."
    }

    if ($null -eq $record)
    {
        return @{
            Zone         = $Zone
            SymbolicName = $SymbolicName
            Protocol     = $Protocol.ToLower()
            Port         = $Port
            Target       = $Target
            Priority     = $null
            Weight       = $null
            TTL          = $null
            DnsServer    = $DnsServer
            Ensure       = 'Absent'
        }
    }

    return @{
        Zone         = $Zone
        SymbolicName = $SymbolicName
        Protocol     = $Protocol.ToLower()
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
        [ValidateSet('TCP', 'UDP')]
        [System.String]
        $Protocol,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 65535)]
        [System.UInt16]
        $Port,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.UInt16]
        $Priority,

        [Parameter()]
        [System.UInt16]
        $Weight,

        [Parameter()]
        [ValidateScript( { $ts = New-TimeSpan; [System.Timespan]::TryParse($_, [ref] $ts) })]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = (Get-ComputerName),

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $dnsParameters = @{
        ZoneName     = $Zone
        ComputerName = $DnsServer
    }

    $recordHostName = "_$($SymbolicName)._$($Protocol)".ToLower()

    $existingSrvRecord = Get-DnsServerResourceRecord @dnsParameters -RRType 'SRV' -ErrorAction SilentlyContinue | Where-Object {
        $_.HostName -eq $recordHostName -and
        $_.RecordData.Port -eq $Port -and
        $_.RecordData.DomainName -eq "$($Target)."
    }

    if ($Ensure -eq 'Present')
    {
        # If the entry exists, update it instead of adding a new one
        if ($null -ne $existingSrvRecord)
        {
            $newSrvRecord = $existingSrvRecord.Clone()

            # Priority, weight, and TTL will not always have values
            if ($PSBoundParameters.ContainsKey('Priority'))
            {
                $newSrvRecord.RecordData.Priority = $Priority
            }

            if ($PSBoundParameters.ContainsKey('Weight'))
            {
                $newSrvRecord.RecordData.Weight = $Weight
            }

            if ($PSBoundParameters.ContainsKey('TTL'))
            {
                <#
                    The value must be explicitly cast to a timespan,
                    otherwise it gets parsed as a date.
                #>
                $newSrvRecord.TimeToLive = [timespan] $TTL
            }

            $dnsParameters.Add('OldInputObject', $existingSrvRecord)
            $dnsParameters.Add('NewInputObject', $newSrvRecord)

            Write-Verbose -Message ($script:localizedData.UpdatingDnsRecordMessage -f 'SRV', $recordHostName, $Target, $Zone, $DnsServer)

            Set-DnsServerResourceRecord @dnsParameters
        }
        else
        {
            $dnsParameters.Add('Name', $recordHostName)
            $dnsParameters.Add('Srv', $true)
            $dnsParameters.Add('DomainName', $Target)
            $dnsParameters.Add('Port', $Port)
            if ($PSBoundParameters.ContainsKey('Priority'))
            {
                $dnsParameters.Add('Priority', $Priority)
            }
            if ($PSBoundParameters.ContainsKey('Weight'))
            {
                $dnsParameters.Add('Weight', $Weight)
            }
            if ($PSBoundParameters.ContainsKey('TTL'))
            {
                $dnsParameters.Add('TimeToLive', $TTL)
            }

            Write-Verbose -Message ($script:localizedData.CreatingDnsRecordMessage -f 'SRV', $recordHostName, $Target, $Zone, $DnsServer)

            Add-DnsServerResourceRecord @dnsParameters
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        if ($null -ne $existingSrvRecord)
        {
            Write-Verbose -Message ($script:localizedData.RemovingDnsRecordMessage -f 'SRV', $recordHostName, $Target, $Zone, $DnsServer)

            $existingSrvRecord | Remove-DnsServerResourceRecord @dnsParameters
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
        [ValidateSet('TCP', 'UDP')]
        [System.String]
        $Protocol,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 65535)]
        [System.UInt16]
        $Port,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [Parameter()]
        [System.UInt16]
        $Priority,

        [Parameter()]
        [System.UInt16]
        $Weight,

        [Parameter()]
        [ValidateScript( { $ts = New-TimeSpan; [System.Timespan]::TryParse($_, [ref] $ts) })]
        [System.String]
        $TTL,

        [Parameter()]
        [System.String]
        $DnsServer = (Get-Computername),

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    # Set up a variable to determine the result of the test
    $hasPassedTest = $true

    # Get-TargetResource does not take the full set of arguments
    $getTargetResourceParams = @{
        Zone         = $Zone
        SymbolicName = $SymbolicName
        Protocol     = $Protocol
        Port         = $Port
        Target       = $Target
        DnsServer    = $DnsServer
    }
    $result = Get-TargetResource @getTargetResourceParams

    $resultHostName = "_$($result.SymbolicName)._$($result.Protocol)"

    if ($Ensure -ne $result.Ensure)
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', $Ensure, $result.Ensure)
        $hasPassedTest = $false
    }
    if ($Ensure -eq 'Present')
    {
        if ($result.SymbolicName -ne $SymbolicName)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'SymbolicName', $SymbolicName, $result.SymbolicName)
            $hasPassedTest = $false
        }

        if ($result.Protocol -ne $Protocol)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Protocol', $Protocol.ToLower(), $result.Protocol)
            $hasPassedTest = $false
        }

        if ($result.Port -ne $Port)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Port', $Port, $result.Port)
            $hasPassedTest = $false
        }

        if ($result.Target -ne $Target)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Target', $Target, $result.Target)
            $hasPassedTest = $false
        }

        if ($PSBoundParameters.ContainsKey('Priority') -ne $Priority)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Priority', $Priority, $result.Priority)
            $hasPassedTest = $false
        }

        if ($PSBoundParameters.ContainsKey('Weight') -ne $Weight)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Weight', $Weight, $result.Weight)
            $hasPassedTest = $false
        }

        if ($PSBoundParameters.ContainsKey('TTL') -and $result.TTL -ne $TTL)
        {
            Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'TTL', $TTL, $result.TTL)
            $hasPassedTest = $false
        }
    }

    if ($hasPassedTest)
    {
        Write-Verbose -Message ($script:localizedData.InDesiredStateMessage -f $resultHostName)
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $resultHostName)
    }

    return $hasPassedTest
} #end function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
