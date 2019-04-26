function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter()]
        [ValidateSet('Absent', 'Present')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory)]
        [String]
        $Name,

        [Parameter(Mandatory)]
        [String[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('None', 'Custom', 'Domain', 'Forest', 'Legacy')]
        [String]
        $ReplicationScope = 'None',

        [Parameter()]
        [String]
        $DirectoryPartition,

        [Parameter()]
        [String]
        $ComputerName,

        [Parameter()]
        [PSCredential]
        $Credential
    )

    $cimParams = NewCimSessionParameter

    $targetResource = @{
        Ensure             = $Ensure
        Name               = $Name
        MasterServers      = $null
        ReplicationScope   = $null
        DirectoryPartition = $null
        ZoneType           = $null
        ComputerName       = $ComputerName
    }

    $zone = Get-DnsServerZone -Name $Name @cimParams -ErrorAction SilentlyContinue
    if ($zone)
    {
        $targetResource.ZoneType = $zone.ZoneType
    }
    if ($zone -and $zone.ZoneType -eq 'Forwarder')
    {
        $targetResource.Ensure = 'Present'
        $targetResource.MasterServers = $zone.MasterServers

        if ($zone.IsDsIntegrated)
        {
            $targetResource.ReplicationScope = $zone.ReplicationScope
        }
        else
        {
            $targetResource.ReplicationScope = 'None'
        }
    }
    else
    {
        $targetResource.Ensure = 'Absent'
    }

    $targetResource
}

function Set-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter()]
        [ValidateSet('Absent', 'Present')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory)]
        [String]
        $Name,

        [Parameter(Mandatory)]
        [String[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('None', 'Custom', 'Domain', 'Forest', 'Legacy')]
        [String]
        $ReplicationScope = 'None',

        [Parameter()]
        [String]
        $DirectoryPartition,

        [Parameter()]
        [String]
        $ComputerName,

        [Parameter()]
        [PSCredential]
        $Credential
    )

    $cimParams = NewCimSessionParameter

    $zone = Get-DnsServerZone -Name $Name @cimParams -ErrorAction SilentlyContinue
    if ($Ensure -eq 'Present')
    {
        $params = @{
            Name         = $Name
            MasterServer = $MasterServers
        }

        if ($zone)
        {
            if ($zone.ZoneType -ne 'Forwarder' -or
                ($zone.IsDsIntegrated -and $ReplicationScope -eq 'None') -or
                (-not $zone.IsDsIntegrated -and $ReplicationScope -ne 'None'))
            {

                Remove-DnsServerZone -Name $Name @cimParams
                $zone = $null
            }
            else
            {
                Set-DnsServerConditionalForwarderZone @params @cimParams
            }
        }

        if ($ReplicationScope -ne 'None')
        {
            $params.ReplicationScope = $ReplicationScope
        }
        if (-not $zone)
        {
            Add-DnsServerConditionalForwarderZone @params @cimParams
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        if ($zone -and $zone.ZoneType -eq 'Forwarder')
        {
            Remove-DnsServerZone -Name $Name @cimParams
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter()]
        [ValidateSet('Absent', 'Present')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory)]
        [String]
        $Name,

        [Parameter(Mandatory)]
        [String[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('None', 'Custom', 'Domain', 'Forest', 'Legacy')]
        [String]
        $ReplicationScope = 'None',

        [Parameter()]
        [String]
        $DirectoryPartition,

        [Parameter()]
        [String]
        $ComputerName,

        [Parameter()]
        [PSCredential]
        $Credential
    )

    $zone = Get-DnsServerZone -Name $Name @cimParams -ErrorAction SilentlyContinue
    if ($Ensure -eq 'Present')
    {
        if (-not $zone)
        {
            return $false
        }

        if ($zone.ZoneType -ne 'Forwarder')
        {
            return $false
        }

        if ($zone.IsDsIntegrated -and $ReplicationScope -eq 'None')
        {
            return $false
        }

        if ($zone.IsDsIntegrated -and $zone.ReplicationScope -ne $ReplicationScope)
        {
            return $false
        }

        if ("$($zone.MasterServers)" -ne "$MasterServers")
        {
            return $false
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        if ($zone -and $zone.ZoneType -eq 'Forwarder')
        {
            return $false
        }
    }

    return $true
}

function NewCimSessionParameter {
    [CmdletBinding()]
    param (
        [String]
        $ComputerName,

        [PSCredential]
        $Credential,

        [Parameter(ValueFromRemainingArguments)]
        $Ignore
    )

    $cimSession = @{}
    if ($ComputerName)
    {
        $cimSession.ComputerName = $ComputerName
    }
    if ($Credential)
    {
        $cimSession.Credential = $Credential
    }
    if ($cimSession.Count -gt 0)
    {
        @{
            CimSession = New-CimSession @params
        }
    }
    else
    {
        @{}
    }
}
