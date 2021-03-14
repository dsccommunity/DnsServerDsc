<#
    .SYNOPSIS
        Convert any object to hashtable

    .PARAMETER InputObject
       The object that should convert to hashtable.
#>
function ConvertTo-HashtableFromObject
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject]
        $InputObject
    )

    $hashResult = @{}

    $InputObject.psobject.Properties | Foreach-Object {
        $hashResult[$_.Name] = $_.Value
    }

    return $hashResult
}
