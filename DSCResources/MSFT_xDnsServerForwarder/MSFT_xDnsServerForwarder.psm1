function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance,
        [string[]]
        $IPAddresses
    )
    try
    {
        Write-Verbose -Message 'Getting current DNS forwarders.'
        $getParams = @{
            Namespace = 'root\MicrosoftDNS'
            ClassName = 'MicrosoftDNS_Server'
            ErrorAction = 'Stop'
        }
        [array]$currentIPs = Get-CimInstance @getParams
        $targetResource =  @{
            IsSingleInstance = $IsSingleInstance
            IPAddresses = @()
        }
        if ($currentIPs)
        {
            $targetResource.IPAddresses = $currentIPs.Forwarders
        }
        Write-Output $targetResource
    }
    catch
    {
        Write-Verbose -Message 'Failed to query DNS server.'
        $targetResource =  @{
            IsSingleInstance = $IsSingleInstance
            IPAddresses = @()
        }
        Write-Output $targetResource
    }
}

function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance,
        [string[]]
        $IPAddresses
    )
    if (-not $IPAddresses)
    {
        $IPAddresses = @()
    }
    try
    {
        Write-Verbose -Message 'Setting DNS forwarders.'
        $setParams = @{
            Namespace = 'root\MicrosoftDNS'
            Query = 'select * from microsoftdns_server'
            Property = @{Forwarders = $IPAddresses}
            ErrorAction = 'Stop'
        }
        Set-CimInstance @setParams
    }
    catch
    {
        Write-Verbose -Message 'Failed to set the DNS forwarders.'
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
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
        [string[]]
        $IPAddresses
    )
    Write-Verbose -Message 'Getting current resource state.'
    [array]$currentIPs = (Get-TargetResource @PSBoundParameters).IPAddresses
    Write-Verbose -Message 'Verifying the currnet state is correct.'
    if ($currentIPs.Count -ne $IPAddresses.Count)
    {
        Write-Verbose -Message 'The current state is incorrect.'
        return $false
    }
    foreach ($ip in $IPAddresses)
    {
        Write-Verbose -Message 'Checking the current forwarders.'
        if ($ip -notin $currentIPs)
        {
            Write-Verbose -Message 'The current state is incorrect.'
            return $false
        }
    }
    Write-Verbose -Message 'The current state is correct.'
    return $true
}
