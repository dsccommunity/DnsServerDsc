<#
    .SYNOPSIS
        Unit test for DSC_DnsServerDsSetting DSC resource.
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

Describe 'DnsServerDsSetting\AssertProperties()' -Tag 'HiddenMember' {

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerDsSetting]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '235.a:00:00'
                    $script:instance.DirectoryPartitionAutoEnlistInterval = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'DirectoryPartitionAutoEnlistInterval', $mockInvalidTime


                    { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                }
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockInvalidTime = '-1.00:00:00'
                    $script:instance.TombstoneInterval = $mockInvalidTime

                    $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'TombstoneInterval', $mockInvalidTime, '00:00:00'

                    { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                }
            }
        }
    }
}

Describe 'DnsServerDsSetting\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerDsSetting -MockWith {
                return New-CimInstance -ClassName 'DnsServerDsSetting' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                    LazyUpdateInterval                   = 3
                    MinimumBackgroundLoadThreads         = 1
                    PollingInterval                      = 180
                    RemoteReplicationDelay               = 30
                    TombstoneInterval                    = '14.00:00:00'
                }
            }
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerDsSetting]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance | Should -Not -BeNullOrEmpty
                $script:instance.GetType().Name | Should -Be 'DnsServerDsSetting'
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

                $getResult.DirectoryPartitionAutoEnlistInterval | Should -Be '1.00:00:00'
                $getResult.LazyUpdateInterval | Should -Be 3
                $getResult.MinimumBackgroundLoadThreads | Should -Be 1
                $getResult.PollingInterval | Should -Be 180
                $getResult.RemoteReplicationDelay | Should -Be 30
                $getResult.TombstoneInterval | Should -Be '14.00:00:00'
            }
            Should -Invoke -CommandName Get-DnsServerDsSetting -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerDsSetting\Test()' -Tag 'Test' {

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerDsSetting]::new()

                $script:instance.DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                $script:instance.LazyUpdateInterval = 3
                $script:instance.MinimumBackgroundLoadThreads = 1
                $script:instance.PollingInterval = 180
                $script:instance.RemoteReplicationDelay = 30
                $script:instance.TombstoneInterval = '14.00:00:00'

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerDsSetting] @{
                            DnsServer                            = 'localhost'
                            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                            LazyUpdateInterval                   = 3
                            MinimumBackgroundLoadThreads         = 1
                            PollingInterval                      = 180
                            RemoteReplicationDelay               = 30
                            TombstoneInterval                    = '14.00:00:00'
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
                    PropertyName  = 'DirectoryPartitionAutoEnlistInterval'
                    PropertyValue = '2.00:00:00'
                }
                @{
                    PropertyName  = 'LazyUpdateInterval'
                    PropertyValue = 1
                }
                @{
                    PropertyName  = 'MinimumBackgroundLoadThreads'
                    PropertyValue = 0
                }
                @{
                    PropertyName  = 'PollingInterval'
                    PropertyValue = 0
                }
                @{
                    PropertyName  = 'RemoteReplicationDelay'
                    PropertyValue = 0
                }
                @{
                    PropertyName  = 'TombstoneInterval'
                    PropertyValue = '01:00:00'
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerDsSetting]::new()


                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerDsSetting] @{
                            DnsServer                            = 'localhost'
                            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                            LazyUpdateInterval                   = 3
                            MinimumBackgroundLoadThreads         = 1
                            PollingInterval                      = 180
                            RemoteReplicationDelay               = 30
                            TombstoneInterval                    = '14.00:00:00'
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

Describe 'DnsServerDsSetting\Set()' -Tag 'Set' {

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerDsSetting
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'DirectoryPartitionAutoEnlistInterval'
                    PropertyValue = '1.00:00:00'
                }
                @{
                    PropertyName  = 'LazyUpdateInterval'
                    PropertyValue = 3
                }
                @{
                    PropertyName  = 'MinimumBackgroundLoadThreads'
                    PropertyValue = 1
                }
                @{
                    PropertyName  = 'PollingInterval'
                    PropertyValue = 180
                }
                @{
                    PropertyName  = 'RemoteReplicationDelay'
                    PropertyValue = 30
                }
                @{
                    PropertyName  = 'TombstoneInterval'
                    PropertyValue = '14.00:00:00'
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerDsSetting]::new()


                $script:instance.DnsServer = 'localhost'

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerDsSetting] @{
                            DnsServer                            = 'localhost'
                            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                            LazyUpdateInterval                   = 3
                            MinimumBackgroundLoadThreads         = 1
                            PollingInterval                      = 180
                            RemoteReplicationDelay               = 30
                            TombstoneInterval                    = '14.00:00:00'
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
            Should -Invoke -CommandName Set-DnsServerDsSetting -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerDsSetting
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'DirectoryPartitionAutoEnlistInterval'
                    PropertyValue = '2.00:00:00'
                }
                @{
                    PropertyName  = 'LazyUpdateInterval'
                    PropertyValue = 1
                }
                @{
                    PropertyName  = 'MinimumBackgroundLoadThreads'
                    PropertyValue = 0
                }
                @{
                    PropertyName  = 'PollingInterval'
                    PropertyValue = 0
                }
                @{
                    PropertyName  = 'RemoteReplicationDelay'
                    PropertyValue = 0
                }
                @{
                    PropertyName  = 'TombstoneInterval'
                    PropertyValue = '01:00:00'
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0
                $script:instance = [DnsServerDsSetting]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerDsSetting] @{
                            DnsServer                            = 'localhost'
                            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                            LazyUpdateInterval                   = 3
                            MinimumBackgroundLoadThreads         = 1
                            PollingInterval                      = 180
                            RemoteReplicationDelay               = 30
                            TombstoneInterval                    = '14.00:00:00'
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
                Should -Invoke -CommandName Set-DnsServerDsSetting -Exactly -Times 1 -Scope It
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
                Should -Invoke -CommandName Set-DnsServerDsSetting -Exactly -Times 1 -Scope It
            }
        }
    }
}
