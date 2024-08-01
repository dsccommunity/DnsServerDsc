<#
    .SYNOPSIS
        Unit test for DSC_DnsServerEDns DSC resource.
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

Describe DnsServerEDns -Tag 'DnsServer', 'DnsServerEDns' {
    Context 'Constructors' {
        It 'Should not throw an exception when instantiated' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [DnsServerEDns]::new() } | Should -Not -Throw
            }
        }

        It 'Has a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsServerEDns]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsServerEDns' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsServerEDns]::new()
                $instance.GetType().Name | Should -Be 'DnsServerEDns'
            }
        }
    }
}

Describe 'DnsServerEDns\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns] @{
                    CacheTimeout    = '0.00:15:00'
                    EnableProbes    = $true
                    EnableReception = $true
                }

                <#
                This mocks the method GetCurrentState().

                    Method Get() will call the base method Get() which will
                    call back to the derived class method GetCurrentState()
                    to get the result to return from the derived method Get().
                #>
                $script:instance | Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                    return @{
                        CacheTimeout    = '0.00:15:00'
                        EnableProbes    = $true
                        EnableReception = $true
                    }
                } -PassThru | Add-Member -Force -MemberType 'ScriptMethod' -Name 'AssertProperties' -Value {
                    return
                }
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
                $script:instance.GetCurrentState(
                    @{
                        DnsServer = $HostName
                    }
                )

                $getResult = $script:instance.Get()

                $getResult.DnsServer | Should -Be $HostName
                $getResult.EnableProbes | Should -BeTrue
                $getResult.EnableReception | Should -BeTrue
                $getResult.CacheTimeout | Should -Be '0.00:15:00'
                $getResult.Reasons | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property EnableReception has the wrong value' {

            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instance = [DnsServerEDns] @{
                        CacheTimeout    = '0.00:15:00'
                        EnableProbes    = $true
                        EnableReception = $true
                    }

                    <#
                This mocks the method GetCurrentState().

                    Method Get() will call the base method Get() which will
                    call back to the derived class method GetCurrentState()
                    to get the result to return from the derived method Get().
                #>
                    $script:instance | Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                        return @{
                            CacheTimeout    = '0.00:15:00'
                            EnableProbes    = $true
                            EnableReception = $false
                        }
                    } -PassThru | Add-Member -Force -MemberType 'ScriptMethod' -Name 'AssertProperties' -Value {
                        return
                    }
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
                    $script:instance.GetCurrentState(
                        @{
                            DnsServer = $HostName
                        }
                    )

                    $getResult = $script:instance.Get()

                    $getResult.DnsServer | Should -Be $HostName
                    $getResult.EnableProbes | Should -BeTrue
                    $getResult.EnableReception | Should -BeFalse
                    $getResult.CacheTimeout | Should -Be '0.00:15:00'
                    $getResult.Reasons | Should -HaveCount 1
                    $getResult.Reasons[0].Code | Should -Be 'DnsServerEDns:DnsServerEDns:EnableReception'
                    $getResult.Reasons[0].Phrase | Should -Be 'The property EnableReception should be true, but was false'
                }
            }
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
            Mock -CommandName Set-DnsServerEDns
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
            Should -Invoke -CommandName Set-DnsServerEDns -Exactly -Times 0 -Scope It
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
                Should -Invoke -CommandName Set-DnsServerEDns -Exactly -Times 1 -Scope It
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
                Should -Invoke -CommandName Set-DnsServerEDns -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'DnsServerEDns\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When object is missing in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns] @{
                    DnsServer = 'localhost'
                }
            }
            Mock -CommandName Get-DnsServerEDns
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:instance.GetCurrentState(
                    @{
                        DnsServer = 'localhost'
                    }
                )

                $currentState.DnsServer | Should -Be 'localhost'
                $currentState.CacheTimeout | Should -BeNullOrEmpty
                $currentState.EnableProbes | Should -BeFalse
                $currentState.EnableReception | Should -BeFalse
            }
            Should -Invoke -CommandName Get-DnsServerEDns -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the object is present in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerEDns] @{
                    DnsServer = 'SomeHost'
                }
            }
            Mock -CommandName Get-DnsServerEDns -MockWith {
                return New-CimInstance -ClassName 'DnsServerEDns' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    CacheTimeout    = '0.00:15:00'
                    EnableProbes    = $true
                    EnableReception = $true
                }
            }
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:instance.GetCurrentState(
                    @{
                        DnsServer = 'SomeHost'
                    }
                )

                $currentState.DnsServer | Should -Be 'SomeHost'
                $currentState.CacheTimeout | Should -Be '0.00:15:00'
                $currentState.EnableProbes | Should -BeTrue
                $currentState.EnableReception | Should -BeTrue
            }
            Should -Invoke -CommandName Get-DnsServerEDns -Exactly -Times 1 -Scope It
        }
    }
}
