<#
    .SYNOPSIS
        Unit test for DSC_DnsServerCache DSC resource.
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

Describe 'DnsServerCache' {
    Context 'Constructors' {
        It 'Should not throw an exception when instantiated' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [DnsServerCache]::new() } | Should -Not -Throw
            }
        }

        It 'Has a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockInstance = [DnsServerCache]::new()
                $mockInstance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsServerCache' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockInstance = [DnsServerCache]::new()
                $mockInstance.GetType().Name | Should -Be 'DnsServerCache'
            }
        }
    }
}

Describe 'DnsServerCache\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerCache] @{
                    IgnorePolicies                   = $true
                    LockingPercent                   = 100
                    MaxKBSize                        = 0
                    EnablePollutionProtection        = $true
                    StoreEmptyAuthenticationResponse = $true
                    MaxNegativeTtl                   = '00:15:00'
                    MaxTtl                           = '1.00:00:00'
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
                            IgnorePolicies                   = $true
                            LockingPercent                   = [System.UInt32] 100
                            MaxKBSize                        = [System.UInt32] 0
                            EnablePollutionProtection        = $true
                            StoreEmptyAuthenticationResponse = $true
                            MaxNegativeTtl                   = '00:15:00'
                            MaxTtl                           = '1.00:00:00'
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
                $script:mockInstance.GetCurrentState(
                    @{
                        DnsServer = $HostName
                    }
                )

                $getResult = $script:mockInstance.Get()

                $getResult.DnsServer | Should -Be $HostName
                $getResult.IgnorePolicies | Should -BeTrue
                $getResult.LockingPercent | Should -Be 100
                $getResult.MaxKBSize | Should -Be 0
                $getResult.EnablePollutionProtection | Should -BeTrue
                $getResult.StoreEmptyAuthenticationResponse | Should -BeTrue
                $getResult.MaxNegativeTtl | Should -Be '00:15:00'
                $getResult.MaxTtl | Should -Be '1.00:00:00'
                $getResult.Reasons | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property MaxKBSize has the wrong value' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [DnsServerCache] @{
                        IgnorePolicies                   = $true
                        LockingPercent                   = 100
                        MaxKBSize                        = 0
                        EnablePollutionProtection        = $true
                        StoreEmptyAuthenticationResponse = $true
                        MaxNegativeTtl                   = '00:15:00'
                        MaxTtl                           = '1.00:00:00'
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
                                IgnorePolicies                   = $true
                                LockingPercent                   = [System.UInt32] 100
                                MaxKBSize                        = [System.UInt32] 1000
                                EnablePollutionProtection        = $true
                                StoreEmptyAuthenticationResponse = $true
                                MaxNegativeTtl                   = '00:15:00'
                                MaxTtl                           = '1.00:00:00'
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

            It 'Should return the correct values when Hostname is ''<HostName>''' -ForEach $testCases {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance.DnsServer = $HostName
                    $script:mockInstance.GetCurrentState(
                        @{
                            DnsServer = $HostName
                        }
                    )

                    $getResult = $script:mockInstance.Get()

                    $getResult.DnsServer | Should -Be $HostName
                    $getResult.IgnorePolicies | Should -BeTrue
                    $getResult.LockingPercent | Should -Be 100
                    $getResult.MaxKBSize | Should -Be 1000
                    $getResult.EnablePollutionProtection | Should -BeTrue
                    $getResult.StoreEmptyAuthenticationResponse | Should -BeTrue
                    $getResult.MaxNegativeTtl | Should -Be '00:15:00'
                    $getResult.MaxTtl | Should -Be '1.00:00:00'

                    $getResult.Reasons | Should -HaveCount 1
                    $getResult.Reasons[0].Code | Should -Be 'DnsServerCache:DnsServerCache:MaxKBSize'
                    $getResult.Reasons[0].Phrase | Should -Be 'The property MaxKBSize should be 0, but was 1000'
                }
            }
        }
    }
}

Describe 'DnsServerCache\Set()' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [DnsServerCache] @{
                DnsServer                        = 'localhost'
                IgnorePolicies                   = $true
                LockingPercent                   = 100
                MaxKBSize                        = 0
                MaxNegativeTtl                   = '00:15:00'
                MaxTtl                           = '1.00:00:00'
                EnablePollutionProtection        = $true
                StoreEmptyAuthenticationResponse = $true
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
                        Property      = 'MaxNegativeTtl'
                        ExpectedValue = '00:15:00'
                        ActualValue   = '00:12:00'
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

Describe 'DnsServerCache\Test()' -Tag 'Test' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [DnsServerCache] @{
                DnsServer                        = 'localhost'
                IgnorePolicies                   = $true
                LockingPercent                   = 100
                MaxKBSize                        = 0
                MaxNegativeTtl                   = '00:15:00'
                MaxTtl                           = '1.00:00:00'
                EnablePollutionProtection        = $true
                StoreEmptyAuthenticationResponse = $true
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
                        Property      = 'IgnorePolicies'
                        ExpectedValue = $true
                        ActualValue   = $false
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

Describe 'DnsServerCache\AssertProperties()' -Tag 'HiddenMember' {
    BeforeDiscovery {
        $testCases = @(
            @{
                Name      = 'MaxNegativeTtl'
                BadFormat = '235.a:00:00'
                TooLow    = '00:00:00'
                TooHigh   = '31.00:00:00'
            }
            @{
                Name      = 'MaxTtl'
                BadFormat = '235.a:00:00'
                TooLow    = '-1.00:00:00'
                TooHigh   = '31.00:00:00'
            }
        )
    }

    Context 'When the property ''<Name>'' is not correct' -ForEach $testCases {
        BeforeAll {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerCache] @{
                    DnsServer = 'localhost'
                }
            }

            Mock -CommandName Assert-TimeSpan
        }

        It 'Should throw the correct error when a bad format' {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:mockInstance.AssertProperties(@{ $Name = $BadFormat }) } | Should -Not -Throw
            }

            Should -Invoke -CommandName Assert-TimeSpan -Exactly -Times 1 -Scope It
        }

        It 'Should throw the correct error when too small' -Skip:([System.String]::IsNullOrEmpty($TooLow)) {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:mockInstance.AssertProperties(@{ $Name = $TooLow }) } | Should -Not -Throw
            }

            Should -Invoke -CommandName Assert-TimeSpan -Exactly -Times 1 -Scope It
        }

        It 'Should throw the correct error when too big' -Skip:([System.String]::IsNullOrEmpty($TooHigh)) {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:mockInstance.AssertProperties(@{ $Name = $TooHigh }) } | Should -Not -Throw
            }

            Should -Invoke -CommandName Assert-TimeSpan -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerCache\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When object is missing in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerCache] @{
                    DnsServer = 'localhost'
                }
            }

            Mock -CommandName Get-DnsServerCache
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
                $currentState.IgnorePolicies | Should -BeFalse
                $currentState.LockingPercent | Should -Be 0
                $currentState.MaxKBSize | Should -Be 0
                $currentState.MaxNegativeTtl | Should -BeNullOrEmpty
                $currentState.MaxTtl | Should -BeNullOrEmpty
                $currentState.EnablePollutionProtection | Should -BeFalse
                $currentState.StoreEmptyAuthenticationResponse | Should -BeFalse
            }

            Should -Invoke -CommandName Get-DnsServerCache -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the object is present in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerCache] @{
                    DnsServer = 'SomeHost'
                }
            }

            Mock -CommandName Get-DnsServerCache -MockWith {
                return New-CimInstance -ClassName 'DnsServerCache' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    IgnorePolicies                   = $true
                    LockingPercent                   = 100
                    MaxKBSize                        = 0
                    MaxNegativeTtl                   = '00:15:00'
                    MaxTtl                           = '1.00:00:00'
                    EnablePollutionProtection        = $true
                    StoreEmptyAuthenticationResponse = $true
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
                $currentState.IgnorePolicies | Should -BeTrue
                $currentState.LockingPercent | Should -Be 100
                $currentState.MaxKBSize | Should -Be 0
                $currentState.MaxNegativeTtl | Should -Be '00:15:00'
                $currentState.MaxTtl | Should -Be '1.00:00:00'
                $currentState.EnablePollutionProtection | Should -BeTrue
                $currentState.StoreEmptyAuthenticationResponse | Should -BeTrue
            }

            Should -Invoke -CommandName Get-DnsServerCache -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerCache\Modify()' -Tag 'HiddenMember' {
    Context 'When the system is not in the desired state' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName    = 'IgnorePolicies'
                    SetPropertyName = 'IgnorePolicies'
                    ExpectedValue   = $true
                }
                @{
                    PropertyName    = 'LockingPercent'
                    SetPropertyName = 'LockingPercent'
                    ExpectedValue   = 100
                }
                @{
                    PropertyName    = 'MaxKBSize'
                    SetPropertyName = 'MaxKBSize'
                    ExpectedValue   = 0
                }
                @{
                    PropertyName    = 'MaxNegativeTtl'
                    SetPropertyName = 'MaxNegativeTtl'
                    ExpectedValue   = '00:15:00'
                }
                @{
                    PropertyName    = 'MaxTtl'
                    SetPropertyName = 'MaxTtl'
                    ExpectedValue   = '1.00:00:00'
                }
                @{
                    PropertyName    = 'EnablePollutionProtection'
                    SetPropertyName = 'PollutionProtection'
                    ExpectedValue   = $true
                }
                @{
                    PropertyName    = 'StoreEmptyAuthenticationResponse'
                    SetPropertyName = 'StoreEmptyAuthenticationResponse'
                    ExpectedValue   = $true
                }
            )
        }

        Context 'When the property <PropertyName> is not in desired state' -ForEach $testCases {
            BeforeAll {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [DnsServerCache] @{
                        DnsServer     = 'localhost'
                        $PropertyName = $ExpectedValue
                    }
                }

                Mock -CommandName Set-DnsServerCache
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

                    Should -Invoke -CommandName Set-DnsServerCache -ParameterFilter {
                        $PesterBoundParameters.$SetPropertyName -eq $ExpectedValue
                    } -Exactly -Times 1 -Scope It
                }
            }
        }
    }
}
