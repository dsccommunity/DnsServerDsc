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

Describe 'DnsServerScavenging' -Tag 'DnsServer', 'DnsServerScavenging' {
    Context 'Constructors' {
        It 'Should not throw an exception when instantiated' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [DnsServerScavenging]::new() } | Should -Not -Throw
            }
        }

        It 'Has a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsServerScavenging]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsServerScavenging' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsServerScavenging]::new()
                $instance.GetType().Name | Should -Be 'DnsServerScavenging'
            }
        }
    }
}

Describe 'DnsServerScavenging\Get()' -Tag 'Get', 'DnsServer', 'DnsServerScavenging' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-DnsServerScavenging -MockWith {
                return New-CimInstance -ClassName 'DnsServerScavenging' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    ScavengingState    = $true
                    ScavengingInterval = '30.00:00:00'
                    RefreshInterval    = '30.00:00:00'
                    NoRefreshInterval  = '30.00:00:00'
                    LastScavengeTime   = '2021-01-01 00:00:00'
                }
            }
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerScavenging]::new()
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
                $getResult.ScavengingState | Should -BeTrue
                $getResult.ScavengingInterval | Should -Be '30.00:00:00'
                $getResult.RefreshInterval | Should -Be '30.00:00:00'
                $getResult.NoRefreshInterval | Should -Be '30.00:00:00'

                # Returns as a DateTime type and not a string.
                $getResult.LastScavengeTime.ToString('yyyy-mm-dd HH:mm:ss') | Should -Be ([System.DateTime] '2021-01-01 00:00:00').ToString('yyyy-mm-dd HH:mm:ss')
            }
            Should -Invoke -CommandName Get-DnsServerScavenging -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerScavenging\Test()' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerScavenging]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '235.a:00:00'
                    $script:instance.ScavengingInterval = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'ScavengingInterval', $mockInvalidTime

                    { $script:instance.Test() } | Should -Throw -ExpectedMessage ('*' + $mockExpectedErrorMessage)
                }
            }
        }

        Context 'When the time exceeds maximum allowed value' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '365.00:00:01'
                    $script:instance.ScavengingInterval = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f 'ScavengingInterval', $mockInvalidTime, '365.00:00:00'

                    { $script:instance.Test() } | Should -Throw -ExpectedMessage ('*' + $mockExpectedErrorMessage)
                }
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '-1.00:00:00'
                    $script:instance.ScavengingInterval = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'ScavengingInterval', $mockInvalidTime, '00:00:00'

                    { $script:instance.Test() } | Should -Throw -ExpectedMessage ('*' + $mockExpectedErrorMessage)
                }
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerScavenging] @{
                    ScavengingState    = $true
                    ScavengingInterval = '30.00:00:00'
                    RefreshInterval    = '30.00:00:00'
                    NoRefreshInterval  = '30.00:00:00'
                    LastScavengeTime   = '2021-01-01 00:00:00'
                }

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerScavenging] @{
                            DnsServer          = 'localhost'
                            ScavengingState    = $true
                            ScavengingInterval = '30.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'
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
                    PropertyName  = 'ScavengingState'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'ScavengingInterval'
                    PropertyValue = '7.00:00:00'
                }
                @{
                    PropertyName  = 'RefreshInterval'
                    PropertyValue = '7.00:00:00'
                }
                @{
                    PropertyName  = 'NoRefreshInterval'
                    PropertyValue = '7.00:00:00'
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerScavenging]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerScavenging] @{
                            DnsServer          = 'localhost'
                            ScavengingState    = $true
                            ScavengingInterval = '30.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'
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

Describe 'DnsServerScavenging\Set()' -Tag 'Set' {

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerScavenging]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '235.a:00:00'

                    $script:instance.ScavengingInterval = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'ScavengingInterval', $mockInvalidTime

                    { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                }
            }
        }

        Context 'When the time exceeds maximum allowed value' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '365.00:00:01'

                    $script:instance.ScavengingInterval = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f 'ScavengingInterval', $mockInvalidTime, '365.00:00:00'

                    { $script:instance.Test() } | Should -Throw -ExpectedMessage ('*' + $mockExpectedErrorMessage )
                }
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '-1.00:00:00'

                    $script:instance.ScavengingInterval = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'ScavengingInterval', $mockInvalidTime, '00:00:00'

                    { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                }
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'ScavengingState'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'ScavengingInterval'
                    PropertyValue = '30.00:00:00'
                }
                @{
                    PropertyName  = 'RefreshInterval'
                    PropertyValue = '30.00:00:00'
                }
                @{
                    PropertyName  = 'NoRefreshInterval'
                    PropertyValue = '30.00:00:00'
                }
            )
        }

        BeforeAll {
            Mock -CommandName Set-DnsServerScavenging
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerScavenging]::new()

                $script:instance.DnsServer = 'localhost'

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerScavenging] @{
                            DnsServer          = 'localhost'
                            ScavengingState    = $true
                            ScavengingInterval = '30.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'
                        }
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
        Should -Invoke -CommandName Set-DnsServerScavenging -Exactly -Times 0 -Scope It
    }


    Context 'When the system is not in the desired state' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'ScavengingState'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'ScavengingInterval'
                    PropertyValue = '7.00:00:00'
                }
                @{
                    PropertyName  = 'RefreshInterval'
                    PropertyValue = '7.00:00:00'
                }
                @{
                    PropertyName  = 'NoRefreshInterval'
                    PropertyValue = '7.00:00:00'
                }
            )
        }

        BeforeAll {
            Mock -CommandName Set-DnsServerScavenging
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerScavenging]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerScavenging] @{
                            DnsServer          = 'localhost'
                            ScavengingState    = $true
                            ScavengingInterval = '30.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'
                        }
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
            Should -Invoke -CommandName Set-DnsServerScavenging -Exactly -Times 1 -Scope It
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
            Should -Invoke -CommandName Set-DnsServerScavenging -Exactly -Times 1 -Scope It
        }
    }
}
