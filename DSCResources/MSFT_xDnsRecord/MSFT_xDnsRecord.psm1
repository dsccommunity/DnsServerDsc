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
        [ValidateSet("A-record", "C-name")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target
    )

    Write-Verbose "Looking up DNS record for $Name in $Zone"
    $record = Get-DnsServerResourceRecord -ZoneName $Zone -Name $Name -ErrorAction SilentlyContinue
    
    if ($record -eq $null) 
    {
        return @{}
    }
    if ($Type -eq "C-name") 
    {
        $Recorddata = ($record.RecordData.hostnamealias).TrimEnd('.')
    }
    else
    {
        $Recorddata = $record.RecordData.IPv4address.IPAddressToString
    }

    return @{
        Name = $record.HostName
        Zone = $Zone
        Target = $Recorddata
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
        [ValidateSet("A-record", "C-name")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target
    )

    if ($Type -eq "A-record")
    {
        Write-Verbose "Creating $Type for DNS $Target in $Zone"
        Add-DnsServerResourceRecordA -IPv4Address $Target -Name $Name -ZoneName $Zone
    }
    if ($Type -eq "C-name")
    {
        Write-Verbose "Creating $Type for DNS $Target in $Zone"
        Add-DnsServerResourceRecordCName -HostNameAlias $Target -Name $Name -ZoneName $Zone
    }
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
        [ValidateSet("A-record", "C-name")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target
    )

    Write-Verbose "Testing for DNS $Name in $Zone"
    $result = @(Get-TargetResource -Name $Name -Zone $Zone -Target $Target -Type $Type)

    if ($result.Count -eq 0) {return  $false} 
    else {
        if ($result.Target -ne $Target) { return $false }
    }
    return $true
}


Export-ModuleMember -Function *-TargetResource

