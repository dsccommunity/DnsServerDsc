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
        [parameter(Mandatory)]
        [String]$Name,

        [parameter(Mandatory)]
        [String]$ZoneFile,

        [ValidateSet('None','NonsecureAndSecure')]
        [String]$DynamicUpdate = 'None',
        
        [ValidateSet('Present','Absent')]
        [String]$Ensure = 'Present'
    )

    $targetResource = @{
        Name = $Name;
        ZoneFile = $ZoneFile;
        DynamicUpdate = $DynamicUpdate;
        Ensure = ''
    }
    if ($Ensure -eq 'Present') {
        if (Test-TargetResource @PSBoundParameters) {
            $targetResource['Ensure'] = 'Present';
        }
        else {
            $targetResource['Ensure'] = 'Absent';
        }
    }
    elseif ($Ensure -eq 'Absent') {
        if (Test-TargetResource @PSBoundParameters) {
            $targetResource['Ensure'] = 'Absent';
        }
        else {
            $targetResource['Ensure'] = 'Present';
        }
    }

    return $targetResource;
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory)]
        [String]$Name,

        [parameter(Mandatory)]
        [String]$ZoneFile,

        [ValidateSet('None','NonsecureAndSecure')]
        [String]$DynamicUpdate = 'None',
        
        [ValidateSet('Present','Absent')]
        [String]$Ensure = 'Present'
    )

    Assert-Module -ModuleName 'DNSServer';
    Write-Verbose ($LocalizedData.CheckingZoneMessage -f $Name, $Ensure);
    $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue;

    $targetResourceInCompliance = $true;

    if (($Ensure -eq 'Present') -and (-not $dnsServerZone)) {
        Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'Ensure', 'Present', 'Absent');
        $targetResourceInCompliance = $false;
    }
    elseif (($Ensure -eq 'Present') -and ($dnsServerZone)) {
        if ($dnsServerZone.ZoneFile -ne $ZoneFile) {
            Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'ZoneFile', $dnsServerZone.ZoneFile, $ZoneFile);
            $targetResourceInCompliance = $false;
        }
        elseif ($dnsServerZone.DynamicUpdate -ne $DynamicUpdate) {
            Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'DynamicUpdate', $dnsServerZone.DynamicUpdate, $DynamicUpdate);
            $targetResourceInCompliance = $false;
        }
    }
    elseif (($Ensure -eq 'Absent') -and ($dnsServerZone)) {
        Write-Verbose ($LocalizedData.NotDesiredPropertyMessage -f 'Ensure', 'Absent', 'Present');
        $targetResourceInCompliance = $false;
    }

    return $targetResourceInCompliance;
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [String]$Name,

        [parameter(Mandatory)]
        [String]$ZoneFile,

        [ValidateSet('None','NonsecureAndSecure')]
        [String]$DynamicUpdate = 'None',
        
        [ValidateSet('Present','Absent')]
        [String]$Ensure = 'Present'
    )

    Assert-Module -ModuleName 'DNSServer';

    if ($Ensure -eq 'Present') {
        Write-Verbose ($LocalizedData.CheckingZoneMessage -f $Name, $Ensure);
        $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue;
        if ($dnsServerZone) {
            ## Update the existing zone
            if ($dnsServerZone.ZoneFile -ne $ZoneFile) {
                $dnsServerZone | Set-DnsServerPrimaryZone -ZoneFile $ZoneFile;
                Write-Verbose ($LocalizedData.SetPropertyMessage -f 'ZoneFile');
            }
            if ($dnsServerZone.DynamicUpdate -ne $DynamicUpdate) {
                $dnsServerZone | Set-DnsServerPrimaryZone -DynamicUpdate $DynamicUpdate;
                Write-Verbose ($LocalizedData.SetPropertyMessage -f 'DynamicUpdate');
            }
        }
        elseif (-not $dnsServerZone) {
            ## Create the zone
            Write-Verbose ($LocalizedData.AddingZoneMessage -f $Name);
            Add-DnsServerPrimaryZone -Name $Name -ZoneFile $ZoneFile -DynamicUpdate $DynamicUpdate;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        # Remove the DNS Server zone
        Write-Verbose ($LocalizedData.RemovingZoneMessage -f $Name);
        Get-DnsServerZone -Name $Name | Remove-DnsServerZone -Force;
    }

}
