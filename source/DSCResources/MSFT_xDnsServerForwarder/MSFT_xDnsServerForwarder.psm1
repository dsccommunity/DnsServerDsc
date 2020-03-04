$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance
    )
    Write-Verbose -Message $script:localizedData.GettingDnsForwardersMessage
    $CurrentServerForwarders = Get-DnsServerForwarder
    [array]$currentIPs = $CurrentServerForwarders.IPAddress
    $CurrentUseRootHint = $CurrentServerForwarders.UseRootHint
    $targetResource =  @{
        IsSingleInstance = $IsSingleInstance
        IPAddresses = @()
        UseRootHint = $CurrentUseRootHint
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
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance,

        [Parameter()]
        [string[]]
        $IPAddresses,

        [Parameter()]
        [System.Boolean]
        $UseRootHint
    )
    if (!$IPAddresses)
    {
        $IPAddresses = @()
    }
    Write-Verbose -Message $script:localizedData.SettingDnsForwardersMessage
    $setParams = @{
        IPAddress = $IPAddresses
    }

    if ($PSBoundParameters.ContainsKey('UseRootHint'))
    {
        $setParams.Add('UseRootHint', $UseRootHint)
    }

    Set-DnsServerForwarder @setParams -WarningAction 'SilentlyContinue'
}

function Test-TargetResource
{
    [OutputType([Bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance,

        [Parameter()]
        [string[]]
        $IPAddresses,

        [Parameter()]
        [System.Boolean]
        $UseRootHint
    )

    Write-Verbose -Message $script:localizedData.ValidatingIPAddressesMessage
    $currentConfiguration = Get-TargetResource -IsSingleInstance $IsSingleInstance
    [array]$currentIPs = $currentConfiguration.IPAddresses
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
    if ($PSBoundParameters.ContainsKey('UseRootHint'))
    {
        if ($currentConfiguration.UseRootHint -ne $UseRootHint)
        {
            return $false
        }
    }

    return $true
}
