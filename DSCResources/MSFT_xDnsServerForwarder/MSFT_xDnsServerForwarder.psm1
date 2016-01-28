function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [string]$IPAddress,
        [bool]$RemoveAll = $false,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    Write-Verbose 'Getting DNS Forwarders'
    Write-Output @{Forwarders = (Get-CimInstance -Namespace root\MicrosoftDNS -ClassName microsoftdns_server).Forwarders}
}

function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [string]$IPAddress,
        [bool]$RemoveAll = $false,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    [array]$forwarders = (Get-TargetResource @PSBoundParameters).Forwarders
    if ($RemoveAll)
    {
        Write-Verbose 'Removing all DNS Forwarders'
        $forwarders = @()
    }
    elseif ($Ensure -eq "Present")
    {
        Write-Verbose 'Adding DNS Forwarder'
        $forwarders = $forwarders + $IPAddress
    }
    else
    {
        Write-Verbose 'Removing DNS Forwarder'
        $forwarders = $forwarders | where {$_ -ne $IPAddress}
    }
    Set-CimInstance -Namespace root\MicrosoftDNS -Query 'select * from microsoftdns_server' -Property @{Forwarders = $forwarders}
}

function Test-TargetResource
{
    [OutputType([Bool])]
    param
    (
        [Parameter(Mandatory)]
        [string]$IPAddress,
        [bool]$RemoveAll = $false,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    [array]$forwarders = (Get-TargetResource @PSBoundParameters).Forwarders
    if (($RemoveAll -and $forwarders -eq $null) -or ($Ensure -eq 'Present' -and $forwarders -contains $IPAddress) -or ($Ensure -eq 'Absent' -and !($forwarders -contains $IPAddress)))
    {
        $true
    }
    else
    {
        $false
    }
}
