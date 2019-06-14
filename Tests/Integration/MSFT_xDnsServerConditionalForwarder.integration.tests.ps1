$script:dscModuleName = 'xDnsServer'
$script:dscResourceFriendlyName = 'xDnsServerConditionalForwarder'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

#region HEADER
# Integration Test Template Version: 1.3.3
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -TestType Integration
#endregion

#region INITIALIZATION
Install-WindowsFeature -Name DNS -IncludeAllSubFeature

# Add zones for the integration tests to fix
$conditionalForwarderZones = @(
    @{ Name = 'nochange.example';            MasterServers = '192.168.1.1', '192.168.1.2' }
    @{ Name = 'fixincorrectmasters.example'; MasterServers = '192.168.1.3', '192.168.1.4' }
    @{ Name = 'removeexisting.example';      MasterServers = '192.168.1.3', '192.168.1.4' }

)
foreach ($zone in $conditionalForwarderZones) {
    Add-DnsServerConditionalForwarderZone @zone
}

# Primary zones which will either be fixed or ignored.
$primaryZones = @(
    @{ Name = 'replaceprimary.example'; ZoneFile = 'replaceprimary.example.dns' }
    @{ Name = 'ignoreprimary.example';  ZoneFile = 'ignoreprimary.example.dns' }
)
foreach ($zone in $primaryZones) {
    Add-DnsServerPrimaryZone @zone
}
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

        $configurationName = "$($script:dscResourceName)_NoChange_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
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

                $NodeData = $ConfigurationData.AllNodes.Where{ $_.ConfigurationName -eq $configurationName }

                $resourceCurrentState.Ensure | Should -Be $NodeData.Ensure
                $resourceCurrentState.Name | Should -Be $NodeData.ZoneName
                $resourceCurrentState.MasterServers | Should -Be $NodeData.MasterServers
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_FixIncorrectMasters_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
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

                $NodeData = $ConfigurationData.AllNodes.Where{ $_.ConfigurationName -eq $configurationName }

                $resourceCurrentState.Ensure | Should -Be $NodeData.Ensure
                $resourceCurrentState.Name | Should -Be $NodeData.ZoneName
                $resourceCurrentState.MasterServers | Should -Be $NodeData.MasterServers
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_ReplacePrimary_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
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

                $NodeData = $ConfigurationData.AllNodes.Where{ $_.ConfigurationName -eq $configurationName }

                $resourceCurrentState.Ensure | Should -Be $NodeData.Ensure
                $resourceCurrentState.Name | Should -Be $NodeData.ZoneName
                $resourceCurrentState.MasterServers | Should -Be $NodeData.MasterServers
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_CreateNew_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
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

                $NodeData = $ConfigurationData.AllNodes.Where{ $_.ConfigurationName -eq $configurationName }

                $resourceCurrentState.Ensure | Should -Be $NodeData.Ensure
                $resourceCurrentState.Name | Should -Be $NodeData.ZoneName
                $resourceCurrentState.MasterServers | Should -Be $NodeData.MasterServers
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_RemoveExisting_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
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

                $NodeData = $ConfigurationData.AllNodes.Where{ $_.ConfigurationName -eq $configurationName }

                $resourceCurrentState.Ensure | Should -Be $NodeData.Ensure
                $resourceCurrentState.Name | Should -Be $NodeData.ZoneName
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_IgnorePrimary_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
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

                $NodeData = $ConfigurationData.AllNodes.Where{ $_.ConfigurationName -eq $configurationName }

                $resourceCurrentState.Ensure | Should -Be $NodeData.Ensure
                $resourceCurrentState.Name | Should -Be $NodeData.ZoneName
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        $configurationName = "$($script:dscResourceName)_DoNothing_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
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

                $NodeData = $ConfigurationData.AllNodes.Where{ $_.ConfigurationName -eq $configurationName }

                $resourceCurrentState.Ensure | Should -Be $NodeData.Ensure
                $resourceCurrentState.Name | Should -Be $NodeData.ZoneName
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
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    Get-DnsServerZone | Remove-DnsServerZone
}









try
{
    #region Integration Tests
    Describe "$($script:DSCResourceName)_Integration" {
        BeforeAll {
            $configFile = Join-Path -Path $psscriptroot -ChildPath "$DSCResourceName.config.ps1"
            . $configFile

            $dscParams = @{
                Path         = $testEnvironment.WorkingFolder
                ComputerName = 'localhost'
                Wait         = $true
                Verbose      = $true
                Force        = $true
            }
        }

        AfterEach {
            Get-DnsServerZone | Remove-DnsServerZone
        }

        Context 'Configuration' {
            It 'Should compile and apply the MOF without throwing' {
                {
                    & "${DSCResourceName}_Config" -OutputPath $testEnvironment.WorkingFolder
                    Start-DscConfiguration @dscParams
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
            }
        }

        Context 'present.example exists, and is a conditional forwarder' {
            It 'Does nothing when all settings match' {
                $setupParams = @{
                    Name          = 'present.example'
                    MasterServers = @('192.168.1.1', '192.168.1.2')
                }
                Add-DnsServerConditionalForwarderZone @setupParams

                Test-TargetResource @testParameters | Should -BeTrue

                Start-DscConfiguration @dscOarams

                $zone = Get-DnsZone -Name present.example -ErrorAction SilentlyContinue
                $zone | Should -Not -BeNullOrEmpty
                $zone.ZoneType | Should -Be 'Forwarder'
                $zone.MasterServers | Should -Be @('192.168.1.1', '192.168.1.2')

                Test-TargetResource @testParameters | Should -BeTrue
            }

            It 'Fixes master servers when different' {
                $setupParams = @{
                    Name          = 'absent.example'
                    MasterServers = @('192.168.1.4', '192.168.1.5')
                }
                Add-DnsServerConditionalForwarderZone @setupParams

                $zone = Get-DnsZone -Name present.example -ErrorAction SilentlyContinue
                $zone | Should -Not -BeNullOrEmpty
                $zone.ZoneType | Should -Be 'Forwarder'
                $zone.MasterServers | Should -Be @('192.168.1.4', '192.168.1.5')

                Test-TargetResource @testParameters | Should -BeFalse

                Start-DscConfiguration @dscOarams

                $zone = Get-DnsZone -Name present.example -ErrorAction SilentlyContinue
                $zone | Should -Not -BeNullOrEmpty
                $zone.ZoneType | Should -Be 'Forwarder'
                $zone.MasterServers | Should -Be @('192.168.1.1', '192.168.1.2')

                Test-TargetResource @testParameters | Should -BeTrue
            }
        }

        Context 'present.example exists, and is a primary zone' {
            It 'Removes and recreates present.example' {
                $setupParams = @{
                    Name     = 'present.example'
                    ZoneFile = 'present.example.dns'
                }
                Add-DnsServerPrimaryZone @setupParams

                $zone = Get-DnsZone -Name present.example -ErrorAction SilentlyContinue
                $zone | Should -Not -BeNullOrEmpty
                $zone.ZoneType | Should -Be 'Primary'

                Test-TargetResource @testParameters | Should -BeFalse

                Start-DscConfiguration @dscOarams

                $zone = Get-DnsZone -Name present.example -ErrorAction SilentlyContinue
                $zone | Should -Not -BeNullOrEmpty
                $zone.ZoneType | Should -Be 'Forwarder'
                $zone.MasterServers | Should -Be @('192.168.1.1', '192.168.1.2')

                Test-TargetResource @testParameters | Should -BeTrue
            }
        }

        Context 'present.example does not exist' {
            It 'Creates present.example' {
                Get-DnsZone -Name present.example -ErrorAction SilentlyContinue | Should -BeNullOrEmpty

                Test-TargetResource @testParameters | Should -BeFalse

                Start-DscConfiguration @dscParams

                $zone = Get-DnsZone -Name present.example
                $zone.ZoneType | Should -Be 'Forwarder'

                Test-TargetResource @testParameters | Should -BeTrue
            }
        }

        Context 'absent.example exists, and is a conditional forwarder' {
            It 'Removes absent.example' {
                $setupParams = @{
                    Name          = 'absent.example'
                    MasterServers = @('192.168.1.1', '192.168.1.2')
                }
                Add-DnsServerConditionalForwarderZone @setupParams

                Test-TargetResource @testParameters | Should -BeFalse

                Start-DscConfiguration @dscParams

                Get-DnsZone -Name absent.example -ErrorAction SilentlyContinue | Should -BeNullOrEmpty

                Test-TargetResource @testParameters | Should -BeTrue
            }
        }

        Context 'absent.example exists, and is a primary zone' {
            It 'Ignores the primary zone' {
                $setupParams = @{
                    Name     = 'absent.example'
                    ZoneFile = 'absent.example.dns'
                }
                Add-DnsServerPrimaryZone @setupParams

                Test-TargetResource @testParameters | Should -BeTrue

                Start-DscConfiguration @dscParams

                $zone = Get-DnsZone -Name absent.example -ErrorAction SilentlyContinue
                $zone | Should -Not -BeNullOrEmpty
                $zone.ZoneType | Should -Be 'Primary'

                Test-TargetResource @testParameters | Should -BeTrue
            }
        }

        Context 'absent.example does not exist' {
            It 'Does nothing' {
                Test-TargetResource @testParameters | Should -BeTrue

                Start-DscConfiguration @dscOarams

                Get-DnsZone -Name absent.example -ErrorAction SilentlyContinue | Should -BeNullOrEmpty

                Test-TargetResource @testParameters | Should -BeTrue
            }
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
