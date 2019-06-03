Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false

<#

    .SYNOPSIS
        Get desired state

    .PARAMETER IsSingleInstance
        Key for the resource. This value must be set to 'Yes'

#>
function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance
    )

    Assert-Module -Name 'DNSServer'

    Write-Verbose 'Getting current root hints.'

    $result = @{ }
    $result.IsSingleInstance = $IsSingleInstance
    $result.NameServer = Convert-RootHintsToHashtable -RootHints (Get-DnsServerRootHint)

    Write-Verbose "Found $($result.Count) root hints"
    $result
}

<#

    .SYNOPSIS
        Set desired state

    .PARAMETER IsSingleInstance
        Key for the resource. This value must be set to 'Yes'

    .PARAMETER NameServer
        A list of names and IP addresses as a hashtable. This may look like this: NameServer = @{ 'rh1.vm.net.' = '20.1.1.1' }

#>
function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance,

        [Parameter(Mandatory)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        [AllowEmptyCollection()]
        $NameServer
    )

    Write-Verbose -Message 'Removing all root hints.'
    Get-DnsServerRootHint | Remove-DnsServerRootHint -Force

    foreach ($item in $NameServer)
    {
        Write-Verbose "Adding root hint '$($item.Key)'."
        Add-DnsServerRootHint -NameServer $item.Key -NameServer  ($item.value -split ',' | ForEach-Object { $_.Trim() })
    }
}

<#

    .SYNOPSIS
        Test desired state

    .PARAMETER IsSingleInstance
        Key for the resource. This value must be set to 'Yes'

    .PARAMETER NameServer
        A list of names and IP addresses as a hashtable. This may look like this: NameServer = @{ 'rh1.vm.net.' = '20.1.1.1' }

#>
function Test-TargetResource
{
    [OutputType([Bool])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Yes')]
        [string]
        $IsSingleInstance,

        [Parameter(Mandatory)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        [AllowEmptyCollection()]
        $NameServer
    )

    Write-Verbose -Message 'Validating root hints.'
    $currentState = Get-TargetResource -IsSingleInstance Yes
    $desiredState = $PSBoundParameters

    foreach ($entry in $desiredState.NameServer)
    {
        $entry.Value = $entry.Value -replace ' ', ''
    }

    $result = Test-DscParameterState -CurrentValues $currentState -DesiredValues $desiredState -TurnOffTypeChecking

    $result
}
