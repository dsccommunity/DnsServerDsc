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
        [AllowEmptyCollection()]
        [string[]]
        $IPAddresses,

        [Parameter()]
        [System.Boolean]
        $UseRootHint
    )

    $setParams = @{}

    if ($IPAddresses.count -eq 0)
    {
        #Assume you want to remove all forwarders as none were provided
        Write-Verbose -Message $script:localizedData.DeletingDnsForwardersMessage
        Get-DnsServerForwarder | Remove-DnsServerForwarder -Force
    } else {
        $setParams.Add('IPAddress', $IPAddresses)
    }

    if ($PSBoundParameters.ContainsKey('UseRootHint'))
    {
        #You can set root hint flag only
        $setParams.Add('UseRootHint', $UseRootHint)
    }

    #If IPAddress present it must have valid IP Addresses. It cannot be null or and empty collection
    if ($setParams.count -gt 0){
        Write-Verbose -Message $script:localizedData.SettingDnsForwardersMessage
        Set-DnsServerForwarder @setParams -WarningAction 'SilentlyContinue'
    }

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
