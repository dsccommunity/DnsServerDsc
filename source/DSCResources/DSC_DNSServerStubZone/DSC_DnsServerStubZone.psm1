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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ipaddress[]]
        $MasterServers,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

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
        MasterServers = $dnsServerZone.MasterServers | ForEach-Object { $_.IPAddressToString }
        ZoneFile = $dnsServerZone.ZoneFile
        Ensure = if (-not $dnsServerZone) { 'Absent' } else { 'Present' }
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

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ipaddress[]]
        $MasterServers,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters
    $targetResourceInCompliance = $true
    $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue

    #If we specify that we want to ensure the zone should be ABSENT, check compliance.
    if ($Ensure -eq 'Absent')
    {
        #If the results of our Get-TargetResource shows that the zone is PRESENT, set compliance, because we want it to be absent.
        if ($targetResource.Ensure -eq 'Present')
        {
            # Dns zone is present and should be absent.                        '{0}'      '{1}'     '{2}'     <--- Definitions in the DSC_DnsServerStubZone.strings.psd1
            Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', 'Absent', 'Present')

            $targetResourceInCompliance = $false
            return $targetResourceInCompliance

        }
    }
    #If we specify that we want to ensure the zone should be PRESENT, check compliance.
    if ($Ensure -eq 'Present')
    {

        #If the results of our Get-TargetResource shows that the zone is PRESENT, set compliance, because we want it to be absent.
        if ($targetResource.Ensure -eq 'Absent')
        {
            # Dns zone is absent and should be present.
            Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', 'Present', 'Absent')

            $targetResourceInCompliance = $false
            return $targetResourceInCompliance
        }

        #If the results of our Get-TargetResource shows that the zone is PRESENT, move on to the next validation check.
        if ($targetResource.Ensure -eq 'Present')
        {

            #If the Zone is AD integrated, set non-compliance.
            if ($dnsServerZone.IsDSIntegrated -eq $true)
            {
                #Zone Storage differs from the desired configuration
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'ZoneStorageLocation', 'Active Directory', 'File')

                $targetResourceInCompliance = $false
                return $targetResourceInCompliance
            }
            #If the ZoneType isn't of type Stub, set non-compliance.
            if ($dnsServerZone.ZoneType -ne 'Stub')
            {
                #Zone Type differs from the desired configuration
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'ZoneType', 'Stub', $dnsServerZone.ZoneType)

                $targetResourceInCompliance = $false
                return $targetResourceInCompliance
            }
            #If the Zone File name differ from the desired configuration, set non-compliance.
            if ($targetResource.ZoneFile -ne $ZoneFile)
            {
                #ZoneFile name differs from the desired configuration
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'ZoneFile', $targetResource.ZoneFile, $ZoneFile)

                $targetResourceInCompliance = $false
                return $targetResourceInCompliance
            }
            #If the Master Servers differ from the desired configuration, set non-compliance.
            $Comparison = Compare-Object -ReferenceObject $MasterServers -DifferenceObject $targetResource.MasterServers
            if ($Comparison)
            {
                #Zone  Master Servers differ from the desired configuration
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'MasterServers', ($MasterServers -join ','), ($targetResource.MasterServers -join ','))
                $targetResourceInCompliance = $false
            }

            return $targetResourceInCompliance

        }

    }

} #end function Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ipaddress[]]
        $MasterServers,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ZoneFile = "$Name.dns",

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Assert-Module -ModuleName 'DNSServer'
    $dnsServerZone = Get-DnsServerZone -Name $Name -ErrorAction SilentlyContinue

    if ($Ensure -eq 'Absent')
    {
        Write-Verbose ($script:localizedData.CheckingZoneMessage -f $Name, $Ensure)

        IF($dnsServerZone.type -eq 'Stub' -and $dnsServerZone.IsDSIntegrated -eq $false)
        {

        # Remove the DNS Server zone.
        Write-Verbose ($script:localizedData.RemovingZoneMessage -f $Name)
        Get-DnsServerZone -Name $Name | Remove-DnsServerZone -Force

        }
        else
        {
            IF($dnsServerZone.type -ne 'Stub'){

                # Zone is not a stub zone.
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'ZoneType', 'Stub', $dnsServerZone.ZoneType)
            }
            If($dnsServerZone.IsDSIntegrated -ne $false){

                # Zone is AD integrated.
                Write-Verbose ($script:localizedData.NotDesiredPropertyMessage -f 'ZoneStorageLocation', 'Active Directory', 'File')
            }

        }
    }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose ($script:localizedData.CheckingZoneMessage -f $Name, $Ensure)

        if ($dnsServerZone.ZoneType -eq 'Stub' -and $dnsServerZone.IsDSIntegrated -eq $false)
        {
            # Compare the Desired master servers to the Existing master servers - if Existing doesn't match Desired, update the master servers for the zone.
            $Comparison = Compare-Object -ReferenceObject $MasterServers -DifferenceObject $targetResource.MasterServers

            if (-not $Comparison)
            {
                # Update the Master Servers list
                Set-DnsServerStubZone -Name $Name -MasterServers $MasterServers

                Write-Verbose ($script:localizedData.SetPropertyMessage -f 'MasterServers')
            }

        }
        elseif (-not $dnsServerZone)
        {
            # Create the DNS Server zone.
            Add-DnsServerStubZone -Name $Name -ZoneFile $ZoneFile -MasterServers $MasterServers

            Write-Verbose ($script:localizedData.AddingZoneMessage -f $Name)
        }
    }

} #end function Set-TargetResource
