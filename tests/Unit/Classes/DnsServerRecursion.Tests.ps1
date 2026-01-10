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

Describe 'DnsServerRecursion' {
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

                $mockInstance = [DnsServerRecursion]::new()
                $mockInstance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsServerRecursion' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockInstance = [DnsServerRecursion]::new()
                $mockInstance.GetType().Name | Should -Be 'DnsServerRecursion'
            }
        }
    }
}

Describe 'DnsServerRecursion\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerRecursion] @{
                    Enable            = $true
                    AdditionalTimeout = 4
                    RetryInterval     = 3
                    Timeout           = 8
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
                            Enable            = $true
                            AdditionalTimeout = [System.UInt32] 4
                            RetryInterval     = [System.UInt32] 3
                            Timeout           = [System.UInt32] 8
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

                $getResult.DnsServer | Should -Be $HostName
                $getResult.Enable | Should -BeTrue
                $getResult.AdditionalTimeout | Should -Be 4
                $getResult.RetryInterval | Should -Be 3
                $getResult.Timeout | Should -Be 8
                $getResult.Reasons | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property RetryInterval has the wrong value' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [DnsServerRecursion] @{
                        Enable            = $true
                        AdditionalTimeout = 4
                        RetryInterval     = 3
                        Timeout           = 8
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
                                Enable            = $true
                                AdditionalTimeout = [System.UInt32] 4
                                RetryInterval     = [System.UInt32] 4
                                Timeout           = [System.UInt32] 8
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

                    $getResult.DnsServer | Should -Be $HostName
                    $getResult.Enable | Should -BeTrue
                    $getResult.AdditionalTimeout | Should -Be 4
                    $getResult.RetryInterval | Should -Be 4
                    $getResult.Timeout | Should -Be 8

                    $getResult.Reasons | Should -HaveCount 1
                    $getResult.Reasons[0].Code | Should -Be 'DnsServerRecursion:DnsServerRecursion:RetryInterval'
                    $getResult.Reasons[0].Phrase | Should -Be 'The property RetryInterval should be 3, but was 4'
                }
            }
        }
    }
}

Describe 'DnsServerRecursion\Set()' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [DnsServerRecursion] @{
                DnsServer         = 'localhost'
                Enable            = $true
                AdditionalTimeout = 4
                RetryInterval     = 3
                Timeout           = 8
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

                $script:mockInstance.Set()

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
                        Property      = 'AdditionalTimeout'
                        ExpectedValue = 4
                        ActualValue   = 5
                    }
                )
            }
        }

        It 'Should call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Set()

                $script:methodModifyCallCount | Should -Be 1
                $script:methodTestCallCount | Should -Be 1
            }
        }
    }
}

Describe 'DnsServerRecursion\Test()' -Tag 'Test' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [DnsServerRecursion] @{
                DnsServer         = 'localhost'
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
                        Property      = 'AdditionalTimeout'
                        ExpectedValue = 4
                        ActualValue   = 3
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

Describe 'DnsServerRecursion\AssertProperties()' -Tag 'HiddenMember' {
    BeforeDiscovery {
        $testCases = @(
            @{
                Name      = 'AdditionalTimeout'
                GoodValue = 2
                BadValue  = 20
            }
            @{
                Name      = 'RetryInterval'
                GoodValue = 2
                BadValue  = 20
            }
            @{
                Name      = 'Timeout'
                GoodValue = 2
                BadValue  = 20
            }
        )
    }

    Context 'When the property ''<Name>'' is not correct' -ForEach $testCases {
        BeforeAll {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerRecursion] @{
                    DnsServer = 'localhost'
                }
            }
        }

        It 'Should throw the correct error when a BadValue' {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:mockInstance.AssertProperties(
                        @{
                            $Name = $BadValue
                        }
                    )
                } | Should -Throw -ExpectedMessage ('*(DSR0007)')
            }
        }

        It 'Should not throw a GoodValue' {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                {
                    $script:mockInstance.AssertProperties(
                        @{
                            $Name = $GoodValue
                        }
                    )
                } | Should -Not -Throw
            }
        }
    }
}

Describe 'DnsServerRecursion\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When object is missing in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerRecursion] @{
                    DnsServer = 'localhost'
                }
            }

            Mock -CommandName Get-DnsServerRecursion
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
                $currentState.Enable | Should -BeFalse
                $currentState.AdditionalTimeout | Should -Be 0
                $currentState.RetryInterval | Should -Be 0
                $currentState.Timeout | Should -Be 0
            }

            Should -Invoke -CommandName Get-DnsServerRecursion -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the object is present in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerRecursion] @{
                    DnsServer = 'SomeHost'
                }
            }

            Mock -CommandName Get-DnsServerRecursion -MockWith {
                return New-CimInstance -ClassName 'DnsServerRecursion' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    Enable            = $true
                    AdditionalTimeout = 4
                    RetryInterval     = 3
                    Timeout           = 8
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
                $currentState.Enable | Should -BeTrue
                $currentState.AdditionalTimeout | Should -Be 4
                $currentState.RetryInterval | Should -Be 3
                $currentState.Timeout | Should -Be 8
            }

            Should -Invoke -CommandName Get-DnsServerRecursion -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerRecursion\Modify()' -Tag 'HiddenMember' {
    Context 'When the system is not in the desired state' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName    = 'Enable'
                    SetPropertyName = 'Enable'
                    ExpectedValue   = $true
                }
                @{
                    PropertyName    = 'AdditionalTimeout'
                    SetPropertyName = 'AdditionalTimeout'
                    ExpectedValue   = 4
                }
                @{
                    PropertyName    = 'RetryInterval'
                    SetPropertyName = 'RetryInterval'
                    ExpectedValue   = 5
                }
                @{
                    PropertyName    = 'Timeout'
                    SetPropertyName = 'Timeout'
                    ExpectedValue   = 7
                }
            )
        }

        Context 'When the property <PropertyName> is not in desired state' -ForEach $testCases {
            BeforeAll {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [DnsServerRecursion] @{
                        DnsServer     = 'localhost'
                        $PropertyName = $ExpectedValue
                    }
                }

                Mock -CommandName Set-DnsServerRecursion
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

                    Should -Invoke -CommandName Set-DnsServerRecursion -ParameterFilter {
                        $PesterBoundParameters.$SetPropertyName -eq $ExpectedValue
                    } -Exactly -Times 1 -Scope It
                }
            }
        }
    }
}
