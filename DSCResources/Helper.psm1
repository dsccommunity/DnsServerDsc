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
        [String]
        $errorId,
        
        [Parameter(Mandatory)]
        [String]
        $errorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]
        $errorCategory
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
        [string]
        $Name
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

function Test-DscParameterState
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)] 
        [hashtable]
        $CurrentValues,

        [Parameter(Mandatory)] 
        [object]
        $DesiredValues,
        
        [string[]]
        $ValuesToCheck,
        
        [switch]$TurnOffTypeChecking
    )

    $returnValue = $true

    $types = 'System.Management.Automation.PSBoundParametersDictionary', 'System.Collections.Hashtable', 'Microsoft.Management.Infrastructure.CimInstance'
    
    if ($DesiredValues.GetType().FullName -notin $types)
    {
        throw ("Property 'DesiredValues' in Test-DscParameterState must be either a Hashtable or CimInstance. Type detected was $($DesiredValues.GetType().Name)")
    }

    if ($DesiredValues.GetType().FullName -eq 'Microsoft.Management.Infrastructure.CimInstance' -and -not $ValuesToCheck)
    {
        throw ("If 'DesiredValues' is a CimInstance then property 'ValuesToCheck' must contain a value")
    }
    
    $DesiredValuesClean = Remove-CommonParameter -Hashtable $DesiredValues

    if (-not $ValuesToCheck)
    {
        $keyList = $DesiredValuesClean.Keys
    } 
    else
    {
        $keyList = $ValuesToCheck
    }

    foreach ($key in $keyList)
    {
        if ($null -ne $DesiredValuesClean.$key)
        {
            $desiredType = $DesiredValuesClean.$key.GetType()
        }
        else
        {
            $desiredType = [psobject]@{ Name = 'Unknown' }
        }
        
        if ($null -ne $CurrentValues.$key)
        {
            $currentType = $CurrentValues.$key.GetType()
        }
        else
        {
            $currentType = [psobject]@{ Name = 'Unknown' }
        }
     
        if (-not $TurnOffTypeChecking)
        {   
            if (($desiredType.Name -ne 'Unknown' -and $currentType.Name -ne 'Unknown') -and
            $desiredType.FullName -ne $currentType.FullName)
            {
                Write-Verbose -Message "NOTMATCH: Type mismatch for property '$key' Current state type is '$($currentType.Name)' and desired type is '$($desiredType.Name)'"
                continue
            }
        }

        if ($CurrentValues.$key -eq $DesiredValuesClean.$key -and -not $desiredType.IsArray)
        {
            Write-Verbose -Message "MATCH: Value (type $($desiredType.Name)) for property '$key' does match. Current state is '$($CurrentValues.$key)' and desired state is '$($DesiredValuesClean.$key)'"
            continue
        }
                    
        if ($DesiredValuesClean.GetType().Name -in 'HashTable', 'PSBoundParametersDictionary')
        {
            $checkDesiredValue = $DesiredValuesClean.ContainsKey($key)
        } 
        else
        {
            $checkDesiredValue = Test-DSCObjectHasProperty -Object $DesiredValuesClean -PropertyName $key
        }
        
        if (-not $checkDesiredValue)
        {
            Write-Verbose -Message "MATCH: Value (type $($desiredType.Name)) for property '$key' does match. Current state is '$($CurrentValues.$key)' and desired state is '$($DesiredValuesClean.$key)'"
            continue
        }
        
        if ($desiredType.IsArray)
        {
            Write-Verbose "Comparing values in property '$key'"
            if (-not $CurrentValues.ContainsKey($key) -or -not $CurrentValues.$key)
            {
                Write-Verbose -Message "NOTMATCH: Value (type $($desiredType.Name)) for property '$key' does not match. Current state is '$($CurrentValues.$key)' and desired state is '$($DesiredValuesClean.$key)'"
                $returnValue = $false
                continue
            }
            elseif ($CurrentValues.$key.Count -ne $DesiredValues.$key.Count)
            {
                Write-Verbose -Message "NOTMATCH: Value (type $($desiredType.Name)) for property '$key' does have a different count. Current state count is '$($CurrentValues.$key.Count)' and desired state count is '$($DesiredValuesClean.$key.Count)'"
                $returnValue = $false
                continue
            }
            else
            {
                $desiredArrayValues = $DesiredValues.$key
                $currentArrayValues = $CurrentValues.$key

                for ($i = 0; $i -lt $desiredArrayValues.Count; $i++)
                {
                    if ($null -ne $desiredArrayValues[$i])
                    {
                        $desiredType = $desiredArrayValues[$i].GetType()
                    }
                    else
                    {
                        $desiredType = [psobject]@{ Name = 'Unknown' }
                    }
                    
                    if ($null -ne $currentArrayValues[$i])
                    {
                        $currentType = $currentArrayValues[$i].GetType()
                    }
                    else
                    {
                        $currentType = [psobject]@{ Name = 'Unknown' }
                    }
                    
                    if (-not $TurnOffTypeChecking)
                    {
                        if (($desiredType.Name -ne 'Unknown' -and $currentType.Name -ne 'Unknown') -and
                        $desiredType.FullName -ne $currentType.FullName)
                        {
                            Write-Verbose -Message "`tNOTMATCH: Type mismatch for property '$key' Current state type of element [$i] is '$($currentType.Name)' and desired type is '$($desiredType.Name)'"
                            $returnValue = $false
                            continue
                        }
                    }
                        
                    if ($desiredArrayValues[$i] -ne $currentArrayValues[$i])
                    {
                        Write-Verbose -Message "`tNOTMATCH: Value [$i] (type $($desiredType.Name)) for property '$key' does match. Current state is '$($currentArrayValues[$i])' and desired state is '$($desiredArrayValues[$i])'"
                        $returnValue = $false
                        continue
                    }
                    else
                    {
                        Write-Verbose -Message "`tMATCH: Value [$i] (type $($desiredType.Name)) for property '$key' does match. Current state is '$($currentArrayValues[$i])' and desired state is '$($desiredArrayValues[$i])'"
                        continue
                    }
                }
                
            }
        } 
        else {
            if ($DesiredValuesClean.$key -ne $CurrentValues.$key)
            {
                Write-Verbose -Message "NOTMATCH: Value (type $($desiredType.Name)) for property '$key' does not match. Current state is '$($CurrentValues.$key)' and desired state is '$($DesiredValuesClean.$key)'"
                $returnValue = $false
            }
        
        } 
    }
    
    Write-Verbose "Result is '$returnValue'"
    return $returnValue
}

function Test-DSCObjectHasProperty
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory)] 
        [object]$Object,

        [Parameter(Mandatory)]
        [string]$PropertyName
    )

    if ($Object.PSObject.Properties.Name -contains $PropertyName) 
    {
        return $true
    }
    
    return $false
}
