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

Describe 'DnsServerScavenging' {
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

                $mockInstance = [DnsServerScavenging]::new()
                $mockInstance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsServerScavenging' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockInstance = [DnsServerScavenging]::new()
                $mockInstance.GetType().Name | Should -Be 'DnsServerScavenging'
            }
        }
    }
}

Describe 'DnsServerScavenging\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerScavenging] @{
                    ScavengingState    = $true
                    ScavengingInterval = '30.00:00:00'
                    RefreshInterval    = '30.00:00:00'
                    NoRefreshInterval  = '30.00:00:00'
                }

                <#
                This mocks the method GetCurrentState().

                    Method Get() will call the base method Get() which will
                    call back to the derived class method GetCurrentState()
                    to get the result to return from the derived method Get().
                #>
                $script:mockInstance | Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                    return @{
                        ScavengingState    = $true
                        ScavengingInterval = '30.00:00:00'
                        RefreshInterval    = '30.00:00:00'
                        NoRefreshInterval  = '30.00:00:00'
                        LastScavengeTime   = '2021-01-01 00:00:00'

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

                $script:mockInstance.DnsServer = $HostName
                $script:mockInstance.GetCurrentState(
                    @{
                        DnsServer = $HostName
                    }
                )

                $getResult = $script:mockInstance.Get()

                $getResult.DnsServer | Should -Be $HostName
                $getResult.ScavengingState | Should -BeTrue
                $getResult.ScavengingInterval | Should -Be '30.00:00:00'
                $getResult.RefreshInterval | Should -Be '30.00:00:00'
                $getResult.NoRefreshInterval | Should -Be '30.00:00:00'
                # Returns as a DateTime type and not a string.
                $getResult.LastScavengeTime.ToString('yyyy-mm-dd HH:mm:ss') | Should -Be ([System.DateTime] '2021-01-01 00:00:00').ToString('yyyy-mm-dd HH:mm:ss')
                $getResult.Reasons | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property ScavengingInterval has the wrong value' {

            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [DnsServerScavenging] @{
                        ScavengingState    = $true
                        ScavengingInterval = '30.00:00:00'
                        RefreshInterval    = '30.00:00:00'
                        NoRefreshInterval  = '30.00:00:00'
                    }

                    <#
                This mocks the method GetCurrentState().

                    Method Get() will call the base method Get() which will
                    call back to the derived class method GetCurrentState()
                    to get the result to return from the derived method Get().
                #>
                    $script:mockInstance | Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                        return @{
                            ScavengingState    = $true
                            ScavengingInterval = '40.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'

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

                    $script:mockInstance.DnsServer = $HostName
                    $script:mockInstance.GetCurrentState(
                        @{
                            DnsServer = $HostName
                        }
                    )

                    $getResult = $script:mockInstance.Get()

                    $getResult.DnsServer | Should -Be $HostName
                    $getResult.ScavengingState | Should -BeTrue
                    $getResult.ScavengingInterval | Should -Be '40.00:00:00'
                    $getResult.RefreshInterval | Should -Be '30.00:00:00'
                    $getResult.NoRefreshInterval | Should -Be '30.00:00:00'
                    # Returns as a DateTime type and not a string.
                    $getResult.LastScavengeTime.ToString('yyyy-mm-dd HH:mm:ss') | Should -Be ([System.DateTime] '2021-01-01 00:00:00').ToString('yyyy-mm-dd HH:mm:ss')

                    $getResult.Reasons | Should -HaveCount 1
                    $getResult.Reasons[0].Code | Should -Be 'DnsServerScavenging:DnsServerScavenging:ScavengingInterval'
                    $getResult.Reasons[0].Phrase | Should -Be 'The property ScavengingInterval should be "30.00:00:00", but was "40.00:00:00"'
                }
            }
        }
    }
}

Describe 'DnsServerScavenging\Set()' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [DnsServerScavenging] @{
                ScavengingState    = $true
                ScavengingInterval = '30.00:00:00'
                RefreshInterval    = '30.00:00:00'
                NoRefreshInterval  = '30.00:00:00'
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
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Compare() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Compare' -Value {
                        return $null
                    } -PassThru |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'AssertProperties' -Value {
                        return
                    }
            }
        }

        It 'Should not call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Set()

                $script:methodModifyCallCount | Should -Be 0
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Compare() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Compare' -Value {
                        return @{
                            Property      = 'ScavengingInterval'
                            ExpectedValue = '30.00:00:00'
                            ActualValue   = '14.00:00:00'
                        }
                    } -PassThru |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'AssertProperties' -Value {
                        return
                    }
            }
        }

        It 'Should call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Set()

                $script:methodModifyCallCount | Should -Be 1
            }
        }
    }
}

Describe 'DnsServerScavenging\Test()' -Tag 'Test' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [DnsServerScavenging] @{
                ScavengingState    = $true
                ScavengingInterval = '30.00:00:00'
                RefreshInterval    = '30.00:00:00'
                NoRefreshInterval  = '30.00:00:00'
            }
        }
    }
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Compare() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Compare' -Value {
                        return $null
                    } -PassThru |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'AssertProperties' -Value {
                        return
                    }
            }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Test() | Should -BeTrue
            }
        }

        Context 'When the system is not in the desired state' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance |
                        # Mock method Compare() which is called by the base method Set()
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Compare' -Value {
                            return @{
                                DnsServer          = 'localhost'
                                ScavengingState    = $false
                                ScavengingInterval = '10.00:00:00'
                                RefreshInterval    = '20.00:00:00'
                                NoRefreshInterval  = '25.00:00:00'
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'AssertProperties' -Value {
                            return
                        }
                }
            }

            It 'Should return $false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance.Test() | Should -BeFalse
                }
            }
        }
    }
}

Describe 'DnsServerScavenging\AssertProperties()' -Tag 'HiddenMember' {
    Context 'When the property ''<Name>'' is not correct' -ForEach @(
        @{
            Name      = 'ScavengingInterval'
            BadFormat = '235.a:00:00'
            TooLow    = '-1.00:00:00'
            TooHigh   = '366.00:00:00'
        }
        @{
            Name      = 'RefreshInterval'
            BadFormat = '235.a:00:00'
            TooLow    = '-1.00:00:00'
            TooHigh   = '366.00:00:00'
        }
        @{
            Name      = 'RefreshInterval'
            BadFormat = '235.a:00:00'
            TooLow    = '-1.00:00:00'
            TooHigh   = '366.00:00:00'
        }
    ) {
        BeforeAll {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerScavenging] @{
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

Describe 'DnsServerScavenging\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When object is missing in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerScavenging] @{
                    DnsServer = 'localhost'
                }
            }
            Mock -CommandName Get-DnsServerScavenging
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
                $currentState.ScavengingState | Should -BeFalse
                $currentState.ScavengingInterval | Should -BeNullOrEmpty
                $currentState.RefreshInterval | Should -BeNullOrEmpty
                $currentState.NoRefreshInterval | Should -BeNullOrEmpty
                $currentState.LastScavengeTime | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-DnsServerScavenging -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the object is present in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [DnsServerScavenging] @{
                    DnsServer = 'SomeHost'
                }
            }
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

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        DnsServer = 'SomeHost'
                    }
                )

                $currentState.DnsServer | Should -Be 'SomeHost'
                $currentState.ScavengingState | Should -BeTrue
                $currentState.ScavengingInterval | Should -Be '30.00:00:00'
                $currentState.RefreshInterval | Should -Be '30.00:00:00'
                $currentState.NoRefreshInterval | Should -Be '30.00:00:00'
                $currentState.LastScavengeTime | Should -Be '2021-01-01 00:00:00'
            }

            Should -Invoke -CommandName Get-DnsServerScavenging -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerScavenging\Modify()' -Tag 'HiddenMember' {
    Context 'When the system is not in the desired state' {
        Context 'When the property <PropertyName> is not in desired state' -ForEach @(
            @{
                PropertyName    = 'ScavengingState'
                SetPropertyName = 'ScavengingState'
                ExpectedValue   = $true
            }
            @{
                PropertyName    = 'ScavengingInterval'
                SetPropertyName = 'ScavengingInterval'
                ExpectedValue   = '10.00:00:00'
            }
            @{
                PropertyName    = 'RefreshInterval'
                SetPropertyName = 'RefreshInterval'
                ExpectedValue   = '20.00:00:00'
            }
            @{
                PropertyName    = 'NoRefreshInterval'
                SetPropertyName = 'NoRefreshInterval'
                ExpectedValue   = '25.00:00:00'
            }
        ) {
            BeforeAll {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [DnsServerScavenging] @{
                        DnsServer     = 'localhost'
                        $PropertyName = $ExpectedValue
                    } |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'AssertProperties' -Value {
                            return
                        } -PassThru
                }
                Mock -CommandName Set-DnsServerScavenging
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

                    Should -Invoke -CommandName Set-DnsServerScavenging -ParameterFilter {
                        $PesterBoundParameters.$SetPropertyName -eq $ExpectedValue
                    } -Exactly -Times 1 -Scope It
                }
            }
        }
    }
}
