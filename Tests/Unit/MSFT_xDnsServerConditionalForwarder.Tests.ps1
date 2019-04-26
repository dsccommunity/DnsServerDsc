
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
    TestType        = 'Unit'
}
$testEnvironment = Initialize-TestEnvironment @params
#endregion HEADER

# Begin Testing
try
{
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force

    InModuleScope 'MSFT_xDnsServerConditionalForwarder' {
        Describe 'MSFT_xDnsServerConditionalForwarder' {
            BeforeAll {
                Mock Add-DnsServerConditionalForwarderZone
                Mock Get-DnsServerZone {
                    [PSCustomObject]@{
                        MasterServers    = '1.1.1.1', '2.2.2.2'
                        ZoneType         = $Script:zoneType
                        IsDsIntegrated   = $Script:isDsIntegrated
                        ReplicationScope = 'Domain'
                    }
                }
                Mock Remove-DnsServerZone
                Mock Set-DnsServerConditionalForwarderZone
            }

            BeforeEach {
                $Script:zoneType = 'Forwarder'
                $Script:isDsIntegrated = $true

                $defaultParameters = @{
                    Ensure           = 'Present'
                    Name             = 'domain.name'
                    MasterServers    = '1.1.1.1', '2.2.2.2'
                    ReplicationScope = 'Domain'
                }
            }

            Context 'Get-TargetResource' {
                It 'When the zone exists, it fills properties' {
                    $instance = Get-TargetResource @defaultParameters

                    $instance.MasterServers -join ',' | Should -Be '1.1.1.1,2.2.2.2'
                    $instance.ZoneType | Should -Be 'Forwarder'
                    $instance.ReplicationScope | Should -Be 'Domain'
                }
            }

            Context 'Set-TargetResource, zone is present' {
                It 'When Ensure is present, and a zone of a different type exists, removes and recreates the zone' {
                    $Script:zoneType = 'Stub'

                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -Times 0 -Scope It
                }

                It 'When Ensure is present, requested replication scope is none, and a DsIntegrated zone exists, removes and recreates the zone' {
                    $Script:isDsIntegrated = $true

                    $defaultParameters.ReplicationScope = 'None'
                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -Times 0 -Scope It
                }

                It 'When Ensure is present, requested zone storage is AD, and a file based zone exists, removes and recreates the zone' {
                    $Script:isDsIntegrated = $false

                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -Times 0 -Scope It
                }

                It 'When Ensure is present, updates all properties' {
                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -Scope It
                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Times 0 -Scope It
                }

                It 'When Ensure is absent, removes the zone' {
                    $defaultParameters.Ensure = 'Absent'
                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Remove-DnsServerZone -Scope It
                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -Times 0 -Scope It
                }
            }

            Context 'Set-TargetResource, zone is absent' {
                BeforeAll {
                    Mock Get-DnsServerZone
                }

                It 'When Ensure is present, attempts to create the zone' {
                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -Times 0 -Scope It
                }
            }

            Context 'Test-TargetResource' {
                It 'When the zone is present, and the list of master servers matches, returns true' {
                    Test-TargetResource @defaultParameters | Should -Be $true
                }

                It 'When the zone is present, and the list of master servers differs, returns false' {
                    $defaultParameters.MasterServers = '3.3.3.3', '4.4.4.4'

                    Test-TargetResource @defaultParameters | Should -Be $false
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $testEnvironment
    #endregion
}
