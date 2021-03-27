$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceName = 'DSC_DnsServerForwarder'

function Invoke-TestSetup
{
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
        -TestType 'Unit'

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        $forwarders = '192.168.0.1', '192.168.0.2'
        $UseRootHint = $true

        $testParams = @{
            IsSingleInstance = 'Yes'
            IPAddresses      = $forwarders
            UseRootHint      = $UseRootHint
            Verbose          = $true
        }

        $testParamLimited = @{
            IsSingleInstance = 'Yes'
            IPAddresses      = $forwarders
            Verbose          = $true
        }

        $fakeDNSForwarder = @{
            IPAddress        = $forwarders
            UseRootHint      = $UseRootHint
            TimeOut          = 10
            EnableReordering = $true
        }

        $fakeUseRootHint = @{
            IPAddress   = $forwarders
            UseRootHint = -not $UseRootHint
        }

        Describe 'DSC_DnsServerForwarder\Get-TargetResource' {
            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return $fakeDNSForwarder }

                $targetResource = Get-TargetResource -IsSingleInstance $testParams.IsSingleInstance

                $targetResource | Should -BeOfType [System.Collections.Hashtable]
            }

            It "Returns the correct values when forwarders exist" {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return $fakeDNSForwarder
                }

                $targetResource = Get-TargetResource -IsSingleInstance $testParams.IsSingleInstance

                $targetResource.IPAddresses | Should -Be $testParams.IPAddresses
                $targetResource.UseRootHint | Should -Be $testParams.UseRootHint
                $targetResource.TimeOut | Should -Be 10
                $targetResource.EnableReordering | Should -BeTrue
            }

            It "Returns expected values when forwarders don't exist" {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        IPAddress        = @()
                        UseRootHint      = $true
                        Timeout          = 4
                        EnableReordering = $false
                    }
                }

                $targetResource = Get-TargetResource -IsSingleInstance $testParams.IsSingleInstance

                $targetResource.IPAddresses | Should -BeNullOrEmpty
                $targetResource.UseRootHint | Should -BeTrue
                $targetResource.Timeout | Should -Be 4
                $targetResource.EnableReordering | Should -BeFalse
            }
        }
        #endregion

        Describe 'DSC_DnsServerForwarder\Test-TargetResource' {
            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return $fakeDNSForwarder
                }

                $targetResource = Test-TargetResource @testParams

                $targetResource | Should -BeOfType [System.Boolean]
            }

            It 'Passes when forwarders match' {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return $fakeDNSForwarder
                }

                Test-TargetResource @testParams | Should -BeTrue
            }

            It 'Passes when forwarders match but root hint do not and are not specified' {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return $fakeUseRootHint
                }

                Test-TargetResource @testParamLimited | Should -BeTrue
            }

            It "Should return $true when EnableReordering don't match" {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        EnableReordering = $true
                    }
                }

                $result = Test-TargetResource -IsSingleInstance 'Yes' -EnableReordering $true

                $result | Should -BeTrue
            }

            It "Should return $true when Timeout don't match" {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        Timeout = 4
                    }
                }

                $result = Test-TargetResource -IsSingleInstance 'Yes' -Timeout 4

                $result | Should -BeTrue
            }

            It "Fails when forwarders don't match" {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        IPAddress   = @()
                        UseRootHint = $true
                    }
                }

                Test-TargetResource @testParams | Should -BeFalse
            }

            It "Fails when UseRootHint don't match" {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        IPAddress = $fakeDNSForwarder.IpAddress
                        UseRootHint = $false
                    }
                }

                Test-TargetResource @testParams | Should -BeFalse
            }

            It "Should return $false when EnableReordering don't match" {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        EnableReordering = $false
                    }
                }

                $result = Test-TargetResource -IsSingleInstance 'Yes' -EnableReordering $true

                $result | Should -BeFalse
            }

            It "Should return $false when Timeout don't match" {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        Timeout = 10
                    }
                }

                $result = Test-TargetResource -IsSingleInstance 'Yes' -Timeout 4

                $result | Should -BeFalse
            }
        }

        Describe 'DSC_DnsServerForwarder\Set-TargetResource' {
            It "Calls Set-DnsServerForwarder once" {
                Mock -CommandName Set-DnsServerForwarder -MockWith { }
                Set-TargetResource @testParams
                Assert-MockCalled -CommandName Set-DnsServerForwarder -Times 1 -Exactly -Scope It
            }

            Context 'When removing all forwarders' {
                It "Should call the correct mocks" {
                    Mock -CommandName Set-DnsServerForwarder
                    Mock -CommandName Remove-DnsServerForwarder
                    Mock -CommandName Get-DnsServerForwarder -MockWith {
                        return New-CimInstance -ClassName 'DnsServerForwarder' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                            IPAddress = @('1.1.1.1')
                        }
                    }

                    Set-TargetResource -IsSingleInstance 'Yes' -IPAddresses @()

                    Assert-MockCalled -CommandName Set-DnsServerForwarder -Times 0 -Exactly -Scope It
                    Assert-MockCalled -CommandName Get-DnsServerForwarder -Times 1 -Exactly -Scope It
                    Assert-MockCalled -CommandName Remove-DnsServerForwarder -Times 1 -Exactly -Scope It
                }
            }

            Context 'When enforcing just parameter UseRootHint' {
                It "Should call the correct mock with correct parameters" {
                    Mock -CommandName Set-DnsServerForwarder

                    Set-TargetResource -IsSingleInstance 'Yes' -UseRootHint $true

                    Assert-MockCalled -CommandName Set-DnsServerForwarder -ParameterFilter {
                        # Only the property UseRootHint should exist in $PSBoundParameters.
                        -not $PSBoundParameters.ContainsKey('IPAddress') -and $UseRootHint -eq $true
                    } -Times 1 -Exactly -Scope It
                }
            }

            Context 'When enforcing just parameter EnableReordering' {
                It "Should call the correct mock with correct parameters" {
                    Mock -CommandName Set-DnsServerForwarder

                    Set-TargetResource -IsSingleInstance 'Yes' -EnableReordering $true

                    Assert-MockCalled -CommandName Set-DnsServerForwarder -ParameterFilter {
                        # Only the property UseRootHint should exist in $PSBoundParameters.
                        -not $PSBoundParameters.ContainsKey('IPAddress') -and $EnableReordering -eq $true
                    } -Times 1 -Exactly -Scope It
                }
            }

            Context 'When enforcing just parameter Timeout' {
                It "Should call the correct mock with correct parameters" {
                    Mock -CommandName Set-DnsServerForwarder

                    Set-TargetResource -IsSingleInstance 'Yes' -Timeout 4

                    Assert-MockCalled -CommandName Set-DnsServerForwarder -ParameterFilter {
                        # Only the property UseRootHint should exist in $PSBoundParameters.
                        -not $PSBoundParameters.ContainsKey('IPAddress') -and $Timeout -eq 4
                    } -Times 1 -Exactly -Scope It
                }
            }
        }
    } #end InModuleScope
}
finally
{
    Invoke-TestCleanup
}
