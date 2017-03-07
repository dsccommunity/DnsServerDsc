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
        [string]$errorId,
        
        [Parameter(Mandatory)]
        [string]$errorMessage,

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
        [Parameter(Mandatory)]
        [string]$Name
    )

    if(-not (Get-Module -Name $Name -ListAvailable))
    {
        $errorMsg = $($LocalizedData.RoleNotFound) -f $Name
        New-TerminatingError -errorId 'ModuleNotFound' -errorMessage $errorMsg -errorCategory ObjectNotFound
    }
}

#Internal function to remove all common parameters from $PSBoundParameters before it is passed to Set-CimInstance
function Remove-CommonParameter
{
    [OutputType([hashtable])]
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]
        $Hashtable
    )

    $inputClone = $Hashtable.Clone()
    $commonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters
    $commonParameters += [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    $Hashtable.Keys | Where-Object { $_ -in $commonParameters } | ForEach-Object {
        $inputClone.Remove($_)
    }

    $inputClone
}
