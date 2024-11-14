<#
    .SYNOPSIS
        Unit test for DnsRecordBase.
#>
<#
    Must have this for the test to work where it creates a class that inherits from
    the DnsRecordBase class.
#>
using module DnsServerDsc

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
}

Describe DnsRecordBase {
    Context 'Constructors' {
        It 'Should not throw an exception when instantiated' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [DnsRecordBase]::new() } | Should -Not -Throw
            }
        }

        It 'Has a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsRecordBase]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsRecordBase' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsRecordBase]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordBase'
            }
        }
    }

    Context 'Unimplemented methods' {
        It 'Should throw when GetResourceRecord() is called' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $instance = [DnsRecordBase]::new().GetResourceRecord() } | Should -Throw
            }
        }

        It 'Should throw when AddResourceRecord() is called' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $instance = [DnsRecordBase]::new().AddResourceRecord() } | Should -Throw
            }
        }

        It 'Should throw when ModifyResourceRecord(...) is called' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $instance = [DnsRecordBase]::new().ModifyResourceRecord($null, $null) } | Should -Throw
            }
        }

        It 'Should throw when NewDscResourceObjectFromRecord(...) is called' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $instance = [DnsRecordBase]::new().NewDscResourceObjectFromRecord($null) } | Should -Throw
            }
        }
    }
}

Describe 'Testing DnsRecordBase Get Method' -Tag 'Get', 'DnsRecord', 'DnsRecordBase' {
    Context 'Testing abstract functionality' {
        BeforeAll {
            $instanceDesiredState = [DnsRecordBase] @{
                ZoneName   = 'contoso.com'
                TimeToLive = '1:00:00'
                DnsServer  = 'localhost'
                Ensure     = 'Present'
            }
        }

        It 'Should throw when Get() is called' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:instanceDesiredState.Get() } | Should -Throw
            }
        }
    }

    Context 'Testing $null value passed to Set()' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instanceDesiredState = [DnsRecordBase] @{
                    ZoneName   = 'contoso.com'
                    TimeToLive = $null
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                }
            }
        }

        It 'Should throw when Set() is called' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:instanceDesiredState.Set() } | Should -Throw
            }
        }
    }

    Context 'Testing subclassed (implemented) functionality' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                class MockRecordDoesNotExist : DnsRecordBase
                {
                    MockRecordDoesNotExist ()
                    {
                    }

                    [System.String] GetResourceRecord()
                    {
                        return (Invoke-Command {})
                    }
                }

                $script:instanceDesiredState = [MockRecordDoesNotExist] @{
                    ZoneName   = 'contoso.com'
                    TimeToLive = '1:00:00'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                }
            }
        }

        It 'Should return the state as absent' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instanceDesiredState.Get().Ensure | Should -Be 'Absent'
            }
        }

        It 'Should return the same values as present in properties' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.ZoneName | Should -Be $script:instanceDesiredState.ZoneName
                $getMethodResourceResult.TimeToLive | Should -Be $script:instanceDesiredState.TimeToLive
                $getMethodResourceResult.DnsServer | Should -Be $script:instanceDesiredState.DnsServer
            }
        }
    }

}

Describe 'Testing DnsRecordBase Set Method' -Tag 'Set', 'DnsRecord', 'DnsRecordBase' {
    Context 'Testing abstract functionality' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instanceDesiredState = [DnsRecordBase] @{
                    ZoneName   = 'contoso.com'
                    TimeToLive = '1:00:00'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                }
            }
        }

        It 'Should throw when Set() is called' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:instanceDesiredState.Set() } | Should -Throw
            }
        }
    }

    Context 'Testing subclassed (implemented) functionality' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                class MockRecordDoesNotExist : DnsRecordBase
                {
                    MockRecordDoesNotExist ()
                    {
                    }

                    [System.String] GetResourceRecord()
                    {
                        Write-Verbose 'Mock subclassed GetResourceRecord()'
                        return  (Invoke-Command {})
                    }

                    [void] AddResourceRecord()
                    {
                        Write-Verbose 'Mock subclassed AddResourceRecord()'
                    }
                }

                $script:instanceDesiredState = [MockRecordDoesNotExist] @{
                    ZoneName   = 'contoso.com'
                    TimeToLive = '1:00:00'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                }
            }
        }

        It 'Should execute without error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:instanceDesiredState.Set() } | Should -Not -Throw
            }
        }
    }
}

Describe 'Testing DnsRecordBase Test Method' -Tag 'Test', 'DnsRecord', 'DnsRecordBase' {
    Context 'Testing abstract functionality' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:instanceDesiredState = [DnsRecordBase] @{
                    ZoneName   = 'contoso.com'
                    TimeToLive = '1:00:00'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                }
            }
        }

        It 'Should throw when Test() is called' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { $script:instanceDesiredState.Test() } | Should -Throw
            }
        }
    }

    Context 'Testing subclassed (implemented) functionality' {
        Context 'When the system is in the desired state' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    class MockRecordExists : DnsRecordBase
                    {
                        MockRecordExists ()
                        {
                        }

                        [System.String] GetResourceRecord()
                        {
                            Write-Verbose 'Mock subclassed GetResourceRecord()'
                            return 'Not Null Value'
                        }

                        [MockRecordExists] NewDscResourceObjectFromRecord($record)
                        {
                            Write-Verbose 'Mock subclassed NewDscResourceObjectFromRecord()'
                            return [MockRecordExists] @{
                                ZoneName   = 'contoso.com'
                                TimeToLive = '1:00:00'
                                DnsServer  = 'localhost'
                                Ensure     = 'Present'
                            }
                        }
                    }

                    $script:instanceDesiredStateExists = [MockRecordExists] @{
                        ZoneName   = 'contoso.com'
                        TimeToLive = '1:00:00'
                        DnsServer  = 'localhost'
                        Ensure     = 'Present'
                    }
                }
            }

            Context 'When enforcing all non-mandatory parameters' {
                It 'Should return $true' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $script:instanceDesiredStateExists.Test() | Should -BeTrue
                    }
                }
            }

            Context 'When no non-mandatory parameters are enforced' {
                BeforeAll {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        class MockRecordExists : DnsRecordBase
                        {
                            MockRecordExists ()
                            {
                            }

                            [System.String] GetResourceRecord()
                            {
                                Write-Verbose 'Mock subclassed GetResourceRecord()'
                                return 'Not Null Value'
                            }

                            [MockRecordExists] NewDscResourceObjectFromRecord($record)
                            {
                                Write-Verbose 'Mock subclassed NewDscResourceObjectFromRecord()'
                                return [MockRecordExists] @{
                                    ZoneName   = 'contoso.com'
                                    TimeToLive = '1:00:00'
                                    DnsServer  = 'localhost'
                                    Ensure     = 'Present'
                                }
                            }
                        }

                        $script:instanceDesiredStateExists = [MockRecordExists] @{
                            ZoneName = 'contoso.com'
                        }
                    }
                }

                It 'Should return $true' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $script:instanceDesiredStateExists.Test() | Should -BeTrue
                    }
                }
            }
        }

        Context 'When the system is not in the desired state' {
            Context 'When a DNS record should be present' {
                BeforeAll {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        class MockRecordDoesNotExist : DnsRecordBase
                        {
                            MockRecordDoesNotExist ()
                            {
                            }

                            [System.String] GetResourceRecord()
                            {
                                Write-Verbose 'Mock subclassed GetResourceRecord()'
                                return  (Invoke-Command {})
                            }
                        }

                        $script:instanceDesiredStateDNE = [MockRecordDoesNotExist] @{
                            ZoneName   = 'contoso.com'
                            TimeToLive = '1:00:00'
                            DnsServer  = 'localhost'
                            Ensure     = 'Present'
                        }
                    }
                }

                It 'Should return $false' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $script:instanceDesiredStateDNE.Test() | Should -BeFalse
                    }
                }
            }

            Context 'When a non-mandatory property is not in desired state' {
                BeforeAll {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        class MockRecordExists : DnsRecordBase
                        {
                            MockRecordExists ()
                            {
                            }

                            [System.String] GetResourceRecord()
                            {
                                Write-Verbose 'Mock subclassed GetResourceRecord()'
                                return 'Not Null Value'
                            }

                            [MockRecordExists] NewDscResourceObjectFromRecord($record)
                            {
                                Write-Verbose 'Mock subclassed NewDscResourceObjectFromRecord()'
                                return [MockRecordExists] @{
                                    ZoneName   = 'contoso.com'
                                    TimeToLive = '1:00:00'
                                    DnsServer  = 'localhost'
                                    Ensure     = 'Present'
                                }
                            }
                        }

                        $script:instanceDesiredStateExists = [MockRecordExists] @{
                            ZoneName   = 'contoso.com'
                            TimeToLive = '2:00:00'
                        }
                    }
                }

                It 'Should return $false' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $script:instanceDesiredStateExists.Test() | Should -BeFalse
                    }
                }
            }
        }
    }
}
