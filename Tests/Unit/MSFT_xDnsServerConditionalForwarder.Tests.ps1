
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
                        MasterServers          = '1.1.1.1', '2.2.2.2'
                        ZoneType               = $Script:zoneType
                        IsDsIntegrated         = $Script:isDsIntegrated
                        ReplicationScope       = $Script:ReplicationScope
                        DirectoryPartitionName = 'CustomName'
                    }
                }
                Mock Remove-DnsServerZone
                Mock Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 }
                Mock Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 }
            }

            BeforeEach {
                $Script:zoneType = 'Forwarder'
                $Script:isDsIntegrated = $true
                $Script:ReplicationScope = 'Domain'

                $defaultParameters = @{
                    Ensure           = 'Present'
                    Name             = 'domain.name'
                    MasterServers    = '1.1.1.1', '2.2.2.2'
                    ReplicationScope = 'Domain'
                }
            }

            Context 'Get-TargetResource, zone is present' {
                BeforeEach {
                    $contextParameters = $defaultParameters.Clone()
                    $contextParameters.Remove('MasterServers')
                    $contextParameters.Remove('ReplicationScope')
                }

                It 'When the zone exists, and is AD integrated' {
                    $instance = Get-TargetResource @contextParameters

                    $instance.MasterServers -join ',' | Should -Be '1.1.1.1,2.2.2.2'
                    $instance.ZoneType | Should -Be 'Forwarder'
                    $instance.ReplicationScope | Should -Be 'Domain'
                }

                It 'When the zone exists, and is not AD integrated' {
                    $Script:isDsIntegrated = $false

                    $instance = Get-TargetResource @contextParameters

                    $instance.ReplicationScope | Should -Be 'None'
                }

                It 'When the zone exists, and is not a forwarder' {
                    $Script:ZoneType = 'Primary'

                    $instance = Get-TargetResource @contextParameters

                    $instance.ZoneType | Should -Be 'Primary'
                }
            }

            Context 'Get-TargetResource, zone is absent' {
                BeforeAll {
                    Mock Get-DnsServerZone
                }

                BeforeEach {
                    $contextParameters = $defaultParameters.Clone()
                    $contextParameters.Remove('MasterServers')
                    $contextParameters.Remove('ReplicationScope')
                }

                It 'When the zone does not exist, sets Ensure to Absent' {
                    $instance = Get-TargetResource @contextParameters

                    $instance.Ensure | Should -Be 'Absent'
                }
            }

            Context 'Set-TargetResource, zone is present' {
                It 'When Ensure is present, and a zone of a different type exists, removes and recreates the zone' {
                    $Script:zoneType = 'Stub'

                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
                }

                It 'When Ensure is present, requested replication scope is none, and a DsIntegrated zone exists, removes and recreates the zone' {
                    $Script:isDsIntegrated = $true

                    $defaultParameters.ReplicationScope = 'None'
                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
                }

                It 'When Ensure is present, requested zone storage is AD, and a file based zone exists, removes and recreates the zone' {
                    $Script:isDsIntegrated = $false

                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
                }

                It 'When Ensure is present, and master servers differs, updates list of master servers' {
                    $defaultParameters.MasterServers = '3.3.3.3', '4.4.4.4'

                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 1 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
                }

                It 'When Ensure is present, and the replication scope differs, attempts to move the zone' {
                    $defaultParameters.ReplicationScope = 'Forest'
                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 1 -Scope It
                }

                It 'When Ensure is present, the replication scope is custom, and the directory partition name differs, attempts to move the zone' {
                    $Script:ReplicationScope = 'Custom'

                    $defaultParameters.ReplicationScope = 'Custom'
                    $defaultParameters.DirectoryPartitionName = 'New'
                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                    Assert-MockCalled Remove-DnsServerZone -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 1 -Scope It
                }

                It 'When Ensure is absent, removes the zone' {
                    $defaultParameters.Ensure = 'Absent'
                    Set-TargetResource @defaultParameters

                    Assert-MockCalled Remove-DnsServerZone -Scope It
                    Assert-MockCalled Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
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
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                    Assert-MockCalled Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
                }
            }

            Context 'Test-TargetResource, zone is present' {
                It 'When Ensure is present, and the list of master servers matches, returns true' {
                    Test-TargetResource @defaultParameters | Should -Be $true
                }

                It 'When Ensure is present, and the list of master servers differs, returns false' {
                    $defaultParameters.MasterServers = '3.3.3.3', '4.4.4.4'

                    Test-TargetResource @defaultParameters | Should -Be $false
                }

                It 'When Ensure is present, and the ZoneType does not match, returns false' {
                    $Script:ZoneType = 'Primary'

                    Test-TargetResource @defaultParameters | Should -Be $false
                }

                It 'When Ensure is present, and the zone is AD Integrated, and ReplicationScope is None, returns false' {
                    $defaultParameters.ReplicationScope = 'None'

                    Test-TargetResource @defaultParameters | Should -Be $false
                }

                It 'When Ensure is present, and the zone is not AD integrated, and ReplicationScope is Domain, returns false' {
                    $Script:isDsIntegrated = $false

                    Test-TargetResource @defaultParameters | Should -Be $false
                }

                It 'When Ensure is present, and the replication scope differs, returns false' {
                    $defaultParameters.ReplicationScope = 'Forest'

                    Test-TargetResource @defaultParameters | Should -Be $false
                }

                It 'When Ensure is present, and ReplicationScope is Custom, and the DirectoryPartitionName does not match, returns false' {
                    $Script:ReplicationScope = 'Custom'

                    $defaultParameters.ReplicationScope = 'Custom'
                    $defaultParameters.DirectoryPartitionName = 'NewName'

                    Test-TargetResource @defaultParameters | Should -Be $false
                }

                It 'When Ensure is absent, returns false' {
                    $defaultParameters.Ensure = 'Absent'

                    Test-TargetResource @defaultParameters | Should -Be $false
                }

                It 'When Ensure is absent, and a zone of a different type exists, returns true' {
                    $Script:ZoneType = 'Primary'

                    $defaultParameters.Ensure = 'Absent'

                    Test-TargetResource @defaultParameters | Should -Be $true
                }
            }

            Context 'Test, zone is absent' {
                BeforeAll {
                    Mock Get-DnsServerZone
                }

                It 'When Ensure is present, returns false' {
                    Test-TargetResource @defaultParameters | Should -Be $false
                }

                It 'When Ensure is is absent, returns true' {
                    $defaultParameters.Ensure = 'Absent'

                    Test-TargetResource @defaultParameters | Should -Be $true
                }
            }

            Context 'Request validation' {
                It 'When Ensure is present, and MasterServers is not set, throws an error' {
                    $defaultParameters.Remove('MasterServers')

                    { Test-TargetResource @defaultParameters } | Should -Throw -ErrorId MasterServersIsMandatory
                }

                It 'When Ensure is absent, and MasterServers is not set, does not not throw an error' {
                    { Test-TargetResource @defaultParameters } | Should -Not -Throw
                }

                It 'When Ensure is present, and ReplicationScope is Custom, and DirectoryPartitionName is not set, throws an error' {
                    $defaultParameters.ReplicationScope = 'Custom'
                    $defaultParameters.DirectoryPartitionName = $null

                    { Test-TargetResource @defaultParameters } | Should -Throw -ErrorId DirectoryPartitionNameIsMandatory
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
