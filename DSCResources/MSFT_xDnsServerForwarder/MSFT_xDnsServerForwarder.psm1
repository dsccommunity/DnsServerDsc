function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]$IsSingleInstance,
        [string[]]$IPAddresses
    )
    Write-Verbose 'Getting current DNS forwarders.'
    [array]$currentIPs = (Get-CimInstance -Namespace root\MicrosoftDNS -ClassName microsoftdns_server).Forwarders
    $targetResource =  @{
        IsSingleInstance = $IsSingleInstance
        IPAddresses = @()
    }
    if ($currentIPs)
    {
        $targetResource.IPAddresses = $currentIPs
    }
    Write-Output $targetResource
}

function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]$IsSingleInstance,
        [string[]]$IPAddresses
    )
    Write-Verbose 'Setting DNS forwarders.'
    Set-CimInstance -Namespace root\MicrosoftDNS -Query 'select * from microsoftdns_server' -Property @{Forwarders = $IPAddresses}
}

function Test-TargetResource
{
    [OutputType([Bool])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]$IsSingleInstance,
        [string[]]$IPAddresses
    )
    [array]$currentIPs = (Get-TargetResource @PSBoundParameters).IPAddresses
    if ($currentIPs.Count -ne $IPAddresses.Count)
    {
        return $false
    }
    foreach ($ip in $IPAddresses)
    {
        if ($ip -notin $currentIPs)
        {
            return $false
        }
    }
    return $true
}
