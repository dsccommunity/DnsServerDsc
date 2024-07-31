<#
    .SYNOPSIS
        Unit test for DSC_DnsServerRecursion DSC resource.
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

Describe DnsServerRecursion -Tag 'DnsServer', 'DnsServerRecursion' {
    Context 'Constructors' {
        It 'Should not throw an exception when instantiated' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [DnsServerRecursion]::new() } | Should -Not -Throw
            }
        }

        It 'Has a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsServerRecursion]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsServerRecursion' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsServerRecursion]::new()
                $instance.GetType().Name | Should -Be 'DnsServerRecursion'
            }
        }
    }
}

Describe 'DnsServerRecursion\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRecursion -MockWith {
                return New-CimInstance -ClassName 'DnsServerRecursion' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    Enable            = $true
                    AdditionalTimeout = 4
                    RetryInterval     = 3
                    Timeout           = 8
                }
            }
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerRecursion]::new()
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
                $getResult.Enable | Should -BeTrue
                $getResult.AdditionalTimeout | Should -Be 4
                $getResult.RetryInterval | Should -Be 3
                $getResult.Timeout | Should -Be 8
            }
            Should -Invoke -CommandName Get-DnsServerRecursion -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerRecursion\Test()' -Tag 'Test' {

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerRecursion]::new()
            }
        }

        It 'Should throw the correct error when property <PropertyName> has invalid value' -TestCases @(
            @{
                PropertyName = 'AdditionalTimeout'
            }
            @{
                PropertyName = 'RetryInterval'
            }
            @{
                PropertyName = 'Timeout'
            }
        ) {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockInvalidValue = 16
                $script:instance.$PropertyName = $mockInvalidValue

                $mockExpectedErrorMessage = $script:localizedData.PropertyIsNotInValidRange -f $PropertyName, $mockInvalidValue

                { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerRecursion]::new()

                $script:instance.Enable = $true
                $script:instance.AdditionalTimeout = 4
                $script:instance.RetryInterval = 3
                $script:instance.Timeout = 8

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerRecursion] @{
                            DnsServer         = 'localhost'
                            Enable            = $true
                            AdditionalTimeout = 4
                            RetryInterval     = 3
                            Timeout           = 8
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
                    PropertyName  = 'Enable'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'AdditionalTimeout'
                    PropertyValue = 5
                }
                @{
                    PropertyName  = 'RetryInterval'
                    PropertyValue = 4
                }
                @{
                    PropertyName  = 'Timeout'
                    PropertyValue = 9
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerRecursion]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerRecursion] @{
                            DnsServer         = 'localhost'
                            Enable            = $true
                            AdditionalTimeout = 4
                            RetryInterval     = 3
                            Timeout           = 8
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

Describe 'DnsServerRecursion\Set()' -Tag 'Set' {

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerRecursion]::new()
            }
        }

        It 'Should throw the correct error when property <PropertyName> has invalid value' -TestCases @(
            @{
                PropertyName = 'AdditionalTimeout'
            }
            @{
                PropertyName = 'RetryInterval'
            }
            @{
                PropertyName = 'Timeout'
            }
        ) {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockInvalidValue = 16
                $script:instance.$PropertyName = $mockInvalidValue

                $mockExpectedErrorMessage = $script:localizedData.PropertyIsNotInValidRange -f $PropertyName, $mockInvalidValue

                { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerRecursion
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'Enable'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'AdditionalTimeout'
                    PropertyValue = 4
                }
                @{
                    PropertyName  = 'RetryInterval'
                    PropertyValue = 3
                }
                @{
                    PropertyName  = 'Timeout'
                    PropertyValue = 8
                }
            )

        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerRecursion]::new()

                $script:instance.DnsServer = 'localhost'

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerRecursion] @{
                            DnsServer         = 'localhost'
                            Enable            = $true
                            AdditionalTimeout = 4
                            RetryInterval     = 3
                            Timeout           = 8
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
            Should -Invoke -CommandName Set-DnsServerRecursion -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerRecursion
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'Enable'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'AdditionalTimeout'
                    PropertyValue = 5
                }
                @{
                    PropertyName  = 'RetryInterval'
                    PropertyValue = 4
                }
                @{
                    PropertyName  = 'Timeout'
                    PropertyValue = 9
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerRecursion]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerRecursion] @{
                            DnsServer         = 'localhost'
                            Enable            = $true
                            AdditionalTimeout = 4
                            RetryInterval     = 3
                            Timeout           = 8
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
                Should -Invoke -CommandName Set-DnsServerRecursion -Exactly -Times 1 -Scope It
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
                Should -Invoke -CommandName Set-DnsServerRecursion -Exactly -Times 1 -Scope It
            }
        }
    }
}
