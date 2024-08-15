<#
    .SYNOPSIS
        Unit test for DSC_DnsServerSettingLegacy DSC resource.
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
    $script:dscResourceName = 'DSC_DnsServerSettingLegacy'

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

Describe 'DSC_DnsServerSettingLegacy\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module
        Mock -CommandName Get-CimClassMicrosoftDnsServer -MockWith {
            return @{
                DnsServer            = 'dns1.company.local'
                DisjointNets         = $false
                NoForwarderRecursion = $false
                LogLevel             = [System.UInt32] 0
            }
        }
    }

    Context 'When the system is in the desired state' {
        It 'Should return the correct values for each property' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getTargetResourceResult = Get-TargetResource -DnsServer 'dns1.company.local'

                $getTargetResourceResult.DisjointNets | Should -BeFalse
                $getTargetResourceResult.NoForwarderRecursion | Should -BeFalse
                $getTargetResourceResult.LogLevel | Should -Be 0
            }
        }
    }
}

Describe 'DSC_DnsServerSettingLegacy\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    DnsServer            = 'dns1.company.local'
                    DisjointNets         = $true
                    NoForwarderRecursion = $true
                    LogLevel             = [System.UInt32] 5
                }
            }
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'DisjointNets'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'NoForwarderRecursion'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'LogLevel'
                    PropertyValue = [System.UInt32] 0
                }
            )
        }

        It 'Should return $false for property <PropertyName>' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceParameters = @{
                    DnsServer     = 'dns1.company.local'
                    $PropertyName = $PropertyValue
                }

                Test-TargetResource @testTargetResourceParameters | Should -BeFalse
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    DnsServer            = 'dns1.company.local'
                    DisjointNets         = $true
                    NoForwarderRecursion = $true
                    LogLevel             = [System.UInt32] 5
                }
            }
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'DisjointNets'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'NoForwarderRecursion'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'LogLevel'
                    PropertyValue = [System.UInt32] 5
                }
            )
        }

        It 'Should return $true for property <PropertyName>' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceParameters = @{
                    DnsServer     = 'dns1.company.local'
                    $PropertyName = $PropertyValue
                }

                Test-TargetResource @testTargetResourceParameters | Should -BeTrue
            }
        }
    }
}

Describe 'DSC_DnsServerSettingLegacy\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module
        Mock -CommandName Set-CimInstance
        Mock -CommandName Get-CimClassMicrosoftDnsServer -MockWith {
            return New-CimInstance -ClassName 'MicrosoftDNS_Server' -Namespace 'root\MicrosoftDNS' -ClientOnly -Property @{
                DisjointNets         = $false
                NoForwarderRecursion = $false
                LogLevel             = [System.UInt32] 0
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    DnsServer            = 'dns1.company.local'
                    DisjointNets         = $true
                    NoForwarderRecursion = $true
                    LogLevel             = [System.UInt32] 5
                }
            }
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'DisjointNets'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'NoForwarderRecursion'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'LogLevel'
                    PropertyValue = [System.UInt32] 0
                }
            )
        }
        It 'Should not throw and call the correct mock to set the property <PropertyName>' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $setTargetResourceParameters = @{
                    DnsServer     = 'dns1.company.local'
                    $PropertyName = $PropertyValue
                }

                { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
            }

            Should -Invoke -CommandName Set-CimInstance -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    DnsServer            = 'dns1.company.local'
                    DisjointNets         = $true
                    NoForwarderRecursion = $true
                    LogLevel             = [System.UInt32] 5
                }
            }
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'DisjointNets'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'NoForwarderRecursion'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'LogLevel'
                    PropertyValue = [System.UInt32] 5
                }
            )
        }

        It 'Should not throw and should not set the property <PropertyName>' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $setTargetResourceParameters = @{
                    DnsServer     = 'dns1.company.local'
                    $PropertyName = $PropertyValue
                }

                { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
            }

            Should -Invoke -CommandName Set-CimInstance -Exactly -Times 0 -Scope It
        }
    }
}

Describe 'DSC_DnsServerSettingLegacy\Get-CimClassMicrosoftDnsServer' -Tag 'Helper' {
    BeforeAll {
        Mock -CommandName Get-CimInstance -MockWith {
            return New-CimInstance -ClassName 'MicrosoftDNS_Server' -Namespace 'root\MicrosoftDNS' -ClientOnly -Property @{
                DisjointNets         = $false
                NoForwarderRecursion = $false
                LogLevel             = [System.UInt32] 0
            }
        }
    }

    Context 'When the system is not in the desired state' {
        It 'Should return the correct object' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getCimClassMicrosoftDnsServerResult = Get-CimClassMicrosoftDnsServer -DnsServer 'dns1.company.local'

                $getCimClassMicrosoftDnsServerResult | Should -BeOfType [Microsoft.Management.Infrastructure.CimInstance]
                $getCimClassMicrosoftDnsServerResult.DisjointNets | Should -BeFalse
                $getCimClassMicrosoftDnsServerResult.NoForwarderRecursion | Should -BeFalse
                $getCimClassMicrosoftDnsServerResult.LogLevel | Should -Be 0
            }
        }
    }
}
