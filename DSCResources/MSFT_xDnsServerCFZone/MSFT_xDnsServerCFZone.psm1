# Localized messages
data LocalizedData {
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

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Custom', 'Domain', 'Forest', 'Legacy')]
        [System.String]
        $ReplicationScope,

        [Parameter()]
        [System.String]
        $DirectoryPartitionName,

        [Parameter(Mandatory)]
        [System.String[]]$MasterServers,

        [ValidateSet('Present', 'Absent')]
        [System.String]$Ensure = 'Present'
    )

    Write-Verbose ($LocalizedData.CheckingZoneMessage -f $Name, $Ensure);
    $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue;

    $targetResource = @{
        Name                   = $dnsServerZone.Name;
        ReplicationScope       = $dnsServerZone.ReplicationScope
        DirectoryPartitionName = $dnsServerZone.DirectoryPartitionName
        MasterServers          = $dnsServerZone.MasterServers;
        Ensure                 = if ($dnsServerZone -eq $null) {
            'Absent'
        }
        else {
            'Present'
        };
    }

    return $targetResource;

} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Custom', 'Domain', 'Forest', 'Legacy')]
        [System.String]
        $ReplicationScope,

        [Parameter()]
        [System.String]
        $DirectoryPartitionName,

        [Parameter(Mandatory)]
        [System.String[]]$MasterServers,

        [ValidateSet('Present', 'Absent')]
        [System.String]$Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    $targetResourceInCompliance = $true;

    if ($Ensure -eq 'Present') {
        if ($targetResource.Ensure -eq 'Present') {
            $MasterComparison = Compare-Object $targetResource["MasterServers"] $MasterServers -ErrorAction SilentlyContinue -ev comparison
            if ($MasterComparison -ne $null -or $comparison -ne $null) {
                Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'MasterServers', ($targetResource.MasterServers -join ','), ($MasterServers -join ','));
                $targetResourceInCompliance = $false;
            }
            if ($targetResource.ReplicationScope -ne $ReplicationScope) {
                Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'ReplicationScope', $ReplicationScope, $targetResource.ReplicationScope)
                $targetResourceInCompliance = $false
            }
            if ($DirectoryPartitionName -and $targetResource.DirectoryPartitionName -ne $DirectoryPartitionName) {
                Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'DirectoryPartitionName', $DirectoryPartitionName, $targetResource.DirectoryPartitionName)
                $targetResourceInCompliance = $false
            }
        }
        else {
            # Dns zone is present and needs removing
            Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'Ensure', 'Absent', 'Present');
            $targetResourceInCompliance = $false;
        }
    }
    else {
        if ($targetResource.Ensure -eq 'Present') {
            ## Dns zone is absent and should be present
            Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'Ensure', 'Absent', 'Present');
            $targetResourceInCompliance = $false;
        }
    }

    return $targetResourceInCompliance;

} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Custom', 'Domain', 'Forest', 'Legacy')]
        [System.String]
        $ReplicationScope,

        [Parameter()]
        [System.String]
        $DirectoryPartitionName,

        [Parameter(Mandatory)]
        [System.String[]]$MasterServers,

        [ValidateSet('Present', 'Absent')]
        [System.String]$Ensure = 'Present'
    )

    if ($Ensure -eq 'Present') {
        Write-Verbose ($LocalizedData.CheckingZoneMessage -f $Name, $Ensure);
        $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue;
        if ($dnsServerZone) {
            Set-DnsServerConditionalForwarderZone -Name $Name -MasterServers $MasterServers;
            Write-Verbose ($LocalizedData.SetPropertyMessage -f 'MasterServers');

            Set-DnsServerConditionalForwarderZone -Name $Name -ReplicationScope $ReplicationScope -DirectoryPartitionName $DirectoryPartitionName;
            Write-Verbose ($LocalizedData.SetPropertyMessage -f 'Replication Scope');
        }
        elseif (-not $dnsServerZone) {
            ## Create the zone
            Write-Verbose ($LocalizedData.AddingZoneMessage -f $Name);
            Add-DnsServerConditionalForwarderZone -Name $Name -MasterServers $MasterServers -ReplicationScope $ReplicationScope -DirectoryPartitionName $DirectoryPartitionName;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        # Remove the DNS Server zone
        Write-Verbose ($LocalizedData.RemovingZoneMessage -f $Name);
        Get-DnsServerZone -Name $Name | Remove-DnsServerZone -Force;
    }

} #end function Set-TargetResource
