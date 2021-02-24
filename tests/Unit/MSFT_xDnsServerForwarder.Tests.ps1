$script:dscModuleName = 'xDnsServer'
$script:dscResourceName = 'MSFT_xDnsServerForwarder'

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
        #region Pester Test Initialization
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
            IPAddress   = $forwarders
            UseRootHint = $UseRootHint
        }

        $fakeUseRootHint = @{
            IPAddress   = $forwarders
            UseRootHint = -not $UseRootHint
        }
        #endregion


        #region Function Get-TargetResource
        Describe 'MSFT_xDnsServerForwarder\Get-TargetResource' {
            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return $fakeDNSForwarder }
                $targetResource = Get-TargetResource -IsSingleInstance $testParams.IsSingleInstance
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It "Returns IPAddresses = $($testParams.IPAddresses) and UseRootHint = $($testParams.UseRootHint) when forwarders exist" {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return $fakeDNSForwarder }
                $targetResource = Get-TargetResource -IsSingleInstance $testParams.IsSingleInstance
                $targetResource.IPAddresses | Should Be $testParams.IPAddresses
                $targetResource.UseRootHint | Should Be $testParams.UseRootHint
            }

            It "Returns an empty IPAddresses and UseRootHint at True when forwarders don't exist" {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return @{IPAddress = @(); UseRootHint = $true } }
                $targetResource = Get-TargetResource -IsSingleInstance $testParams.IsSingleInstance
                $targetResource.IPAddresses | Should Be $null
                $targetResource.UseRootHint | Should Be $true
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe 'MSFT_xDnsServerForwarder\Test-TargetResource' {
            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return $fakeDNSForwarder }
                $targetResource = Test-TargetResource @testParams
                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Passes when forwarders match' {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return $fakeDNSForwarder }
                Test-TargetResource @testParams | Should Be $true
            }

            It 'Passes when forwarders match but root hint do not and are not specified' {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return $fakeUseRootHint }
                Test-TargetResource @testParamLimited | Should Be $true
            }

            It "Fails when forwarders don't match" {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return @{IPAddress = @(); UseRootHint = $true } }
                Test-TargetResource @testParams | Should Be $false
            }

            It "Fails when UseRootHint don't match" {
                Mock -CommandName Get-DnsServerForwarder -MockWith { return @{IPAddress = $fakeDNSForwarder.IpAddress; UseRootHint = $false } }
                Test-TargetResource @testParams | Should Be $false
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe 'MSFT_xDnsServerForwarder\Set-TargetResource' {
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
                        $UseRootHint -eq $true -and $null -eq $IPAddress
                    } -Times 0 -Exactly -Scope It
                }
            }

        }
    } #end InModuleScope
}
finally
{
    Invoke-TestCleanup
}
