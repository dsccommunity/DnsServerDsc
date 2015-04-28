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
    return (Get-DnsServerResourceRecord -ZoneName $Zone -Name $Name)
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
    return ((Get-DnsServerResourceRecord -ZoneName $Zone -Name $Name -ErrorAction SilentlyContinue) -ne $null) 
}


Export-ModuleMember -Function *-TargetResource

