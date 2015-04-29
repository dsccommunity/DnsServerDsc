function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Zone,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target
    )

    Write-Verbose "Looking up DNS record for $Name in $Zone"
    $record = Get-DnsServerResourceRecord -ZoneName $Zone -Name $Name -ErrorAction SilentlyContinue

    if ($record -eq $null) {
        return @{}
    }

    return @{
        Name = $record.HostName
        Zone = $Zone
        Target = $record.RecordData
    }
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Zone,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target
    )
    
    Write-Verbose "Creating for DNS $Target in $Zone"
    Add-DnsServerResourceRecordA -IPv4Address $Target -Name $Name -ZoneName $Zone -ComputerName "localhost" 
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Zone,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target
    )

    Write-Verbose "Testing for DNS $Name in $Zone"
    $result = @(Get-TargetResource -Name $Name -Zone $Zone -Target $Target)

    if ($result.Count -eq 0) {return  $false} 
    else {
        if ($result.Target -ne $Target) { return $false }
    }
    return $true
}


Export-ModuleMember -Function *-TargetResource

