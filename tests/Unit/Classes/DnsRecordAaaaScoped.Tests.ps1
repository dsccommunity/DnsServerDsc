<#
    .SYNOPSIS
        Unit test for DSC_DnsRecordAaaaScoped DSC resource.
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

Describe DnsRecordAaaaScoped -Tag 'DnsRecord', 'DnsRecordAaaaScoped' {
    Context 'Constructors' {
        It 'Should not throw an exception when instantiate' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [DnsRecordAaaaScoped]::new() } | Should -Not -Throw
            }
        }

        It 'Has a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsRecordAaaaScoped]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsRecordAaaaScoped' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsRecordAaaaScoped]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordAaaaScoped'
            }
        }
    }
}

Describe 'Testing DnsRecordAaaaScoped Get Method' -Tag 'Get', 'DnsRecord', 'DnsRecordAaaaScoped' {
    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:instanceDesiredState = [DnsRecordAaaaScoped] @{
                ZoneName    = 'contoso.com'
                ZoneScope   = 'external'
                Name        = 'www'
                IPv6Address = '2001:db8:85a3::8a2e:370:7334'
            }
        }
    }

    Context 'When the configuration is absent' {
        BeforeAll {
            Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                Write-Verbose -Message 'Mock Get-DnsServerResourceRecord Called' -Verbose
            }
        }

        It 'Should return the state as absent' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:instanceDesiredState.Get()

                $currentState.Ensure | Should -Be 'Absent'
            }

            Should -Invoke Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
        }

        It 'Should return the same values as present in Key properties' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.ZoneName | Should -Be $script:instanceDesiredState.ZoneName
                $getMethodResourceResult.ZoneScope | Should -Be $script:instanceDesiredState.ZoneScope
                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
                $getMethodResourceResult.IPv6Address | Should -Be $script:instanceDesiredState.IPv6Address
            }
        }

        It 'Should return $false or $null respectively for the rest of the non-key properties' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.TimeToLive | Should -BeNullOrEmpty
                $getMethodResourceResult.DnsServer | Should -Be 'localhost'
            }
        }
    }

    Context 'When the configuration is present' {
        BeforeAll {
            $mockInstancesPath = Resolve-Path -Path $PSScriptRoot

            Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                Write-Verbose -Message 'Mock Get-DnsServerResourceRecord Called' -Verbose

                return Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\AaaaRecordInstance.xml"
            }
        }

        It 'Should return the state as present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:instanceDesiredState.Get()

                $currentState.Ensure | Should -Be 'Present'
            }

            Should -Invoke Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
        }

        It 'Should return the same values as present in Key properties' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
                $getMethodResourceResult.IPv6Address | Should -Be $script:instanceDesiredState.IPv6Address
            }
        }
    }

}

Describe 'Testing DnsRecordAaaaScoped Test Method' -Tag 'Test', 'DnsRecord', 'DnsRecordAaaaScoped' {
    Context 'When the system is in the desired state' {
        Context 'When the configuration are absent' {
            BeforeEach {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState = [DnsRecordAaaaScoped] @{
                        ZoneName    = 'contoso.com'
                        ZoneScope   = 'external'
                        Name        = 'www'
                        IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                        Ensure      = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordAaaaScoped] @{
                            ZoneName    = 'contoso.com'
                            ZoneScope   = 'external'
                            Name        = 'www'
                            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                            Ensure      = [Ensure]::Absent
                        }

                        return $mockInstanceCurrentState
                    }
                }
            }

            It 'Should return $true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState.Test() | Should -BeTrue
                }
            }
        }

        Context 'When the configuration are present' {
            BeforeEach {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState = [DnsRecordAaaaScoped] @{
                        ZoneName    = 'contoso.com'
                        ZoneScope   = 'external'
                        Name        = 'www'
                        IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                    }

                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordAaaaScoped] @{
                            ZoneName    = 'contoso.com'
                            ZoneScope   = 'external'
                            Name        = 'www'
                            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                            Ensure      = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }
                }
            }

            It 'Should return $true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState.Test() | Should -BeTrue
                }
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When the configuration should be absent' {
            BeforeEach {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState = [DnsRecordAaaaScoped] @{
                        ZoneName    = 'contoso.com'
                        ZoneScope   = 'external'
                        Name        = 'www'
                        IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                        Ensure      = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordAaaaScoped] @{
                            ZoneName    = 'contoso.com'
                            ZoneScope   = 'external'
                            Name        = 'www'
                            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                            Ensure      = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }
                }
            }

            It 'Should return $false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }
        }

        Context 'When the configuration should be present' {
            BeforeEach {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState = [DnsRecordAaaaScoped] @{
                        ZoneName    = 'contoso.com'
                        ZoneScope   = 'external'
                        Name        = 'www'
                        IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                        TimeToLive  = '1:00:00'
                        Ensure      = [Ensure]::Present
                    }
                }
            }

            BeforeDiscovery {
                $testCasesToFail = @(
                    @{
                        ZoneName    = 'contoso.com'
                        ZoneScope   = 'external'
                        Name        = 'www'
                        IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                        DnsServer   = 'localhost'
                        TimeToLive  = '02:00:00' # Undesired
                        Ensure      = 'Present'
                    }
                )
            }

            It 'Should return $false when the object is not found' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordAaaaScoped] @{
                            ZoneName    = 'contoso.com'
                            ZoneScope   = 'external'
                            Name        = 'www'
                            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                            Ensure      = [Ensure]::Absent
                        }

                        return $mockInstanceCurrentState
                    }
                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }

            It 'Should return $false when non-key values are not in the desired state.' -TestCases $testCasesToFail {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordAaaaScoped] @{
                            ZoneName    = $ZoneName
                            ZoneScope   = $ZoneScope
                            Name        = $Name
                            IPv6Address = $IPv6Address
                            Ensure      = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }

                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }
        }
    }
}

Describe 'Testing DnsRecordAaaaScoped Set Method' -Tag 'Set', 'DnsRecord', 'DnsRecordAaaaScoped' {
    BeforeAll {
        # Mock the Add-DnsServerResourceRecord cmdlet to return nothing
        Mock -CommandName Add-DnsServerResourceRecord -MockWith {
            Write-Verbose -Message 'Mock Add-DnsServerResourceRecord Called' -Verbose
        } -Verifiable

        # Mock the Remove-DnsServerResourceRecord cmdlet to return nothing
        Mock -CommandName Remove-DnsServerResourceRecord -MockWith {
            Write-Verbose -Message 'Mock Remove-DnsServerResourceRecord Called' -Verbose
        } -Verifiable

        Mock -CommandName Set-DnsServerResourceRecord -MockWith {
            Write-Verbose -Message 'Mock Set-DnsServerResourceRecord Called' -Verbose
        } -Verifiable
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $mockInstancesPath = Resolve-Path -Path $PSScriptRoot

            Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                Write-Verbose -Message 'Mock Get-DnsServerResourceRecord Called' -Verbose

                $mockRecord = Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\AaaaRecordInstance.xml"

                # Set a wrong value
                $mockRecord.TimeToLive = [System.TimeSpan] '2:00:00'

                return $mockRecord
            }
        }

        Context 'When the configuration should be absent' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState = [DnsRecordAaaaScoped] @{
                        ZoneName    = 'contoso.com'
                        ZoneScope   = 'external'
                        Name        = 'www'
                        IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                        Ensure      = [Ensure]::Absent
                    }
                }
            }

            BeforeEach {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState.Ensure = [Ensure]::Absent
                }
            }

            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { $script:instanceDesiredState.Set() } | Should -Not -Throw
                }

                Should -Invoke -CommandName Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Remove-DnsServerResourceRecord -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the configuration should be present' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState = [DnsRecordAaaaScoped] @{
                        ZoneName    = 'contoso.com'
                        ZoneScope   = 'external'
                        Name        = 'www'
                        IPv6Address = '2001:db8:85a3::8a2e:370:7334'
                        TimeToLive  = '1:00:00'
                        Ensure      = [Ensure]::Present
                    }
                }
            }

            BeforeEach {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState.Ensure = 'Present'
                }
            }

            It 'Should call the correct mocks when record exists' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { $script:instanceDesiredState.Set() } | Should -Not -Throw
                }

                Should -Invoke -CommandName Set-DnsServerResourceRecord -Exactly -Times 1 -Scope It
            }

            It 'Should call the correct mocks when record does not exist' {
                Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                    Write-Verbose -Message 'Mock Get-DnsServerResourceRecord Called' -Verbose

                    return
                }
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { $script:instanceDesiredState.Set() } | Should -Not -Throw
                }

                Should -Invoke -CommandName Add-DnsServerResourceRecord -Exactly -Times 1 -Scope It
            }
        }

        It 'Should call all verifiable mocks' {
            Should -InvokeVerifiable
        }
    }
}
