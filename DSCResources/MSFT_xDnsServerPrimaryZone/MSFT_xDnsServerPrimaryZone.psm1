# Import the Helper module
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'
Import-Module -Name (Join-Path -Path $modulePath -ChildPath (Join-Path -Path Helper -ChildPath Helper.psm1))

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xDnsServerPrimaryZone'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

        [Parameter()]
        [ValidateSet('None','NonsecureAndSecure')]
        [System.String]
        $DynamicUpdate = 'None',

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Assert-Module -Name 'DNSServer';
    Write-Verbose ($script:localizedData.CheckingZoneMessage -f $Name, $Ensure);
    $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue;

    $targetResource = @{
        Name = $dnsServerZone.ZoneName;
        ZoneFile = $dnsServerZone.ZoneFile;
        DynamicUpdate = $dnsServerZone.DynamicUpdate;
        Ensure = if ($null -eq $dnsServerZone) { 'Absent' } else { 'Present' };
    }

    return $targetResource;

} #end function Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

        [Parameter()]
        [ValidateSet('None','NonsecureAndSecure')]
        [System.String]
        $DynamicUpdate = 'None',

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    $targetResourceInCompliance = $true;

    if ($Ensure -eq 'Present')
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            if ($targetResource.ZoneFile -ne $ZoneFile)
            {
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'ZoneFile', $targetResource.ZoneFile, $ZoneFile);
                $targetResourceInCompliance = $false;
            }
            elseif ($targetResource.DynamicUpdate -ne $DynamicUpdate)
            {
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'DynamicUpdate', $targetResource.DynamicUpdate, $DynamicUpdate);
                $targetResourceInCompliance = $false;
            }
        }
        else
        {
            # Dns zone is present and needs removing
            Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', 'Absent', 'Present');
            $targetResourceInCompliance = $false;
        }
    }
    else
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            ## Dns zone is absent and should be present
            Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', 'Absent', 'Present');
            $targetResourceInCompliance = $false;
        }
    }

    return $targetResourceInCompliance;

} #end function Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

        [Parameter()]
        [ValidateSet('None','NonsecureAndSecure')]
        [System.String]
        $DynamicUpdate = 'None',

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Assert-Module -Name 'DNSServer';

    if ($Ensure -eq 'Present')
    {
        Write-Verbose ($script:localizedData.CheckingZoneMessage -f $Name, $Ensure);
        $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue;
        if ($dnsServerZone)
        {
            ## Update the existing zone
            if ($dnsServerZone.ZoneFile -ne $ZoneFile)
            {
                $dnsServerZone | Set-DnsServerPrimaryZone -ZoneFile $ZoneFile;
                Write-Verbose ($script:localizedData.SetPropertyMessage -f 'ZoneFile');
            }
            if ($dnsServerZone.DynamicUpdate -ne $DynamicUpdate)
            {
                $dnsServerZone | Set-DnsServerPrimaryZone -DynamicUpdate $DynamicUpdate;
                Write-Verbose ($script:localizedData.SetPropertyMessage -f 'DynamicUpdate');
            }
        }
        elseif (-not $dnsServerZone)
        {
            ## Create the zone
            Write-Verbose ($script:localizedData.AddingZoneMessage -f $Name);
            Add-DnsServerPrimaryZone -Name $Name -ZoneFile $ZoneFile -DynamicUpdate $DynamicUpdate;
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        # Remove the DNS Server zone
        Write-Verbose ($script:localizedData.RemovingZoneMessage -f $Name);
        Get-DnsServerZone -Name $Name | Remove-DnsServerZone -Force;
    }

} #end function Set-TargetResource
