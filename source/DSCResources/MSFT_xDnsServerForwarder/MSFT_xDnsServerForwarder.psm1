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
        [System.String]
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
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [AllowEmptyCollection()]
        [string[]]
        $IPAddresses,

        [Parameter()]
        [System.Boolean]
        $UseRootHint
    )

    $setDnsServerForwarderParameters = @{}

    if ($PSBoundParameters.ContainsKey('IPAddresses'))
    {
        if ($IPAddresses.Count -eq 0)
        {
            Write-Verbose -Message $script:localizedData.DeletingDnsForwardersMessage

            Get-DnsServerForwarder | Remove-DnsServerForwarder -Force
        }
        else
        {
            Write-Verbose -Message $script:localizedData.SettingDnsForwardersMessage

            $setDnsServerForwarderParameters['IPAddress'] = $IPAddresses
        }
    }

    if ($PSBoundParameters.ContainsKey('UseRootHint'))
    {
        Write-Verbose -Message ($script:localizedData.SettingUseRootHintProperty -f $UseRootHint)

        $setDnsServerForwarderParameters['UseRootHint'] = $UseRootHint
    }

    # Only do set if there are any parameters values added to the hashtable.
    if ($setDnsServerForwarderParameters.Count -gt 0)
    {
        Set-DnsServerForwarder @setDnsServerForwarderParameters -WarningAction 'SilentlyContinue'
    }
}

function Test-TargetResource
{
    [OutputType([Bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [AllowEmptyCollection()]
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
