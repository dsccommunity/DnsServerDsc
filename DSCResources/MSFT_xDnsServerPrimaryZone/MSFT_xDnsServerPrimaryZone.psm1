Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
CheckingZoneMessage          = Checking DNS server zone with name '{0}' is '{1}'...
AddingZoneMessage            = Adding DNS server zone '{0}' ...
RemovingZoneMessage          = Removing DNS server zone '{0}' ...

CheckPropertyMessage         = Checking DNS server zone property '{0}' ...
NotDesiredPropertyMessage    = DNS server zone property '{0}' is not correct. Expected '{1}', actual '{2}'
SetPropertyMessage           = DNS server zone property '{0}' is set
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]$NameOrNetworkID,

        [bool]$ReverseLookupZone = $false,

        [System.String]$ZoneFile,

        [ValidateSet('None','NonsecureAndSecure','Secure')]
        [System.String]$DynamicUpdate = 'None',

        [ValidateSet('Domain','Forest','Legacy')]
        [System.String]$ReplicationScope,

        [ValidateSet('Present','Absent')]
        [System.String]$Ensure = 'Present'
    )

    Assert-Module -ModuleName 'DNSServer'
    if ($ReverseLookupZone)
    {
        $NetworkIDParts = ($NameOrNetworkID -split '/')[0] -split '\.'
        [array]::Reverse($NetworkIDParts)
        $NetworkIDReversed = $NetworkIDParts -join '.'
        $NameOrNetworkID = "$NetworkIDReversed.in-addr.arpa"
    }
    Write-Verbose ($LocalizedData.CheckingZoneMessage -f $NameOrNetworkID, $Ensure)
    $dnsServerZone = Get-DnsServerZone -Name $NameOrNetworkID -ErrorAction SilentlyContinue

    $targetResource = @{
        RequiredName = $NameOrNetworkID
        ExistingName = $dnsServerZone.ZoneName
        ZoneFile = $dnsServerZone.ZoneFile
        DynamicUpdate = $dnsServerZone.DynamicUpdate
        ReplicationScope = $dnsServerZone.ReplicationScope
        Ensure = if ($dnsServerZone -eq $null) { 'Absent' } else { 'Present' }
    }

    return $targetResource

} #end function Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]$NameOrNetworkID,

        [bool]$ReverseLookupZone = $false,

        [System.String]$ZoneFile,

        [ValidateSet('None','NonsecureAndSecure','Secure')]
        [System.String]$DynamicUpdate = 'None',

        [ValidateSet('Domain','Forest','Legacy')]
        [System.String]$ReplicationScope,

        [ValidateSet('Present','Absent')]
        [System.String]$Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters
    $targetResourceInCompliance = $true

    if ($Ensure -eq 'Present')
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            if ($ZoneFile -and $targetResource.ZoneFile -ne $ZoneFile)
            {
                Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'ZoneFile', $ZoneFile, $targetResource.ZoneFile)
                $targetResourceInCompliance = $false
            }
            elseif ($targetResource.DynamicUpdate -ne $DynamicUpdate)
            {
                Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'DynamicUpdate', $DynamicUpdate, $targetResource.DynamicUpdate)
                $targetResourceInCompliance = $false
            }
            elseif ($ReplicationScope -and $targetResource.ReplicationScope -ne $ReplicationScope)
            {
                Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'ReplicationScope', $ReplicationScope, $targetResource.ReplicationScope)
                $targetResourceInCompliance = $false
            }
        }
        else
        {
            # Dns zone is present and needs removing
            Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'Ensure', 'Present', 'Absent')
            $targetResourceInCompliance = $false
        }
    }
    else
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            ## Dns zone is absent and should be present
            Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'Ensure', 'Absent', 'Present')
            $targetResourceInCompliance = $false
        }
    }

    return $targetResourceInCompliance

} #end function Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]$NameOrNetworkID,

        [bool]$ReverseLookupZone = $false,

        [System.String]$ZoneFile,

        [ValidateSet('None','NonsecureAndSecure','Secure')]
        [System.String]$DynamicUpdate = 'None',

        [ValidateSet('Domain','Forest','Legacy')]
        [System.String]$ReplicationScope,

        [ValidateSet('Present','Absent')]
        [System.String]$Ensure = 'Present'
    )

    Assert-Module -ModuleName 'DNSServer'
    $targetResource = Get-TargetResource @PSBoundParameters
    if ($Ensure -eq 'Present') {
        if ($targetResource.Ensure -eq 'Present')
        {
            ## Update the existing zone
            if ($ZoneFile -and $targetResource.ZoneFile -ne $ZoneFile)
            {
                Set-DnsServerPrimaryZone -Name $targetResource.ExistingName -ZoneFile $ZoneFile
                Write-Verbose ($LocalizedData.SetPropertyMessage -f 'ZoneFile')
            }
            if ($targetResource.DynamicUpdate -ne $DynamicUpdate)
            {
                Set-DnsServerPrimaryZone -Name $targetResource.ExistingName -DynamicUpdate $DynamicUpdate
                Write-Verbose ($LocalizedData.SetPropertyMessage -f 'DynamicUpdate')
            }
            if ($ReplicationScope -and $targetResource.ReplicationScope -ne $ReplicationScope)
            {
                Set-DnsServerPrimaryZone -Name $targetResource.ExistingName -ReplicationScope $ReplicationScope
                Write-Verbose ($LocalizedData.SetPropertyMessage -f 'ReplicationScope')
            }
        }
        elseif ($targetResource.Ensure -eq 'Absent')
        {
            ## Create the zone
            Write-Verbose ($LocalizedData.AddingZoneMessage -f $targetResource.RequiredName)
            $Params = @{
                DynamicUpdate = $DynamicUpdate
            }
            if ($ReverseLookupZone) {$Params += @{NetworkID = $NameOrNetworkID}}
            else {$Params += @{Name = $NameOrNetworkID}}
            if ($ZoneFile) {$Params += @{ZoneFile = $ZoneFile}}
            if ($ReplicationScope) {$Params += @{ReplicationScope = $ReplicationScope}}
            Add-DnsServerPrimaryZone @Params
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        # Remove the DNS Server zone
        Write-Verbose ($LocalizedData.RemovingZoneMessage -f $targetResource.ExistingName)
        Remove-DnsServerZone -Name $targetResource.ExistingName -Force
    }

} #end function Set-TargetResource
