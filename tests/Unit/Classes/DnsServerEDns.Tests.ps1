<#
    .SYNOPSIS
        Unit test for DSC_DnsServerScavenging DSC resource.
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
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
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

    Import-Module -Name $script:dscModuleName

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '..\Stubs\DnsServer.psm1') -Force

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force

    # Unload the stub module.
    Remove-Module -Name DnsServer -Force
}

Describe 'DnsServerEDns\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerEDns -MockWith {
                return New-CimInstance -ClassName 'DnsServerEDns' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    CacheTimeout    = '0.00:15:00'
                    EnableProbes    = $true
                    EnableReception = $true
                }
            }
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance | Should -Not -BeNullOrEmpty
                $script:instance.GetType().Name | Should -Be 'DnsServerEDns'
            }
        }

        It 'Should return the correct values for the properties when DnsServer is set to ''<HostName>''' -TestCases @(
            @{
                HostName = 'localhost'
            }
            @{
                HostName = 'dns.company.local'
            }
        ) {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance.DnsServer = $HostName

                $getResult = $script:instance.Get()

                $getResult.DnsServer | Should -Be $HostName
                $getResult.EnableProbes | Should -BeTrue
                $getResult.EnableReception | Should -BeTrue
                $getResult.CacheTimeout | Should -Be '0.00:15:00'
            }
            Should -Invoke -CommandName Get-DnsServerEDns -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerEDns\Test()' -Tag 'Test' {

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '235.a:00:00'
                    $script:instance.CacheTimeout = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'CacheTimeout', $mockInvalidTime

                    { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                }
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '-1.00:00:00'
                    $script:instance.CacheTimeout = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'CacheTimeout', $mockInvalidTime, '00:00:00'

                    { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                }
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns] @{
                    EnableReception = $true
                    EnableProbes    = $true
                    CacheTimeout    = '0.00:15:00'
                }

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerEDns] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
            }
        }

        It 'Should return the $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getResult = $script:instance.Test()

                $getResult | Should -BeTrue
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:30:00'
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerEDns] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
            }
        }

        It 'Should return the $false when property <PropertyName> is not in desired state' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance.$PropertyName = $PropertyValue

                $getResult = $script:instance.Test()

                $getResult | Should -BeFalse
            }
        }
    }
}

Describe 'DnsServerEDns\Set()' -Tag 'Set' {

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '235.a:00:00'
                    $script:instance.CacheTimeout = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'CacheTimeout', $mockInvalidTime


                    { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                }
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '-1.00:00:00'
                    $script:instance.CacheTimeout = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'CacheTimeout', $mockInvalidTime, '00:00:00'


                    { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                }
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerEDns -ModuleName $ProjectName
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:15:00'
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns]::new()


                $script:instance.DnsServer = 'localhost'

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerEDns] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
            }
        }

        It 'Should not call any mock to set a value for property ''<PropertyName>''' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance.$PropertyName = $PropertyValue

                { $script:instance.Set() } | Should -Not -Throw
            }
            Should -Invoke -CommandName Set-DnsServerEDns -ModuleName $ProjectName -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerEDns
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:30:00'
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0
                $script:instance = [DnsServerEDns]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerEDns] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
            }
        }

        Context 'When parameter DnsServer is set to ''localhost''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instance.DnsServer = 'localhost'
                    $script:instance.$PropertyName = $PropertyValue

                    { $script:instance.Set() } | Should -Not -Throw
                }
                Should -Invoke -CommandName Set-DnsServerEDns -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }

        Context 'When parameter DnsServer is set to ''dns.company.local''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instance.DnsServer = 'dns.company.local'
                    $script:instance.$PropertyName = $PropertyValue

                    { $script:instance.Set() } | Should -Not -Throw
                }
                Should -Invoke -CommandName Set-DnsServerEDns -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }
    }
}
