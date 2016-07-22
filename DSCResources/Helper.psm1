# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
RoleNotFound = Please ensure that the PowerShell module for role {0} is installed
'@
}

# Internal function to throw terminating error with specified errroCategory, errorId and errorMessage
function New-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String]$errorId,
        
        [Parameter(Mandatory)]
        [String]$errorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]$errorCategory
    )
    
    $exception = New-Object System.InvalidOperationException $errorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    throw $errorRecord
}

# Internal function to assert if the role specific module is installed or not
function Assert-Module
{
    [CmdletBinding()]
    param
    (
        [string]$moduleName = 'DnsServer'
    )

    if(! (Get-Module -Name $moduleName -ListAvailable))
    {
        $errorMsg = $($LocalizedData.RoleNotFound) -f $moduleName
        New-TerminatingError -errorId 'ModuleNotFound' -errorMessage $errorMsg -errorCategory ObjectNotFound
    }
}

# Internal function to compare property values that are arrays
function Compare-Array
{
    [OutputType([System.Boolean])]
    [cmdletbinding()]
    param
    (
        [array]
        $ReferenceObject,

        [array]
        $DifferenceObject
    )

    $compare = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject

    if ($compare)
    {    
        return $false
    }
    else
    {    
        return $true
    }
}

#Internal function to remove all common parameters from $PSBoundParameters before it is passed to Set-CimInstance
function Remove-CommonParameter
{
    [OutputType([System.Collections.Hashtable])]
    [cmdletbinding()]
    param
    (
        [hashtable]
        $InputParameter
    )

    $inputClone = $InputParameter.Clone()
    $commonParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
    $commonParameters += [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    foreach ($parameter in $InputParameter.Keys)
    {
        foreach ($commonParameter in $commonParameters)
        {
            if ($parameter -eq $commonParameter)
            {
                $inputClone.Remove($parameter)
            }
        }
    }

    $inputClone
}
