<#
    .SYNOPSIS
        Unit test for DSC_DnsServerClientSubnet DSC resource.
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
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
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
    $script:dscResourceName = 'DSC_DnsServerClientSubnet'

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

Describe 'DSC_DnsServerClientSubnet\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        $IPv4Present = {
            [PSCustomObject]@{
                Name       = 'ClientSubnetA'
                IPv4Subnet = '10.1.1.0/24'
                IPv6Subnet = $null
            }
        }
        $IPv6Present = {
            [PSCustomObject]@{
                Name       = 'ClientSubnetB'
                IPv4Subnet = $null
                IPv6Subnet = 'db8::1/28'
            }
        }
        $BothPresent = {
            [PSCustomObject]@{
                Name       = 'ClientSubnetC'
                IPv4Subnet = '10.1.1.0/24'
                IPv6Subnet = 'db8::1/28'
            }
        }
    }
    Context 'When the system is in the desired state' {
        Context 'When the IPv4 client subnet is present' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet -MockWith $IPv4Present
            }

            It 'Should set Ensure to Present' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $getTargetResourceResult = Get-TargetResource 'ClientSubnetA'
                    $getTargetResourceResult.Ensure | Should -Be 'Present'
                    $getTargetResourceResult.IPv4Subnet | Should -Be '10.1.1.0/24'
                    $getTargetResourceResult.IPv6Subnet | Should -BeNullOrEmpty
                }

                Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the IPv6 client subnet is present' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet -MockWith $IPv6Present
            }

            It 'Should set Ensure to Present' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $getTargetResourceResult = Get-TargetResource 'ClientSubnetB'
                    $getTargetResourceResult.Ensure | Should -Be 'Present'
                    $getTargetResourceResult.IPv4Subnet | Should -BeNullOrEmpty
                    $getTargetResourceResult.IPv6Subnet | Should -Be 'db8::1/28'
                }

                Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
            }
        }

        Context 'When both client subnets are present' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet -MockWith $BothPresent
            }

            It 'Should set Ensure to Present' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $getTargetResourceResult = Get-TargetResource 'ClientSubnetC'
                    $getTargetResourceResult.Ensure | Should -Be 'Present'
                    $getTargetResourceResult.IPv4Subnet | Should -Be '10.1.1.0/24'
                    $getTargetResourceResult.IPv6Subnet | Should -Be 'db8::1/28'
                }

                Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerClientSubnet
        }

        It 'Should set Ensure to Absent when the IPv4 client subnet is not present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult = Get-TargetResource 'ClientSubnetA'
                $getTargetResourceResult.Ensure | Should -Be 'Absent'
                $getTargetResourceResult.IPv4Subnet | Should -BeNullOrEmpty
                $getTargetResourceResult.IPv6Subnet | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
        }

        It 'Should set Ensure to Absent when the IPv6 client subnet is not present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult = Get-TargetResource 'ClientSubnetB'
                $getTargetResourceResult.Ensure | Should -Be 'Absent'
                $getTargetResourceResult.IPv4Subnet | Should -BeNullOrEmpty
                $getTargetResourceResult.IPv6Subnet | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
        }

        It 'Should set Ensure to Absent when both client subnets are not present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult = Get-TargetResource 'ClientSubnetC'
                $getTargetResourceResult.Ensure | Should -Be 'Absent'
                $getTargetResourceResult.IPv4Subnet | Should -BeNullOrEmpty
                $getTargetResourceResult.IPv6Subnet | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_DnsServerClientSubnet\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        $IPv4Present = {
            [PSCustomObject]@{
                Name       = 'ClientSubnetA'
                IPv4Subnet = '10.1.1.0/24'
                IPv6Subnet = $null
            }
        }
        $IPv6Present = {
            [PSCustomObject]@{
                Name       = 'ClientSubnetB'
                IPv4Subnet = $null
                IPv6Subnet = 'db8::1/28'
            }
        }
        $BothPresent = {
            [PSCustomObject]@{
                Name       = 'ClientSubnetC'
                IPv4Subnet = '10.1.1.0/24'
                IPv6Subnet = 'db8::1/28'
            }
        }
    }
    Context 'When the system is in the desired state' {
        Context 'When the IPv4Subnet matches' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet $IPv4Present
            }

            It 'Should return True' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetA'
                        IPv4Subnet = '10.1.1.0/24'
                    }
                    Test-TargetResource @params | Should -BeTrue
                }
            }
        }

        Context 'When the IPv6Subnet matches' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet $IPv6Present
            }

            It 'Should return True' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetB'
                        IPv6Subnet = 'db8::1/28'
                    }
                    Test-TargetResource @params | Should -BeTrue
                }
            }
        }

        Context 'When both IPv4 and IPv6 Subnets match' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet $BothPresent
            }

            It 'Should return True' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetC'
                        IPv4Subnet = '10.1.1.0/24'
                        IPv6Subnet = 'db8::1/28'
                    }
                    Test-TargetResource @params | Should -BeTrue
                }
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerClientSubnet

            $GetIPv4Present = {
                [PSCustomObject]@{
                    Name       = 'ClientSubnetA'
                    IPv4Subnet = '10.1.1.0/24'
                    IPv6Subnet = $null
                }
            }
            $GetIPv6Present = {
                [PSCustomObject]@{
                    Name       = 'ClientSubnetB'
                    IPv4Subnet = $null
                    IPv6Subnet = 'db8::1/28'
                    Ensure     = 'Present'
                }
            }
        }

        It 'Should return False when the Ensure doesnt match' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Ensure     = 'Present'
                    Name       = 'ClientSubnetA'
                    IPv4Subnet = '10.1.20.0/24'
                }
                Test-TargetResource @params | Should -BeFalse
            }

            Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
        }

        Context 'When an IPv4 Subnet does not exist but one is configured' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet
            }

            It 'Should return False' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetA'
                        IPv4Subnet = '10.1.20.0/24'
                    }
                    Test-TargetResource @params | Should -BeFalse
                }

                Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the IPv4 Subnet does not match what is configured' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet -MockWith $GetIPv4Present
            }

            It 'Should return False' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetA'
                        IPv4Subnet = '10.1.20.0/24'
                    }
                    Test-TargetResource @params | Should -BeFalse
                }

                Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the IPv6 Subnet does not match what is configured' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet -MockWith $GetIPv6Present
            }

            It 'Should return False' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetB'
                        IPv6Subnet = 'aab8::1/28'
                    }
                    Test-TargetResource @params | Should -BeFalse
                }

                Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
            }
        }

        Context 'When an IPv6 Subnet does not exist but one is configured' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet
            }

            It 'Should return False' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetB'
                        IPv6Subnet = 'db8::1/28'
                    }
                    Test-TargetResource @params | Should -BeFalse
                }

                Should -Invoke -CommandName Get-DnsServerClientSubnet -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'DSC_DnsServerClientSubnet\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        $IPv4Present = {
            [PSCustomObject]@{
                Name       = 'ClientSubnetA'
                IPv4Subnet = '10.1.1.0/24'
                IPv6Subnet = $null
            }
        }
    }

    Context 'When configuring DNS Server Client Subnets' {
        Context 'When the subnet does not exist' {
            BeforeAll {
                Mock -CommandName Get-DnsServerClientSubnet
                Mock -CommandName Add-DnsServerClientSubnet
            }

            It 'Should call Add-DnsServerClientSubnet in the set method' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetA'
                        IPv4Subnet = '10.1.20.0/24'
                    }
                    Set-TargetResource @params
                }

                Should -Invoke Add-DnsServerClientSubnet -Scope It -ParameterFilter {
                    $Name -eq 'ClientSubnetA' -and $IPv4Subnet -eq '10.1.20.0/24'
                }
            }

            It 'Should call Add-DnsServerClientSubnet in the set method' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetB'
                        IPv6Subnet = 'db8::1/28'
                    }
                    Set-TargetResource @params
                }

                Should -Invoke Add-DnsServerClientSubnet -Scope It -ParameterFilter {
                    $Name -eq 'ClientSubnetB' -and $IPv6Subnet -eq 'db8::1/28'
                }
            }
        }

        Context 'When the subnet does not exist' {
            BeforeAll {
                Mock -CommandName Remove-DnsServerClientSubnet
                Mock -CommandName Get-DnsServerClientSubnet -MockWith { return $IPv4Present }
            }

            It 'Should call Remove-DnsServerClientSubnet in the set method when Ensure is Absent' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Absent'
                        Name       = 'ClientSubnetA'
                        IPv4Subnet = '10.1.20.0/24'
                    }
                    Set-TargetResource @params
                }

                Should -Invoke Remove-DnsServerClientSubnet -Scope It
            }
        }

        Context 'When the subnet does not exist' {
            BeforeAll {
                Mock -CommandName Set-DnsServerClientSubnet
                Mock -CommandName Get-DnsServerClientSubnet -MockWith { return $IPv4Present }
            }

            It 'Should call Set-DnsServerClientSubnet in the set method when Ensure is Present subnet is found' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Ensure     = 'Present'
                        Name       = 'ClientSubnetX'
                        IPv4Subnet = '10.1.1.0/24'
                    }
                    Set-TargetResource @params
                }

                Should -Invoke Set-DnsServerClientSubnet -Scope It
            }
        }
    }
}
