$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceFriendlyName = 'DnsServerSetting'
$script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

try
{
    #region Integration Tests
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"

            # This will be used to set the settings back to the original values.
            $originalConfigurationData = @{
                AllNodes = @()
            }
        }

        $configurationName = "$($script:dscResourceName)_GetCurrentSettings_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should get the values of the current state without throwing' {
                {
                    $invokeDscResourceParameters = @{
                        Name        = $script:dscResourceFriendlyName
                        ModuleName  = $script:dscModuleName
                        Method      = 'Get'
                        Property    = @{
                            DnsServer = 'localhost'
                        }
                        ErrorAction = 'Stop'
                    }

                    $originalPropertyValues = Invoke-DscResource @invokeDscResourceParameters

                    Write-Verbose -Message ("Current state values:`r`n{0}" -f ($originalPropertyValues | Out-String)) -Verbose

                    $originalConfigurationData.AllNodes += @{
                        NodeName                  = 'localhost'
                        CertificateFile           = $env:DscPublicCertificatePath
                        DnsServer                 = 'localhost'

                        AddressAnswerLimit        = $originalPropertyValues.AddressAnswerLimit
                        AllowUpdate               = $originalPropertyValues.AllowUpdate
                        AutoCacheUpdate           = $originalPropertyValues.AutoCacheUpdate
                        AutoConfigFileZones       = $originalPropertyValues.AutoConfigFileZones
                        BindSecondaries           = $originalPropertyValues.BindSecondaries
                        BootMethod                = $originalPropertyValues.BootMethod
                        DisableAutoReverseZone    = $originalPropertyValues.DisableAutoReverseZone
                        EnableDirectoryPartitions = $originalPropertyValues.EnableDirectoryPartitions
                        EnableDnsSec              = $originalPropertyValues.EnableDnsSec
                        ForwardDelegations        = $originalPropertyValues.ForwardDelegations
                        ListeningIPAddress        = $originalPropertyValues.ListeningIPAddress
                        LocalNetPriority          = $originalPropertyValues.LocalNetPriority
                        LooseWildcarding          = $originalPropertyValues.LooseWildcarding
                        NameCheckFlag             = $originalPropertyValues.NameCheckFlag
                        RoundRobin                = $originalPropertyValues.RoundRobin
                        RpcProtocol               = $originalPropertyValues.RpcProtocol
                        SendPort                  = $originalPropertyValues.SendPort
                        StrictFileParsing         = $originalPropertyValues.StrictFileParsing
                        UpdateOptions             = $originalPropertyValues.UpdateOptions
                        WriteAuthorityNS          = $originalPropertyValues.WriteAuthorityNS
                        XfrConnectTimeout         = $originalPropertyValues.XfrConnectTimeout
                    }

                } | Should -Not -Throw
            }
        }

        Wait-ForIdleLcm -Clear

        $configurationName = "$($script:dscResourceName)_SetSettings_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.DnsServer                  | Should -Be $ConfigurationData.AllNodes.DnsServer
                $resourceCurrentState.AddressAnswerLimit         | Should -Be $ConfigurationData.AllNodes.AddressAnswerLimit
                $resourceCurrentState.AllowUpdate                | Should -Be $ConfigurationData.AllNodes.AllowUpdate
                $resourceCurrentState.AutoCacheUpdate            | Should -Be $ConfigurationData.AllNodes.AutoCacheUpdate
                $resourceCurrentState.AutoConfigFileZones        | Should -Be $ConfigurationData.AllNodes.AutoConfigFileZones
                $resourceCurrentState.BindSecondaries            | Should -Be $ConfigurationData.AllNodes.BindSecondaries
                $resourceCurrentState.BootMethod                 | Should -Be $ConfigurationData.AllNodes.BootMethod
                $resourceCurrentState.DisableAutoReverseZone     | Should -Be $ConfigurationData.AllNodes.DisableAutoReverseZone
                $resourceCurrentState.EnableDnsSec               | Should -Be $ConfigurationData.AllNodes.EnableDnsSec
                $resourceCurrentState.ForwardDelegations         | Should -Be $ConfigurationData.AllNodes.ForwardDelegations
                $resourceCurrentState.LocalNetPriority           | Should -Be $ConfigurationData.AllNodes.LocalNetPriority
                $resourceCurrentState.LooseWildcarding           | Should -Be $ConfigurationData.AllNodes.LooseWildcarding
                $resourceCurrentState.NameCheckFlag              | Should -Be $ConfigurationData.AllNodes.NameCheckFlag
                $resourceCurrentState.RoundRobin                 | Should -Be $ConfigurationData.AllNodes.RoundRobin
                $resourceCurrentState.RpcProtocol                | Should -Be $ConfigurationData.AllNodes.RpcProtocol
                $resourceCurrentState.SendPort                   | Should -Be $ConfigurationData.AllNodes.SendPort
                $resourceCurrentState.StrictFileParsing          | Should -Be $ConfigurationData.AllNodes.StrictFileParsing
                $resourceCurrentState.UpdateOptions              | Should -Be $ConfigurationData.AllNodes.UpdateOptions
                $resourceCurrentState.WriteAuthorityNS           | Should -Be $ConfigurationData.AllNodes.WriteAuthorityNS
                $resourceCurrentState.XfrConnectTimeout          | Should -Be $ConfigurationData.AllNodes.XfrConnectTimeout
                $resourceCurrentState.EnableDirectoryPartitions  | Should -Be $ConfigurationData.AllNodes.EnableDirectoryPartitions
                $resourceCurrentState.ListeningIPAddress         | Should -Be $ConfigurationData.AllNodes.ListeningIPAddress
            }

            It 'Should return ''True'' when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Wait-ForIdleLcm -Clear

        <#
            This is using the same configuration, but the configuration data is
            switch before running the configuration, to be able to revert back
            to the original values! NOTE: This must always be the
            last test for this resource!
        #>
        Context ('When using configuration {0} to revert to original values' -f $configurationName) {
            BeforeAll {
                # Switch to configuration data that holds the original values.
                $ConfigurationData = $originalConfigurationData
            }

            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.DnsServer                  | Should -Be $ConfigurationData.AllNodes.DnsServer
                $resourceCurrentState.AddressAnswerLimit         | Should -Be $ConfigurationData.AllNodes.AddressAnswerLimit
                $resourceCurrentState.AllowUpdate                | Should -Be $ConfigurationData.AllNodes.AllowUpdate
                $resourceCurrentState.AutoCacheUpdate            | Should -Be $ConfigurationData.AllNodes.AutoCacheUpdate
                $resourceCurrentState.AutoConfigFileZones        | Should -Be $ConfigurationData.AllNodes.AutoConfigFileZones
                $resourceCurrentState.BindSecondaries            | Should -Be $ConfigurationData.AllNodes.BindSecondaries
                $resourceCurrentState.BootMethod                 | Should -Be $ConfigurationData.AllNodes.BootMethod
                $resourceCurrentState.DisableAutoReverseZone     | Should -Be $ConfigurationData.AllNodes.DisableAutoReverseZone
                $resourceCurrentState.EnableDnsSec               | Should -Be $ConfigurationData.AllNodes.EnableDnsSec
                $resourceCurrentState.ForwardDelegations         | Should -Be $ConfigurationData.AllNodes.ForwardDelegations
                $resourceCurrentState.LocalNetPriority           | Should -Be $ConfigurationData.AllNodes.LocalNetPriority
                $resourceCurrentState.LooseWildcarding           | Should -Be $ConfigurationData.AllNodes.LooseWildcarding
                $resourceCurrentState.NameCheckFlag              | Should -Be $ConfigurationData.AllNodes.NameCheckFlag
                $resourceCurrentState.RoundRobin                 | Should -Be $ConfigurationData.AllNodes.RoundRobin
                $resourceCurrentState.RpcProtocol                | Should -Be $ConfigurationData.AllNodes.RpcProtocol
                $resourceCurrentState.SendPort                   | Should -Be $ConfigurationData.AllNodes.SendPort
                $resourceCurrentState.StrictFileParsing          | Should -Be $ConfigurationData.AllNodes.StrictFileParsing
                $resourceCurrentState.UpdateOptions              | Should -Be $ConfigurationData.AllNodes.UpdateOptions
                $resourceCurrentState.WriteAuthorityNS           | Should -Be $ConfigurationData.AllNodes.WriteAuthorityNS
                $resourceCurrentState.XfrConnectTimeout          | Should -Be $ConfigurationData.AllNodes.XfrConnectTimeout
                $resourceCurrentState.EnableDirectoryPartitions  | Should -Be $ConfigurationData.AllNodes.EnableDirectoryPartitions
                $resourceCurrentState.ListeningIPAddress         | Should -Be $ConfigurationData.AllNodes.ListeningIPAddress
            }

            It 'Should return ''True'' when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Wait-ForIdleLcm -Clear
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
