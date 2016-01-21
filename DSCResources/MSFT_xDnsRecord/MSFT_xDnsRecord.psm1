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
        [ValidateSet("ARecord", "CName")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose "Looking up DNS record for $Name in $Zone"
    $record = Get-DnsServerResourceRecord -ZoneName $Zone -Name $Name -ErrorAction SilentlyContinue
    
    if ($record -eq $null) 
    {
        return @{
            Name = $Name.HostName;
            Zone = $Zone;
            Target = $Target;
            Ensure = 'Absent';
        }
    }
    if ($Type -eq "CName") 
    {
        $Recorddata = ($record.RecordData.hostnamealias).TrimEnd('.')
    }
    if ($Type -eq "ARecord") 
    {
        $Recorddata = $record.RecordData.IPv4address.IPAddressToString
    }

    return @{
        Name = $record.HostName;
        Zone = $Zone;
        Target = $Recorddata;
        Ensure = 'Present'
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
        [ValidateSet("ARecord", "CName")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $DNSParameters = @{Name=$Name; ZoneName=$Zone} 

    if ($Ensure -eq 'Present') {
        if ($Type -eq "ARecord")
        {
            $DNSParameters.Add('A',$true)
            $DNSParameters.Add('IPv4Address',$target)
        }
        if ($Type -eq "CName")
        {
            $DNSParameters.Add('CName',$true)
            $DNSParameters.Add('HostNameAlias',$Target)
        }
    Write-Verbose "Creating $Type for DNS $Target in $Zone"
    Add-DnsServerResourceRecord @DNSParameters
    }

    elseif ($Ensure -eq 'Absent') {
        
        $DNSParameters.Add('Computername','localhost')
        $DNSParameters.Add('Force',$true)

        if ($Type -eq "ARecord")
        {
            $DNSParameters.Add('RRType','A')
        }
        if ($Type -eq "CName")
        {
            $DNSParameters.Add('RRType','CName')
        }
    Write-Verbose "Removing $Type for DNS $Target in $Zone"
    Remove-DnsServerResourceRecord @DNSParameters
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
        [ValidateSet("ARecord", "CName")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose "Testing for DNS $Name in $Zone"
    $result = @(Get-TargetResource @PSBoundParameters)
    if ($Ensure -ne $result.Ensure) { return $false }
    elseif ($Ensure -eq 'Present' -and ($result.Target -ne $Target)) { return $false }
    return $true
}


Export-ModuleMember -Function *-TargetResource

