function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance,

        [Parameter()]
        [string[]]
        $IPAddresses
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
        [string]
        $IsSingleInstance,

        [Parameter()]
        [string[]]
        $IPAddresses
    )
    if (!$IPAddresses)
    {
        $IPAddresses = @()
    }
    Write-Verbose -Message 'Setting DNS forwarders.'
    $setParams = @{
        Namespace = 'root\MicrosoftDNS'
        Query = 'select * from microsoftdns_server'
        Property = @{Forwarders = $IPAddresses}
    }
    Set-CimInstance @setParams
}

function Test-TargetResource
{
    [OutputType([Bool])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance,

        [Parameter()]
        [string[]]
        $IPAddresses
    )
    Write-Verbose -Message 'Validate IP addresses.'
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
