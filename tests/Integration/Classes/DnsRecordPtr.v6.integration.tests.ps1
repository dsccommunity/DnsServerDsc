$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceFriendlyName = 'DnsRecordPtr'
$script:dscResourceName = "$($script:dscResourceFriendlyName)"

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
    ResourceType = 'Class'
    TestType = 'Integration'
}
$script:testEnvironment = Initialize-TestEnvironment @initializationParams

# Using try/finally to always cleanup.
try
{
    #region Integration Tests
    $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).v6.config.ps1"
    . $configurationFile

    Describe "$($script:dscResourceName)_Integration (IPv6)" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }

        $configurationName = "$($script:dscResourceName)_CreateRecord_Config_v6"

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
                    $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Key properties
                $resourceCurrentState.ZoneName | Should -Be $shouldBeData.ZoneName
                $resourceCurrentState.ZoneScope | Should -Be $shouldBeData.ZoneScope
                $resourceCurrentState.IpAddress | Should -Be $shouldBeData.IpAddress
                $resourceCurrentState.Name | Should -Be $shouldBeData.Name

                # Optional properties were not specified, so we just need to ensure the value exists
                $resourceCurrentState.TimeToLive | Should -Not -Be $null

                # Defaulted properties
                $resourceCurrentState.DnsServer | Should -Be 'localhost'
                $resourceCurrentState.Ensure | Should -Be 'Present'
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_ModifyRecord_Config_v6"

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
                    $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Key properties
                $resourceCurrentState.ZoneName | Should -Be $shouldBeData.ZoneName
                $resourceCurrentState.ZoneScope | Should -Be $shouldBeData.ZoneScope
                $resourceCurrentState.IpAddress | Should -Be $shouldBeData.IpAddress
                $resourceCurrentState.Name | Should -Be $shouldBeData.Name

                # Optional properties
                $resourceCurrentState.TimeToLive | Should -Be $shouldBeData.TimeToLive

                # Defaulted properties
                $resourceCurrentState.DnsServer | Should -Be $shouldBeData.DnsServer
                $resourceCurrentState.Ensure | Should -Be $shouldBeData.Ensure
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_DeleteRecord_Config_v6"

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
                    $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Key properties
                $resourceCurrentState.ZoneName | Should -Be $shouldBeData.ZoneName
                $resourceCurrentState.ZoneScope | Should -Be $shouldBeData.ZoneScope
                $resourceCurrentState.IpAddress | Should -Be $shouldBeData.IpAddress
                $resourceCurrentState.Name | Should -Be $shouldBeData.Name

                # Optional properties
                if ($shouldBeData.TimeToLive)
                {
                    $resourceCurrentState.TimeToLive | Should -Be $shouldBeData.TimeToLive
                }

                # DnsServer is not specified in this test, so it defaults to 'localhost'
                $resourceCurrentState.DnsServer | Should -Be 'localhost'

                # Ensure will be Absent
                $resourceCurrentState.Ensure | Should -Be 'Absent'
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
}
