# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        RoleNotFound                         = Please ensure that the PowerShell module for role {0} is installed.
        FindingNetAdapterMessage             = Finding network adapters matching the parameters.
        AllNetAdaptersFoundMessage           = Found all network adapters because no filter parameters provided.
        NetAdapterFoundMessage               = {0} network adapters were found matching the parameters.
        NetAdapterNotFoundError              = A network adapter matching the parameters was not found. Please correct the properties and try again.
        InterfaceAliasNotFoundError          = A network adapter with the alias '{0}' could not be found.
        MultipleMatchingNetAdapterFound      = Please adjust the parameters or specify IgnoreMultipleMatchingAdapters to only use the first and try again.
        InvalidNetAdapterNumberError         = network adapter interface number {0} was specified but only {1} was found. Please correct the interface number and try again.
        GettingDNSServerStaticAddressMessage = Getting staticly assigned DNS server {0} address for interface alias '{1}'.
        DNSServerStaticAddressNotSetMessage  = Statically assigned DNS server {0} address for interface alias '{1}' is not set.
        DNSServerStaticAddressFoundMessage   = Statically assigned DNS server {0} address for interface alias '{1}' is '{2}'.
        InvalidValuesError                   = Property '{0}' in Test-DscParameterState must be either a Hashtable, CimInstance or CimIntance[]. Type detected was '{1}'.
        InvalidDesiredValuesError            = Property 'DesiredValuesValues' in Test-DscParameterState must be either a Hashtable, CimInstance or CimIntance[]. Type detected was '{0}'.
        InvalidCurrentValuesError            = Property 'CurrentValuesValues' in Test-DscParameterState must be either a Hashtable, CimInstance or CimIntance[]. Type detected was '{0}'.
        InvalidValuesToCheckError            = If 'DesiredValues' is a CimInstance then property 'ValuesToCheck' must contain a value.
        TestDscParameterCompareMessage       = Comparing values in property '{0}'.
        MatchPsCredentialUsernameMessage     = MATCH: PSCredential username match. Current state is '{0}' and desired state is '{1}'.
        NoMatchPsCredentialUsernameMessage   = NOTMATCH: PSCredential username mismatch. Current state is '{0}' and desired state is '{1}'.
        NoMatchTypeMismatchMessage           = NOTMATCH: Type mismatch for property '{0}' Current state type is '{1}' and desired type is '{2}'.
        MatchValueMessage                    = MATCH: Value (type '{0}') for property '{1}' does match. Current state is '{2}' and desired state is '{3}'.
        NoMatchValueMessage                  = NOTMATCH: Value (type '{0}') for property '{1}' does not match. Current state is '{2}' and desired state is '{3}'.
        NoMatchValueDifferentCountMessage    = NOTMATCH: Value (type '{0}') for property '{1}' does have a different count. Current state count is '{2}' and desired state count is '{3}'.
        NoMatchElementTypeMismatchMessage    = NOTMATCH: Type mismatch for property '{0}' Current state type of element [{1}] is '{2}' and desired type is '{3}'.
        NoMatchElementValueMismatchMessage   = NOTMATCH: Value [{0}] (type '{1}') for property '{2}' does match. Current state is '{3}' and desired state is '{4}'.
        MatchElementValueMessage             = MATCH: Value [{0}] (type '{1}') for property '{2}' does match. Current state is '{3}' and desired state is '{4}'.
        TestDscParameterResultMessage        = Test-DscParameter result is '{0}'.
        StartingReverseCheck                 = --------- Starting reverse check. Current state and desired state are inverted now. ---------
'@
}

# Internal function to throw terminating error with specified errroCategory, errorId and errorMessage
function New-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $errorId,

        [Parameter(Mandatory = $true)]
        [String]
        $errorMessage,

        [Parameter(Mandatory = $true)]
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
        [Parameter(Mandatory = $true)]
        [string]
        $Name
    )

    if (-not (Get-Module -Name $Name -ListAvailable))
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
        [Parameter(Mandatory = $true)]
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
        [Parameter(Mandatory = $true)]
        [System.Object]
        $CurrentValues,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $DesiredValues,

        [Parameter()]
        [System.String[]]
        $ValuesToCheck,

        [Parameter()]
        [switch]
        $TurnOffTypeChecking,

        [Parameter()]
        [switch]
        $ReverseCheck,

        [Parameter()]
        [switch]
        $SortArrayValues
    )

    $returnValue = $true

    if ($CurrentValues -is [Microsoft.Management.Infrastructure.CimInstance] -or $CurrentValues -is [Microsoft.Management.Infrastructure.CimInstance[]])
    {
        $CurrentValues = ConvertTo-HashTable -CimInstance $CurrentValues
    }

    if ($DesiredValues -is [Microsoft.Management.Infrastructure.CimInstance] -or $DesiredValues -is [Microsoft.Management.Infrastructure.CimInstance[]])
    {
        $DesiredValues = ConvertTo-HashTable -CimInstance $DesiredValues
    }

    $types = 'System.Management.Automation.PSBoundParametersDictionary', 'System.Collections.Hashtable', 'Microsoft.Management.Infrastructure.CimInstance'

    if ($DesiredValues.GetType().FullName -notin $types)
    {
        New-InvalidArgumentException `
            -Message ($script:localizedData.InvalidDesiredValuesError -f $DesiredValues.GetType().FullName) `
            -ArgumentName 'DesiredValues'
    }

    if ($CurrentValues.GetType().FullName -notin $types)
    {
        New-InvalidArgumentException `
            -Message ($script:localizedData.InvalidCurrentValuesError -f $CurrentValues.GetType().FullName) `
            -ArgumentName 'CurrentValues'
    }

    if ($DesiredValues -is [Microsoft.Management.Infrastructure.CimInstance] -and -not $ValuesToCheck)
    {
        New-InvalidArgumentException `
            -Message $script:localizedData.InvalidValuesToCheckError `
            -ArgumentName 'ValuesToCheck'
    }

    $desiredValuesClean = Remove-CommonParameter -Hashtable $DesiredValues

    if (-not $ValuesToCheck)
    {
        $keyList = $desiredValuesClean.Keys
    }
    else
    {
        $keyList = $ValuesToCheck
    }

    foreach ($key in $keyList)
    {
        $desiredValue = $desiredValuesClean.$key
        $currentValue = $CurrentValues.$key

        if ($desiredValue -is [Microsoft.Management.Infrastructure.CimInstance] -or $desiredValue -is [Microsoft.Management.Infrastructure.CimInstance[]])
        {
            $desiredValue = ConvertTo-HashTable -CimInstance $desiredValue
        }
        if ($currentValue -is [Microsoft.Management.Infrastructure.CimInstance] -or $currentValue -is [Microsoft.Management.Infrastructure.CimInstance[]])
        {
            $currentValue = ConvertTo-HashTable -CimInstance $currentValue
        }

        if ($null -ne $desiredValue)
        {
            $desiredType = $desiredValue.GetType()
        }
        else
        {
            $desiredType = [psobject] @{
                Name = 'Unknown'
            }
        }

        if ($null -ne $currentValue)
        {
            $currentType = $currentValue.GetType()
        }
        else
        {
            $currentType = [psobject] @{
                Name = 'Unknown'
            }
        }

        if ($currentType.Name -ne 'Unknown' -and $desiredType.Name -eq 'PSCredential')
        {
            # This is a credential object. Compare only the user name
            if ($currentType.Name -eq 'PSCredential' -and $currentValue.UserName -eq $desiredValue.UserName)
            {
                Write-Verbose -Message ($script:localizedData.MatchPsCredentialUsernameMessage -f $currentValue.UserName, $desiredValue.UserName)
                continue
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.NoMatchPsCredentialUsernameMessage -f $currentValue.UserName, $desiredValue.UserName)
                $returnValue = $false
            }

            # Assume the string is our username when the matching desired value is actually a credential
            if ($currentType.Name -eq 'string' -and $currentValue -eq $desiredValue.UserName)
            {
                Write-Verbose -Message ($script:localizedData.MatchPsCredentialUsernameMessage -f $currentValue, $desiredValue.UserName)
                continue
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.NoMatchPsCredentialUsernameMessage -f $currentValue, $desiredValue.UserName)
                $returnValue = $false
            }
        }

        if (-not $TurnOffTypeChecking)
        {
            if (($desiredType.Name -ne 'Unknown' -and $currentType.Name -ne 'Unknown') -and
                $desiredType.FullName -ne $currentType.FullName)
            {
                Write-Verbose -Message ($script:localizedData.NoMatchTypeMismatchMessage -f $key, $currentType.Name, $desiredType.Name)
                $returnValue = $false
                continue
            }
        }

        if ($currentValue -eq $desiredValue -and -not $desiredType.IsArray)
        {
            Write-Verbose -Message ($script:localizedData.MatchValueMessage -f $desiredType.Name, $key, $currentValue, $desiredValue)
            continue
        }

        if ($desiredValuesClean.GetType().Name -in 'HashTable', 'PSBoundParametersDictionary')
        {
            $checkDesiredValue = $desiredValuesClean.ContainsKey($key)
        }
        else
        {
            $checkDesiredValue = Test-DscObjectHasProperty -Object $desiredValuesClean -PropertyName $key
        }

        if (-not $checkDesiredValue)
        {
            Write-Verbose -Message ($script:localizedData.MatchValueMessage -f $desiredType.Name, $key, $currentValue, $desiredValue)
            continue
        }

        if ($desiredType.IsArray)
        {
            Write-Verbose -Message ($script:localizedData.TestDscParameterCompareMessage -f $key)

            if (-not $currentValue)
            {
                Write-Verbose -Message ($script:localizedData.NoMatchValueMessage -f $desiredType.Name, $key, $currentValue, $desiredValue)
                $returnValue = $false
                continue
            }
            elseif ($currentValue.Count -ne $desiredValue.Count)
            {
                Write-Verbose -Message ($script:localizedData.NoMatchValueDifferentCountMessage -f $desiredType.Name, $key, $currentValue.Count, $desiredValue.Count)
                $returnValue = $false
                continue
            }
            else
            {
                $desiredArrayValues = $desiredValue
                $currentArrayValues = $currentValue

                if ($SortArrayValues)
                {
                    $desiredArrayValues = $desiredArrayValues | Sort-Object
                    $currentArrayValues = $currentArrayValues | Sort-Object
                }

                for ($i = 0; $i -lt $desiredArrayValues.Count; $i++)
                {
                    if ($null -ne $desiredArrayValues[$i])
                    {
                        $desiredType = $desiredArrayValues[$i].GetType()
                    }
                    else
                    {
                        $desiredType = [psobject]@{
                            Name = 'Unknown'
                        }
                    }

                    if ($null -ne $currentArrayValues[$i])
                    {
                        $currentType = $currentArrayValues[$i].GetType()
                    }
                    else
                    {
                        $currentType = [psobject]@{
                            Name = 'Unknown'
                        }
                    }

                    if (-not $TurnOffTypeChecking)
                    {
                        if (($desiredType.Name -ne 'Unknown' -and $currentType.Name -ne 'Unknown') -and
                            $desiredType.FullName -ne $currentType.FullName)
                        {
                            Write-Verbose -Message ($script:localizedData.NoMatchElementTypeMismatchMessage -f $key, $i, $currentType.Name, $desiredType.Name)
                            $returnValue = $false
                            continue
                        }
                    }

                    if ($desiredArrayValues[$i] -ne $currentArrayValues[$i])
                    {
                        Write-Verbose -Message ($script:localizedData.NoMatchElementValueMismatchMessage -f $i, $desiredType.Name, $key, $currentArrayValues[$i], $desiredArrayValues[$i])
                        $returnValue = $false
                        continue
                    }
                    else
                    {
                        Write-Verbose -Message ($script:localizedData.MatchElementValueMessage -f $i, $desiredType.Name, $key, $currentArrayValues[$i], $desiredArrayValues[$i])
                        continue
                    }
                }

            }
        }
        elseif ($desiredType -eq [hashtable] -and $currentType -eq [hashtable])
        {
            $param = $PSBoundParameters
            $param.CurrentValues = $currentValue
            $param.DesiredValues = $desiredValue
            [void]$param.Remove('ValuesToCheck')
            if ($returnValue)
            {
                $returnValue = Test-DscParameterState @param
            }
            else
            {
                Test-DscParameterState @param | Out-Null
            }
            continue
        }
        else
        {
            if ($desiredValue -ne $currentValue)
            {
                Write-Verbose -Message ($script:localizedData.NoMatchValueMessage -f $desiredType.Name, $key, $currentValue, $desiredValue)
                $returnValue = $false
            }
        }
    }

    if ($ReverseCheck)
    {
        Write-Verbose -Message $script:localizedData.StartingReverseCheck
        $param = $PSBoundParameters
        $param.CurrentValues = $DesiredValues
        $param.DesiredValues = $CurrentValues
        [void]$param.Remove('ReverseCheck')
        if ($returnValue)
        {
            $returnValue = Test-DscParameterState @param
        }
        else
        {
            Test-DscParameterState @param | Out-Null
        }
    }

    Write-Verbose -Message ($script:localizedData.TestDscParameterResultMessage -f $returnValue)
    return $returnValue
}

function Test-DSCObjectHasProperty
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$Object,

        [Parameter(Mandatory = $true)]
        [string]$PropertyName
    )

    if ($Object.PSObject.Properties.Name -contains $PropertyName)
    {
        return $true
    }

    return $false
}

function ConvertTo-CimInstance
{
    param(
        [Parameter(Mandatory)]
        [hashtable]$Hashtable
    )

    [CimInstance[]]$result = foreach ($item in $Hashtable.GetEnumerator())
    {
        New-CimInstance -ClassName MSFT_KeyValuePair -Namespace root/microsoft/Windows/DesiredStateConfiguration -Property @{
            Key   = $item.Key
            Value = if ($item.Value -is [array])
            {
                $item.Value -join ','
            }
            else
            {
                $item.Value
            }
        } -ClientOnly
    }

    $result
}

function ConvertTo-HashTable
{
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [CimInstance[]]$CimInstance
    )

    $result = @{ }
    foreach ($ci in $CimInstance)
    {
        $result.Add($ci.Key, $ci.Value)
    }
    $result
}

function Convert-RootHintsToHashtable
{
    param (
        [object[]]$RootHints
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

    $r
}
