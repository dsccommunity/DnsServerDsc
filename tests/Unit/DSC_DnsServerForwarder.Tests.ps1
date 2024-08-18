<#
    .SYNOPSIS
        Unit test for DSC_DnsServerForwarder DSC resource.
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'DnsServerDsc'
    $script:dscResourceName = 'DSC_DnsServerForwarder'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    Remove-Module -Name DnsServer -Force
}

Describe 'DSC_DnsServerForwarder\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Get-DnsServerForwarder -MockWith {
            return @{
                IPAddress        = $forwarders
                UseRootHint      = $UseRootHint
                Timeout          = $timeout
                EnableReordering = $reordering
            }
        }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:defaultParameters = @{
                IsSingleInstance = 'Yes'
                IPAddresses      = '192.168.0.1', '192.168.0.2'
                UseRootHint      = $true
                Verbose          = $false
            }
        }
    }

    BeforeEach {
        $script:forwarders = '192.168.0.1', '192.168.0.2'
        $script:UseRootHint = $true
        $script:timeout = 10
        $script:reordering = $true

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockTestParameters = $defaultParameters.Clone()
        }
    }

    It 'Should return a "System.Collections.Hashtable" object type' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Get-TargetResource -IsSingleInstance $mockTestParameters.IsSingleInstance

            $targetResource | Should -BeOfType [System.Collections.Hashtable]
        }
    }

    It 'Should return the correct values when forwarders exist' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Get-TargetResource -IsSingleInstance $mockTestParameters.IsSingleInstance

            $targetResource.IPAddresses | Should -Be $mockTestParameters.IPAddresses
            $targetResource.UseRootHint | Should -Be $mockTestParameters.UseRootHint
            $targetResource.TimeOut | Should -Be 10
            $targetResource.EnableReordering | Should -BeTrue
        }
    }

    It "Should return expected values when forwarders don't exist" {
        $script:forwarders = @()
        $script:timeout = 4
        $script:reordering = $false

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Get-TargetResource -IsSingleInstance $mockTestParameters.IsSingleInstance

            $targetResource.IPAddresses | Should -BeNullOrEmpty
            $targetResource.UseRootHint | Should -BeTrue
            $targetResource.Timeout | Should -Be 4
            $targetResource.EnableReordering | Should -BeFalse
        }
    }
}

Describe 'DSC_DnsServerForwarder\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        $forwarders = '192.168.0.1', '192.168.0.2'
        $UseRootHint = $true

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

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:defaultParameters = @{
                IsSingleInstance = 'Yes'
                IPAddresses      = '192.168.0.1', '192.168.0.2'
                UseRootHint      = $true
                Verbose          = $false
            }

            $script:defaultParamsLimited = @{
                IsSingleInstance = 'Yes'
                IPAddresses      = '192.168.0.1', '192.168.0.2'
                Verbose          = $false
            }
        }
    }

    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockTestParameters = $defaultParameters.Clone()
            $script:mockLimitedTestParameters = $defaultParamsLimited.Clone()
        }

    }

    Context 'When the system is in the desired state' {
        Context 'When the command completes' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return $fakeDNSForwarder
                }
            }

            It 'Should return a "System.Boolean" object type' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $targetResource = Test-TargetResource @mockTestParameters

                    $targetResource | Should -BeOfType [System.Boolean]
                }
            }
        }

        Context 'When forwarders match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return $fakeDNSForwarder
                }
            }

            It 'Should return $true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Test-TargetResource @mockTestParameters | Should -BeTrue
                }
            }
        }

        Context 'When forwarders match but root hint do not and are not specified' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return $fakeUseRootHint
                }
            }

            It 'Should return $true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Test-TargetResource @mockLimitedTestParameters | Should -BeTrue
                }
            }
        }

        Context 'When EnableReordering does match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        EnableReordering = $true
                    }
                }
            }

            It "Should return $true" {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-TargetResource -IsSingleInstance 'Yes' -EnableReordering $true

                    $result | Should -BeTrue
                }
            }
        }

        Context 'When Timeout does match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        Timeout = 4
                    }
                }
            }

            It 'Should return $true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-TargetResource -IsSingleInstance 'Yes' -Timeout 4

                    $result | Should -BeTrue
                }
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When forwarder count do not match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        IPAddress   = @()
                        UseRootHint = $true
                    }
                }
            }

            It 'Should return $false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0
                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }
        }
        Context 'When forwarder values do not match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        IPAddress   = '192.168.0.1', '192.168.0.3'
                        UseRootHint = $true
                    }
                }
            }

            It 'Should return $false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0
                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }
        }

        Context 'When UseRootHint does not match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        IPAddress   = $fakeDNSForwarder.IpAddress
                        UseRootHint = $false
                    }
                }
            }

            It 'Should return $false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0
                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }
        }

        Context 'When EnableReordering does not match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        EnableReordering = $false
                    }
                }
            }

            It 'Should return $false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-TargetResource -IsSingleInstance 'Yes' -EnableReordering $true

                    $result | Should -BeFalse
                }
            }
        }

        Context 'When Timeout does not match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerForwarder -MockWith {
                    return @{
                        Timeout = 10
                    }
                }
            }

            It "Should return $false" {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $result = Test-TargetResource -IsSingleInstance 'Yes' -Timeout 4

                    $result | Should -BeFalse
                }
            }
        }
    }
}

Describe 'DSC_DnsServerForwarder\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:testParams = @{
                IsSingleInstance = 'Yes'
                IPAddresses      = '192.168.0.1', '192.168.0.2'
                UseRootHint      = $true
                Verbose          = $false
            }
        }
    }

    Context 'When setting forwarders' {
        BeforeAll {
            Mock -CommandName Set-DnsServerForwarder

            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockSetParameters = $testParams.Clone()
            }
        }

        It 'Should call Set-DnsServerForwarder once' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Set-TargetResource @mockSetParameters
            }

            Should -Invoke -CommandName Set-DnsServerForwarder -Times 1 -Exactly -Scope It
        }
    }

    Context 'When removing all forwarders' {
        BeforeAll {
            Mock -CommandName Set-DnsServerForwarder
            Mock -CommandName Remove-DnsServerForwarder
            Mock -CommandName Get-DnsServerForwarder -MockWith {
                return New-CimInstance -ClassName 'DnsServerForwarder' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    IPAddress = @('1.1.1.1')
                }
            }
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Set-TargetResource -IsSingleInstance 'Yes' -IPAddresses @()
            }

            Should -Invoke -CommandName Set-DnsServerForwarder -Times 0 -Exactly -Scope It
            Should -Invoke -CommandName Get-DnsServerForwarder -Times 1 -Exactly -Scope It
            Should -Invoke -CommandName Remove-DnsServerForwarder -Times 1 -Exactly -Scope It
        }
    }

    Context 'When enforcing just parameter UseRootHint' {
        BeforeAll {
            Mock -CommandName Set-DnsServerForwarder
        }

        It 'Should call the correct mock with correct parameters' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Set-TargetResource -IsSingleInstance 'Yes' -UseRootHint $true
            }

            Should -Invoke -CommandName Set-DnsServerForwarder -ParameterFilter {
                # Only the property UseRootHint should exist in $PSBoundParameters.
                -not $PSBoundParameters.ContainsKey('IPAddress') -and $UseRootHint -eq $true
            } -Times 1 -Exactly -Scope It
        }
    }

    Context 'When enforcing just parameter EnableReordering' {
        BeforeAll {
            Mock -CommandName Set-DnsServerForwarder
        }

        It 'Should call the correct mock with correct parameters' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Set-TargetResource -IsSingleInstance 'Yes' -EnableReordering $true
            }

            Should -Invoke -CommandName Set-DnsServerForwarder -ParameterFilter {
                # Only the property UseRootHint should exist in $PSBoundParameters.
                -not $PSBoundParameters.ContainsKey('IPAddress') -and $EnableReordering -eq $true
            } -Times 1 -Exactly -Scope It
        }
    }

    Context 'When enforcing just parameter Timeout' {
        BeforeAll {
            Mock -CommandName Set-DnsServerForwarder
        }

        It 'Should call the correct mock with correct parameters' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Set-TargetResource -IsSingleInstance 'Yes' -Timeout 4
            }

            Should -Invoke -CommandName Set-DnsServerForwarder -ParameterFilter {
                # Only the property UseRootHint should exist in $PSBoundParameters.
                -not $PSBoundParameters.ContainsKey('IPAddress') -and $Timeout -eq 4
            } -Times 1 -Exactly -Scope It
        }
    }
}
