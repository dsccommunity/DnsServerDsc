$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Assert-Module -ModuleName 'DNSServer'

    Write-Verbose ($script:localizedData.CheckingZoneMessage -f $Name, $Ensure)

    $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue
  

    $targetResource = @{
        Name = $Name
        ZoneFile = $dnsServerZone.ZoneFile
        MasterServers = $dnsServerZone.MasterServers | ForEach-Object { $_.IPAddressToString } | Sort-Object
        Ensure = if ($null -eq $dnsServerZone) { 'Absent' } else { 'Present' }
    }

    return $targetResource

} #end function Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters

    $targetResourceInCompliance = $true

    #If we specify that we want to ensure the zone should be PRESENT, check compliance.
    if ($Ensure -eq 'Present')
    {
        #If the results of our Get-TargetResource shows that the zone is PRESENT, move on to the next validation check.
        if ($targetResource.Ensure -eq 'Present')
        {
            #If the zonefile name doesn't equal what we defined, set non-compliance.
            if ($targetResource.ZoneFile -ne $ZoneFile)
            {
                #ZoneFile name differs from the desired configuration                 0}'         '{1}'                  '{2}'     <--- Definitions in the DSC_DnsServerStubZone.strings.psd1
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'ZoneFile', $targetResource.ZoneFile, $ZoneFile)

                $targetResourceInCompliance = $false
            }
            #If the Master Servers differ from the desired configuration, set non-compliance.
            if (($targetResource.MasterServers  -join ',' | Sort-Object) -ne ($MasterServers -join ',' | Sort-Object))
            {
                #Zone  Master Servers differ from the desired configuration             '{0}'            '{1}'                                '{2}'     <--- Definitions in the DSC_DnsServerStubZone.strings.psd1
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'MasterServers', ($MasterServers -join ','), ($targetResource.MasterServers -join ','))
                $targetResourceInCompliance = $false
            }
        }
        #Otherwise, if the results of our Get-TargetResource shows that the zone is ABSENT, set non-compliance, because we want it to exist.
        else
        {
            # Dns zone is absent and should be present.                        '{0}'      '{1}'     '{2}'     <--- Definitions in the DSC_DnsServerStubZone.strings.psd1
            Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', 'Present', 'Absent')

            $targetResourceInCompliance = $false
        }
    }
    #Otherwise, if $Ensure is not PRESENT we specify that means we want to ensure the zone is ABSENT, so check compliance.
    else
    {
        #If the results of our Get-TargetResource shows that the zone is present, set non-compliance.
        if ($targetResource.Ensure -eq 'Present')
        {
            # Dns zone is present and needs removing.                          '{0}'      '{1}'     '{2}'     <--- Definitions in the DSC_DnsServerStubZone.strings.psd1
            Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', 'Absent', 'Present')

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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Assert-Module -ModuleName 'DNSServer'

    if ($Ensure -eq 'Present')
    {
        Write-Verbose ($script:localizedData.CheckingZoneMessage -f $Name, $Ensure)

        $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue

        if ($dnsServerZone)
        {

        $DesiredMasterServers = $MasterServers | Sort-Object
        $CurrentMasterServers = $dnsServerZone.MasterServers | ForEach-Object { $_.IPAddressToString } | Sort-Object


            if($CurrentMasterServers -join ',' -ne $DesiredMasterServers -join ',' )
            {
                # Update the Master Servers list
                Set-DnsServerStubZone -Name $Name -MasterServers $MasterServers

                Write-Verbose ($script:localizedData.SetPropertyMessage -f 'MasterServers')
            }

        }
        elseif (-not $dnsServerZone)
        {
            # Create the DNS Server zone.
            Write-Verbose ($script:localizedData.AddingZoneMessage -f $Name)

            Add-DnsServerStubZone -Name $Name -ZoneFile $ZoneFile -MasterServers $MasterServers
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        # Remove the DNS Server zone.
        Write-Verbose ($script:localizedData.RemovingZoneMessage -f $Name)

        Get-DnsServerZone -Name $Name | Remove-DnsServerZone -Force
    }

} #end function Set-TargetResource
