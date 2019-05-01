
$DSCModuleName   = 'xDnsServer'
$DSCResourceName = 'MSFT_xDnsServerConditionalForwarder'

#region HEADER
# Unit Test Template Version: 1.1.0
$moduleRoot = Resolve-Path (Join-Path $myinvocation.MyCommand.Path '..\..\..')
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git clone 'https://github.com/PowerShell/DscResource.Tests.git' (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests')
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$params = @{
    DSCModuleName   = $DSCModuleName
    DSCResourceName = $DSCResourceName
    TestType        = 'Integration'
}
$testEnvironment = Initialize-TestEnvironment @params
#endregion HEADER

try
{
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
}
finally
{
    Restore-TestEnvironment -TestEnvironment $testEnvironment
}
