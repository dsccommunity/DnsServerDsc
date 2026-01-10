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
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
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

Describe 'DnsServerDsSetting' {
    Context 'Constructors' {
        It 'Should not throw an exception when instantiated' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [DnsServerDsSetting]::new() } | Should -Not -Throw
            }
        }

        It 'Has a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockInstance = [DnsServerDsSetting]::new()
                $mockInstance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsServerDsSetting' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockInstance = [DnsServerDsSetting]::new()
                $mockInstance.GetType().Name | Should -Be 'DnsServerDsSetting'
            }
        }
    }
}

Describe 'DnsServerDsSetting\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerDsSetting] @{
                    DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                    LazyUpdateInterval                   = 3
                    MinimumBackgroundLoadThreads         = 1
                    PollingInterval                      = 180
                    RemoteReplicationDelay               = 30
                    TombstoneInterval                    = '14.00:00:00'
                }

                <#
                This mocks the method GetCurrentState().

                    Method Get() will call the base method Get() which will
                    call back to the derived class method GetCurrentState()
                    to get the result to return from the derived method Get().
                #>
                $script:mockInstance |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                        return @{
                            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                            LazyUpdateInterval                   = [System.UInt32] 3
                            MinimumBackgroundLoadThreads         = [System.UInt32] 1
                            PollingInterval                      = [System.String] 180
                            RemoteReplicationDelay               = [System.UInt32] 30
                            TombstoneInterval                    = '14.00:00:00'
                        }
                    } -PassThru |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                        return
                    } -PassThru |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                        return
                    } -PassThru
            }
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    HostName = 'localhost'
                }
                @{
                    HostName = 'dns.company.local'
                }
            )
        }

        It 'Should return the correct values for the properties when DnsServer is set to ''<HostName>''' -ForEach $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.DnsServer = $HostName

                $getResult = $script:mockInstance.Get()

                $getResult.DirectoryPartitionAutoEnlistInterval | Should -Be '1.00:00:00'
                $getResult.LazyUpdateInterval | Should -Be 3
                $getResult.MinimumBackgroundLoadThreads | Should -Be 1
                $getResult.PollingInterval | Should -Be 180
                $getResult.RemoteReplicationDelay | Should -Be 30
                $getResult.TombstoneInterval | Should -Be '14.00:00:00'
                $getResult.Reasons | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property RemoteReplicationDelay has the wrong value' {
            BeforeDiscovery {
                $testCases = @(
                    @{
                        HostName = 'localhost'
                    }
                    @{
                        HostName = 'dns.company.local'
                    }
                )
            }

            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [DnsServerDsSetting] @{
                        DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                        LazyUpdateInterval                   = 3
                        MinimumBackgroundLoadThreads         = 1
                        PollingInterval                      = 180
                        RemoteReplicationDelay               = 30
                        TombstoneInterval                    = '14.00:00:00'
                    }

                    <#
                This mocks the method GetCurrentState().

                    Method Get() will call the base method Get() which will
                    call back to the derived class method GetCurrentState()
                    to get the result to return from the derived method Get().
                #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{
                                DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                                LazyUpdateInterval                   = [System.UInt32] 3
                                MinimumBackgroundLoadThreads         = [System.UInt32] 1
                                PollingInterval                      = [System.String] 180
                                RemoteReplicationDelay               = [System.UInt32] 60
                                TombstoneInterval                    = '14.00:00:00'
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values for the properties when DnsServer is set to ''<HostName>''' -ForEach $testCases {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance.DnsServer = $HostName

                    $getResult = $script:mockInstance.Get()

                    $getResult.DirectoryPartitionAutoEnlistInterval | Should -Be '1.00:00:00'
                    $getResult.LazyUpdateInterval | Should -Be 3
                    $getResult.MinimumBackgroundLoadThreads | Should -Be 1
                    $getResult.PollingInterval | Should -Be 180
                    $getResult.RemoteReplicationDelay | Should -Be 60
                    $getResult.TombstoneInterval | Should -Be '14.00:00:00'

                    $getResult.Reasons | Should -HaveCount 1
                    $getResult.Reasons[0].Code | Should -Be 'DnsServerDsSetting:DnsServerDsSetting:RemoteReplicationDelay'
                    $getResult.Reasons[0].Phrase | Should -Be 'The property RemoteReplicationDelay should be 30, but was 60'
                }
            }
        }
    }
}

Describe 'DnsServerDsSetting\Set()' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [DnsServerDsSetting] @{
                DnsServer                            = 'localhost'
                DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                LazyUpdateInterval                   = 3
                MinimumBackgroundLoadThreads         = 1
                PollingInterval                      = 180
                RemoteReplicationDelay               = 30
                TombstoneInterval                    = '14.00:00:00'
            } |
                # Mock method Modify which is called by the case method Set().
                Add-Member -Force -MemberType 'ScriptMethod' -Name 'Modify' -Value {
                    $script:methodModifyCallCount += 1
                } -PassThru
        }
    }

    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:methodModifyCallCount = 0
            $script:methodTestCallCount = 0
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Test() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
                        $script:methodTestCallCount += 1
                        return $true
                    }
            }
        }

        It 'Should not call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = $script:mockInstance.Set()

                $script:methodModifyCallCount | Should -Be 0
                $script:methodTestCallCount | Should -Be 1
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Test() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
                        $script:methodTestCallCount += 1
                        return $false
                    }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'TombstoneInterval'
                        ExpectedValue = '14.00:00:00'
                        ActualValue   = '7.00:00:00'
                    }
                )
            }
        }

        It 'Should call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = $script:mockInstance.Set()

                $script:methodModifyCallCount | Should -Be 1
                $script:methodTestCallCount | Should -Be 1
            }
        }
    }
}

Describe 'DnsServerDsSetting\Test()' -Tag 'Test' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [DnsServerDsSetting] @{
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

            $script:mockMethodGetCallCount = 0
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Get() which is called by the base method Test()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
                        $script:mockMethodGetCallCount += 1
                    }
            }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Test() | Should -BeTrue

                $script:mockMethodGetCallCount | Should -Be 1
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Get() which is called by the base method Test()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
                        $script:mockMethodGetCallCount += 1

                    }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'TombstoneInterval'
                        ExpectedValue = '14.00:00:00'
                        ActualValue   = '7.00:00:00'
                    }
                )
            }
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Test() | Should -BeFalse

                $script:mockMethodGetCallCount | Should -Be 1
            }
        }
    }
}

Describe 'DnsServerDsSetting\AssertProperties()' -Tag 'HiddenMember' {
    BeforeDiscovery {
        $testCases = @(
            @{
                Name      = 'DirectoryPartitionAutoEnlistInterval'
                BadFormat = '235.a:00:00'
                TooLow    = '-01:00:00'
                TooHigh   = ''
            }
            @{
                Name      = 'TombstoneInterval'
                BadFormat = '235.a:00:00'
                TooLow    = '-1.00:00:00'
                TooHigh   = ''
            }
        )
    }

    Context 'When the property ''<Name>'' is not correct' -ForEach $testCases {
        BeforeAll {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerDsSetting] @{
                    DnsServer = 'localhost'
                }
            }

            Mock -CommandName Assert-TimeSpan
        }

        It 'Should throw the correct error when a bad format' {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:mockInstance.AssertProperties(
                        @{
                            $Name = $BadFormat
                        }
                    )
                } | Should -Not -Throw
            }

            Should -Invoke -CommandName Assert-TimeSpan -Exactly -Times 1 -Scope It
        }

        It 'Should throw the correct error when too small' -Skip:([System.String]::IsNullOrEmpty($TooLow)) {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:mockInstance.AssertProperties(
                        @{
                            $Name = $TooLow
                        }
                    )
                } | Should -Not -Throw
            }

            Should -Invoke -CommandName Assert-TimeSpan -Exactly -Times 1 -Scope It
        }

        It 'Should throw the correct error when too big' -Skip:([System.String]::IsNullOrEmpty($TooHigh)) {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:mockInstance.AssertProperties(
                        @{
                            $Name = $TooHigh
                        }
                    )
                } | Should -Not -Throw
            }

            Should -Invoke -CommandName Assert-TimeSpan -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerDsSetting\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When object is missing in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerDsSetting] @{
                    DnsServer = 'localhost'
                }
            }
            Mock -CommandName Get-DnsServerDsSetting
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        DnsServer = 'localhost'
                    }
                )

                $currentState.DnsServer | Should -Be 'localhost'
                $currentState.DirectoryPartitionAutoEnlistInterval | Should -BeNullOrEmpty
                $currentState.LazyUpdateInterval | Should -Be 0
                $currentState.MinimumBackgroundLoadThreads | Should -Be 0
                $currentState.PollingInterval | Should -BeNullOrEmpty
                $currentState.RemoteReplicationDelay | Should -Be 0
                $currentState.TombstoneInterval | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-DnsServerDsSetting -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the object is present in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerDsSetting] @{
                    DnsServer = 'SomeHost'
                }
            }
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

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        DnsServer = 'SomeHost'
                    }
                )

                $currentState.DnsServer | Should -Be 'SomeHost'
                $currentState.DirectoryPartitionAutoEnlistInterval | Should -Be '1.00:00:00'
                $currentState.LazyUpdateInterval | Should -Be 3
                $currentState.MinimumBackgroundLoadThreads | Should -Be 1
                $currentState.PollingInterval | Should -Be 180
                $currentState.RemoteReplicationDelay | Should -Be 30
                $currentState.TombstoneInterval | Should -Be '14.00:00:00'
            }

            Should -Invoke -CommandName Get-DnsServerDsSetting -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerDsSetting\Modify()' -Tag 'HiddenMember' {
    Context 'When the system is not in the desired state' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName    = 'DirectoryPartitionAutoEnlistInterval'
                    SetPropertyName = 'DirectoryPartitionAutoEnlistInterval'
                    ExpectedValue   = '1.00:00:00'
                }
                @{
                    PropertyName    = 'LazyUpdateInterval'
                    SetPropertyName = 'LazyUpdateInterval'
                    ExpectedValue   = 3
                }
                @{
                    PropertyName    = 'MinimumBackgroundLoadThreads'
                    SetPropertyName = 'MinimumBackgroundLoadThreads'
                    ExpectedValue   = 1
                }
                @{
                    PropertyName    = 'PollingInterval'
                    SetPropertyName = 'PollingInterval'
                    ExpectedValue   = 180
                }
                @{
                    PropertyName    = 'RemoteReplicationDelay'
                    SetPropertyName = 'RemoteReplicationDelay'
                    ExpectedValue   = 30
                }
                @{
                    PropertyName    = 'TombstoneInterval'
                    SetPropertyName = 'TombstoneInterval'
                    ExpectedValue   = '14.00:00:00'
                }
            )
        }

        Context 'When the property <PropertyName> is not in desired state' -ForEach $testCases {
            BeforeAll {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [DnsServerDsSetting] @{
                        DnsServer     = 'localhost'
                        $PropertyName = $ExpectedValue
                    }
                }

                Mock -CommandName Set-DnsServerDsSetting
            }

            It 'Should call the correct mocks' {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance.Modify(
                        # This is the properties not in desired state.
                        @{
                            $PropertyName = $ExpectedValue
                        }
                    )

                    Should -Invoke -CommandName Set-DnsServerDsSetting -ParameterFilter {
                        $PesterBoundParameters.$SetPropertyName -eq $ExpectedValue
                    } -Exactly -Times 1 -Scope It
                }
            }
        }
    }
}
