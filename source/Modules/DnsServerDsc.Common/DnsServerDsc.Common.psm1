$script:resourceHelperModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'

Import-Module -Name $script:resourceHelperModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Converts a string to a fully qualified DNS domain name, if its not already.

    .DESCRIPTION
        This function is used to convert a string into a fully qualified DNS domain name by appending a '.' to the end.

    .PARAMETER Name
        A string with the value to convert.

    .OUTPUTS
        System.String
#>
function ConvertTo-FollowRfc1034
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]
        $Name
    )

    if (-not $Name.EndsWith('.'))
    {
        return "$Name."
    }

    return $Name
}

<#
    .SYNOPSIS
        Converts root hints like the DNS cmdlets are run.

    .DESCRIPTION
        This function is used to convert a CimInstance array containing MSFT_KeyValuePair objects into a hashtable.

    .PARAMETER CimInstance
        An array of CimInstances or a single CimInstance object to convert.

    .OUTPUTS
        System.Collections.Hashtable
#>
function Convert-RootHintsToHashtable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        [AllowEmptyCollection()]
        $RootHints
    )

    $r = @{ }

    foreach ($rootHint in $RootHints)
    {
        if (-not $rootHint.IPAddress)
        {
            continue
        }

        $ip = if ($rootHint.IPAddress.RecordData.IPv4Address)
        {
            $rootHint.IPAddress.RecordData.IPv4Address.IPAddressToString -join ','
        }
        else
        {
            $rootHint.IPAddress.RecordData.IPv6Address.IPAddressToString -join ','
        }

        $r.Add($rootHint.NameServer.RecordData.NameServer, $ip)
    }

    return $r
}
