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

                $instance = [DnsServerCache]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsServerCache' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsServerCache]::new()
                $instance.GetType().Name | Should -Be 'DnsServerCache'
            }
        }
    }
}

Describe 'DnsServerCache\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerCache] @{
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
                $script:instance | Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                    return @{
                        IgnorePolicies                   = $true
                        LockingPercent                   = [System.UInt32] 100
                        MaxKBSize                        = [System.UInt32] 0
                        EnablePollutionProtection        = $true
                        StoreEmptyAuthenticationResponse = $true
                        MaxNegativeTtl                   = '00:15:00'
                        MaxTtl                           = '1.00:00:00'
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

                    $script:instance = [DnsServerCache] @{
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
                    $script:instance | Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                        return @{
                            IgnorePolicies                   = $true
                            LockingPercent                   = [System.UInt32] 100
                            MaxKBSize                        = [System.UInt32] 1000
                            EnablePollutionProtection        = $true
                            StoreEmptyAuthenticationResponse = $true
                            MaxNegativeTtl                   = '00:15:00'
                            MaxTtl                           = '1.00:00:00'
                        }
                    } -PassThru | Add-Member -Force -MemberType 'ScriptMethod' -Name 'AssertProperties' -Value {
                        return
                    }
                }
            }

            It 'Should return the correct values when Hostname is ''<HostName>''' -TestCases @(
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

Describe 'DnsServerCache\Test()' -Tag 'Test' {

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerCache]::new()
            }
        }

        Context 'When providing a invalid value for the property MaxTtl' {
            Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '235.a:00:00'
                        $script:instance.MaxTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'MaxTtl', $mockInvalidTime

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }

            Context 'When the time exceeds maximum allowed value' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '31.00:00:00'
                        $script:instance.MaxTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f 'MaxTtl', $mockInvalidTime, '30.00:00:00'

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }

            Context 'When the time is below minimum allowed value' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '-1.00:00:00'
                        $script:instance.MaxTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'MaxTtl', $mockInvalidTime, '00:00:00'

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }
        }

        Context 'When providing a invalid value for the property MaxNegativeTtl' {
            Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '235.a:00:00'
                        $script:instance.MaxNegativeTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'MaxNegativeTtl', $mockInvalidTime

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }

            Context 'When the time exceeds maximum allowed value' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '31.00:00:00'
                        $script:instance.MaxNegativeTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f 'MaxNegativeTtl', $mockInvalidTime, '30.00:00:00'

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }

            Context 'When the time is below minimum allowed value' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '00:00:00'
                        $script:instance.MaxNegativeTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'MaxNegativeTtl', $mockInvalidTime, '00:00:01'

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerCache] @{
                    IgnorePolicies                   = $true
                    LockingPercent                   = 100
                    MaxKBSize                        = 0
                    MaxNegativeTtl                   = '00:15:00'
                    MaxTtl                           = '1.00:00:00'
                    EnablePollutionProtection        = $true
                    StoreEmptyAuthenticationResponse = $true
                }

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerCache] @{
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
                    PropertyName  = 'IgnorePolicies'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'LockingPercent'
                    PropertyValue = 80
                }
                @{
                    PropertyName  = 'MaxKBSize'
                    PropertyValue = '1000'
                }
                @{
                    PropertyName  = 'MaxNegativeTtl'
                    PropertyValue = '00:30:00'
                }
                @{
                    PropertyName  = 'MaxTtl'
                    PropertyValue = '3.00:00:00'
                }
                @{
                    PropertyName  = 'EnablePollutionProtection'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'StoreEmptyAuthenticationResponse'
                    PropertyValue = $false
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerCache]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerCache] @{
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
        }

        It 'Should return $false when property <PropertyName> is not in desired state' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance.$PropertyName = $PropertyValue
                $getResult = $instance.Test()

                $getResult | Should -BeFalse
            }
        }
    }
}

Describe 'DnsServerCache\Set()' -Tag 'Set' {

    Context 'When providing an invalid interval' {
        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerCache]::new()
            }
        }

        Context 'When providing a invalid value for the property MaxTtl' {
            Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '235.a:00:00'
                        $script:instance.MaxTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'MaxTtl', $mockInvalidTime

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }

            Context 'When the time exceeds maximum allowed value' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '31.00:00:00'
                        $script:instance.MaxTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f 'MaxTtl', $mockInvalidTime, '30.00:00:00'

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }

            Context 'When the time is below minimum allowed value' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '-1.00:00:00'
                        $script:instance.MaxTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'MaxTtl', $mockInvalidTime, '00:00:00'

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }
        }

        Context 'When providing a invalid value for the property MaxNegativeTtl' {
            Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '235.a:00:00'
                        $script:instance.MaxNegativeTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'MaxNegativeTtl', $mockInvalidTime

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }

            Context 'When the time exceeds maximum allowed value' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '31.00:00:00'
                        $script:instance.MaxNegativeTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f 'MaxNegativeTtl', $mockInvalidTime, '30.00:00:00'

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }

            Context 'When the time is below minimum allowed value' {
                It 'Should throw the correct error' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $mockInvalidTime = '00:00:00'
                        $script:instance.MaxNegativeTtl = $mockInvalidTime

                        $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'MaxNegativeTtl', $mockInvalidTime, '00:00:01'

                        { $script:instance.Test() } | Should -Throw ('*' + $mockExpectedErrorMessage)
                    }
                }
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerCache
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'IgnorePolicies'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'LockingPercent'
                    PropertyValue = 100
                }
                @{
                    PropertyName  = 'MaxKBSize'
                    PropertyValue = '0'
                }
                @{
                    PropertyName  = 'MaxNegativeTtl'
                    PropertyValue = '00:15:00'
                }
                @{
                    PropertyName  = 'MaxTtl'
                    PropertyValue = '1.00:00:00'
                }
                @{
                    PropertyName  = 'EnablePollutionProtection'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'StoreEmptyAuthenticationResponse'
                    PropertyValue = $true
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerCache]::new()

                $script:instance.DnsServer = 'localhost'

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerCache] @{
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
        }

        It 'Should not call any mock to set a value for property ''<PropertyName>''' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance.$PropertyName = $PropertyValue

                { $script:instance.Set() } | Should -Not -Throw
            }
            Should -Invoke -CommandName Set-DnsServerCache -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerCache
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'IgnorePolicies'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'LockingPercent'
                    PropertyValue = 80
                }
                @{
                    PropertyName  = 'MaxKBSize'
                    PropertyValue = '1000'
                }
                @{
                    PropertyName  = 'MaxNegativeTtl'
                    PropertyValue = '00:30:00'
                }
                @{
                    PropertyName  = 'MaxTtl'
                    PropertyValue = '3.00:00:00'
                }
                @{
                    PropertyName  = 'EnablePollutionProtection'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'StoreEmptyAuthenticationResponse'
                    PropertyValue = $false
                }
            )
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerCache]::new()

                # Override Get() method
                $script:instance |
                    Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        return [DnsServerCache] @{
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
        }

        Context 'When parameter DnsServer is set to ''localhost''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instance.DnsServer = 'localhost'
                    $script:instance.$PropertyName = $PropertyValue

                    { $script:instance.Set() } | Should -Not -Throw
                }
                Should -Invoke -CommandName Set-DnsServerCache -Exactly -Times 1 -Scope It
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
                Should -Invoke -CommandName Set-DnsServerCache -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'DnsServerCache\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When object is missing in the current state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instance = [DnsServerCache] @{
                    DnsServer = 'localhost'
                }
            }
            Mock -CommandName Get-DnsServerCache
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

                $script:instance = [DnsServerCache] @{
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

                $currentState = $script:instance.GetCurrentState(
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
