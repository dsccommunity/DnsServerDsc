Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false

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

    $result = @{}
    $result.IsSingleInstance = $IsSingleInstance
    $result.IPAddress = Convert-RootHintsToHashtable -RootHints (Get-DnsServerRootHint)

    Write-Verbose "Found $($result.Count) root hints"
    $result
}

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
        $IPAddress
    )

    Write-Verbose -Message 'Removing all root hints.'
    Get-DnsServerRootHint | Remove-DnsServerRootHint -Force

    foreach ($item in $IPAddress)
    {
        Write-Verbose "Adding root hint '$($item.Key)'."
        Add-DnsServerRootHint -NameServer $item.Key -IPAddress  ($item.value -split ',' | ForEach-Object { $_.Trim() })
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

        [Parameter(Mandatory)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        [AllowEmptyCollection()]
        $IPAddress
    )

    Write-Verbose -Message 'Validating root hints.'
    $currentState = Get-TargetResource -IsSingleInstance Yes
    $desiredState = $PSBoundParameters

    foreach ($entry in $desiredState.IPAddress)
    {
        $entry.Value = $entry.Value -replace ' ',''
    }

    $result = Test-DscParameterState -CurrentValues $currentState -DesiredValues $desiredState -TurnOffTypeChecking

    $result
}
