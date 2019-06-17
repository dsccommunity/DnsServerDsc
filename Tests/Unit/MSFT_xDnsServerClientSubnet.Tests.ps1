$script:DSCModuleName = 'xDnsServer'
$script:DSCResourceName = 'MSFT_xDnsServerClientSubnet'

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $script:DSCResourceName {
        #region Pester Test Initialization
        $dnsServerClientsSubnetToTest = @(
            @{
                TestParameters = @{
                    Name       = 'ClientSubnetA'
                    IPv4Subnet = '10.1.1.0/24'
                    Ensure     = 'Present'
                }
                MockRecord     = [PSCustomObject]@{
                    Name       = 'ClientSubnetA'
                    IPv4Subnet = '10.1.1.0/24'
                    IPv6Subnet = $null
                }
            }
            @{
                TestParameters = @{
                    Name       = 'ClientSubnetB'
                    IPv6Subnet = '0db8::1/28'
                    Ensure     = 'Present'
                }
                MockRecord     = [PSCustomObject]@{
                    Name       = 'ClientSubnetB'
                    IPv4Subnet = $null
                    IPv6Subnet = '0db8::1/28'
                }
            }
            @{
                TestParameters = @{
                    Name       = 'ClientSubnetC'
                    IPv4Subnet = '10.1.1.0/24, 10.0.0.0/24'
                    Ensure     = 'Present'
                }
                MockRecord     = [PSCustomObject]@{
                    Name       = 'ClientSubnetC'
                    IPv4Subnet = '10.1.1.0/24, 10.0.0.0/24'
                    IPv6Subnet = $null
                }
            }
        )
        #endregion

        #region Function Get-TargetResource
        Describe "MSFT_xDnsServerClientSubnet\Get-TargetResource" {
            Context "When managing a DNS Server Client Subnet" {
                It "Should return Ensure is Present when subnet exists" -TestCases $dnsServerClientsSubnetToTest {
                    $MockRecord = $dnsServerClientsSubnetToTest.MockRecord
                    $TestParameters = $dnsServerClientsSubnetToTest.TestParameters
                    Mock -CommandName Get-DnsServerClientSubnet -MockWith { return $MockRecord }
                    (Get-TargetResource @TestParameters).Ensure | Should Be 'Present'
                }

                It "Should return Ensure is Absent when Subnet does not exist" -TestCases $dnsServerClientsSubnetToTest {
                    $TestParameters = $dnsServerClientsSubnetToTest.TestParameters
                    Mock -CommandName Get-DnsServerClientSubnet -MockWith { return $null }
                    (Get-TargetResource @TestParameters).Ensure | Should Be 'Absent'
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "MSFT_xDnsServerClientSubnet\Test-TargetResource" {
            Context "When managing DNS Server Client subets" {
                It "Should fail when no DNS Server Client Subnet exists and Ensure is Absent" -TestCases $dnsServerClientsSubnetToTest {
                    Param ($TestParameters)
                    $absentParameters = $TestParameters.Clone()
                    $absentParameters['Ensure'] = 'Absent'
                    Mock -CommandName Get-TargetResource -MockWith { return $absentParameters }
                    Test-TargetResource @TestParameters | Should Be $false
                }

                It "Should fail when a Client Subnet exists, target does not match and Ensure is Present" -TestCases $dnsServerClientsSubnetToTest {
                    Param ($TestParameters)
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            Name       = $TestParameters.Name
                            IPv4Subnet = '172.16.1.0/24, 172.17.0.0/24'
                            IPv6Subnet = $null
                            Ensure     = $TestParameters.Ensure
                        }
                    }
                    Test-TargetResource @TestParameters | Should Be $false
                }

                It "Should fail when a Subnet exists and Ensure is Absent" -TestCases $dnsServerClientsSubnetToTest {
                    Param ($TestParameters)
                    $absentParameters = $TestParameters.Clone()
                    $absentParameters['Ensure'] = 'Absent'
                    Mock -CommandName Get-TargetResource -MockWith { return $TestParameters }
                    Test-TargetResource @absentParameters | Should Be $false
                }

                It "Should pass when Client Subnet exists, target matches and Ensure is Present" -TestCases $dnsServerClientsSubnetToTest {
                    Param ($TestParameters)
                    Mock -CommandName Get-TargetResource -MockWith { return $TestParameters }
                    Test-TargetResource @TestParameters | Should Be $true
                }

                It "Should pass when Client Subnet does not exist and Ensure is Absent" -TestCases $dnsServerClientsSubnetToTest {
                    Param ($TestParameters)
                    $absentParameters = $TestParameters.Clone()
                    $absentParameters['Ensure'] = 'Absent'
                    Mock -CommandName Get-TargetResource -MockWith { return $absentParameters }
                    Test-TargetResource @absentParameters | Should Be $true
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "MSFT_xDnsServerClientSubnet\Set-TargetResource" {
            Context "When managing DNS Server Client Subnets" {
                It "Calls Add-DnsServerClientSubnet in the set method when Ensure is Present and Subnet doesn't exist" -TestCases $dnsServerClientsSubnetToTest {
                    Param ($TestParameters)
                    Mock -CommandName Add-DnsServerClientSubnet
                    Mock -CommandName Get-DnsServerClientSubnet
                    Set-TargetResource @TestParameters
                    Assert-MockCalled Add-DnsServerClientSubnet -Scope It
                }

                It "Calls Remove-DnsServerClientSubnet in the set method when Ensure is Absent" -TestCases $dnsServerClientsSubnetToTest {
                    Param ($TestParameters)
                    $absentParameters = $TestParameters.Clone()
                    $absentParameters['Ensure'] = 'Absent'
                    Mock -CommandName Remove-DnsServerClientSubnet
                    Set-TargetResource @absentParameters
                    Assert-MockCalled Remove-DnsServerClientSubnet -Scope It
                }

                It "Calls Set-DnsServerClientSubnet in the set method when Ensure is Present and Subnets don't match" -TestCases $dnsServerClientsSubnetToTest {
                    Param ($TestParameters)
                    Mock -CommandName Set-DnsServerClientSubnet
                    Mock -CommandName Get-DnsServerClientSubnet -MockWith {
                        return @{
                            Name       = $TestParameters.Name
                            IPv4Subnet = '192.1.1.0/24'
                            IPv6Subnet = $null
                        }
                    }
                    Set-TargetResource @TestParameters
                    Assert-MockCalled Set-DnsServerClientSubnet -Scope It
                }
            }
        }
        #endregion
    } #end InModuleScope
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
