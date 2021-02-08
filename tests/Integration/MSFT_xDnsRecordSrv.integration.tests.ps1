$script:dscModuleName = 'xDnsServer'
$script:dscResourceFriendlyName = 'xDnsRecordSrv'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$initializationParams = @{
    DSCModuleName = $script:dscModuleName
    DSCResourceName = $script:dscResourceName
    ResourceType = 'Mof'
    TestType = 'Integration'
}
$script:testEnvironment = Initialize-TestEnvironment @initializationParams

#region INITIALIZATION

Add-DnsServerPrimaryZone -Name 'srv.test' -ZoneFile 'srv.test.dns'

#endregion

# Using try/finally to always cleanup.
try
{
    #region Integration Tests
    $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configurationFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }


        $configurationName = "$($script:dscResourceName)_CreateRecord_Config"

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
                        ComputerName = Get-ComputerName
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
                    $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Mandatory properties
                $resourceCurrentState.Zone | Should -Be $shouldBeData.Zone
                $resourceCurrentState.SymbolicName | Should -Be $shouldBeData.SymbolicName
                $resourceCurrentState.Protocol | Should -Be $shouldBeData.Protocol
                $resourceCurrentState.Port | Should -Be $shouldBeData.Port
                $resourceCurrentState.Target | Should -Be $shouldBeData.Target

                # Optional properties
                if ($shouldBeData.Priority)
                {
                    $resourceCurrentState.Priority | Should -Be $shouldBeData.Priority
                }
                else
                {
                    $resourceCurrentState.Priority | Should -Be 0
                }

                if ($shouldBeData.Weight)
                {
                    $resourceCurrentState.Weight | Should -Be $shouldBeData.Weight
                }
                else
                {
                    $resourceCurrentState.Weight | Should -Be 0
                }

                $resourceCurrentState.TTL | Should -Be $shouldBeData.TTL

                #Properties with default values
                $resourceCurrentState.DnsServer | Should -Be $shouldBeData.DnsServer
                $resourceCurrentState.Ensure | Should -Be $shouldBeData.Ensure
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }



        $configurationName = "$($script:dscResourceName)_ModifyRecord_Config"

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
                        ComputerName = Get-ComputerName
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
                    $_.ConfigurationName -eq $configurationName
                    -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Mandatory properties
                $resourceCurrentState.Zone | Should -Be $shouldBeData.Zone
                $resourceCurrentState.SymbolicName | Should -Be $shouldBeData.SymbolicName
                $resourceCurrentState.Protocol | Should -Be $shouldBeData.Protocol
                $resourceCurrentState.Port | Should -Be $shouldBeData.Port
                $resourceCurrentState.Target | Should -Be $shouldBeData.Target

                # Optional properties
                if ($shouldBeData.Priority)
                {
                    $resourceCurrentState.Priority | Should -Be $shouldBeData.Priority
                }
                else
                {
                    $resourceCurrentState.Priority | Should -Be 0
                }

                if ($shouldBeData.Weight)
                {
                    $resourceCurrentState.Weight | Should -Be $shouldBeData.Weight
                }
                else
                {
                    $resourceCurrentState.Weight | Should -Be 0
                }

                $resourceCurrentState.TTL | Should -Be $shouldBeData.TTL

                #Properties with default values
                $resourceCurrentState.DnsServer | Should -Be $shouldBeData.DnsServer
                $resourceCurrentState.Ensure | Should -Be $shouldBeData.Ensure
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }



        $configurationName = "$($script:dscResourceName)_DeleteRecord_Config"

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
                        ComputerName = Get-ComputerName
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
                    $_.ConfigurationName -eq $configurationName
                    -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Mandatory properties
                $resourceCurrentState.Zone | Should -Be $shouldBeData.Zone
                $resourceCurrentState.SymbolicName | Should -Be $shouldBeData.SymbolicName
                $resourceCurrentState.Protocol | Should -Be $shouldBeData.Protocol
                $resourceCurrentState.Port | Should -Be $shouldBeData.Port
                $resourceCurrentState.Target | Should -Be $shouldBeData.Target

                # Optional properties
                if ($shouldBeData.Priority)
                {
                    $resourceCurrentState.Priority | Should -Be $shouldBeData.Priority
                }
                else
                {
                    $resourceCurrentState.Priority | Should -Be 0
                }

                if ($shouldBeData.Weight)
                {
                    $resourceCurrentState.Weight | Should -Be $shouldBeData.Weight
                }
                else
                {
                    $resourceCurrentState.Weight | Should -Be 0
                }

                $resourceCurrentState.TTL | Should -Be $shouldBeData.TTL

                #Properties with default values
                $resourceCurrentState.DnsServer | Should -Be $shouldBeData.DnsServer
                $resourceCurrentState.Ensure | Should -Be $shouldBeData.Ensure
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

    }
    #endregion

}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    #region CLEANUP

    #endregion
}
