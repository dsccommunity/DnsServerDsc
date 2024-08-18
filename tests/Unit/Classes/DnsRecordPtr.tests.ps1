<#
    .SYNOPSIS
        Unit test for DSC_DnsRecordPtr DSC resource.
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

Describe DnsRecordPtr -Tag 'DnsRecord', 'DnsRecordPtr' {
    Context 'Constructors' {
        It 'Should not throw an exception when instantiated' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [DnsRecordPtr]::new() } | Should -Not -Throw
            }
        }

        It 'Has a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsRecordPtr]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Type creation' {
        It 'Should be type named DnsRecordPtr' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [DnsRecordPtr]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordPtr'
            }
        }
    }
}

Describe 'Testing DnsRecordPtr Get Method' -Tag 'Get', 'DnsRecord', 'DnsRecordPtr' {
    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:instanceDesiredState = [DnsRecordPtr] @{
                ZoneName  = '0.168.192.in-addr.arpa'
                IpAddress = '192.168.0.9'
                Name      = 'quarks.contoso.com'
            }
        }
    }

    Context 'When the configuration is absent' {
        BeforeAll {
            Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                Write-Verbose 'Mock Get-DnsServerResourceRecord Called' -Verbose
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
                $getMethodResourceResult.IpAddress | Should -Be $script:instanceDesiredState.IpAddress
                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
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
                Write-Verbose 'Mock Get-DnsServerResourceRecord Called' -Verbose

                return Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\PtrRecordInstance.xml"
            }
        }

        It 'Should return the state as present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:instanceDesiredState.Get()

                Should -Invoke Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
                $currentState.Ensure | Should -Be 'Present'
            }
        }

        It 'Should return the same values as present in Key properties' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.IpAddress | Should -Be $script:instanceDesiredState.IpAddress
                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
            }
        }
    }
}

Describe 'Testing DnsRecordPtr Test Method' -Tag 'Test', 'DnsRecord', 'DnsRecordPtr' {
    Context 'When the system is in the desired state' {
        Context 'When the configuration are absent' {
            BeforeEach {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.168.192.in-addr.arpa'
                        IpAddress = '192.168.0.9'
                        Name      = 'quarks.contoso.com'
                        Ensure    = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = '0.168.192.in-addr.arpa'
                            IpAddress = '192.168.0.9'
                            Name      = 'quarks.contoso.com'
                            Ensure    = [Ensure]::Absent
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
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.168.192.in-addr.arpa'
                        IpAddress = '192.168.0.9'
                        Name      = 'quarks.contoso.com'
                    }

                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = '0.168.192.in-addr.arpa'
                            IpAddress = '192.168.0.9'
                            Name      = 'quarks.contoso.com'
                            Ensure    = [Ensure]::Present
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

                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.168.192.in-addr.arpa'
                        IpAddress = '192.168.0.9'
                        Name      = 'quarks.contoso.com'
                        Ensure    = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = '0.168.192.in-addr.arpa'
                            IpAddress = '192.168.0.9'
                            Name      = 'quarks.contoso.com'
                            Ensure    = [Ensure]::Present
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

                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName   = '0.168.192.in-addr.arpa'
                        IpAddress  = '192.168.0.9'
                        Name       = 'quarks.contoso.com'
                        TimeToLive = '1:00:00'
                        Ensure     = [Ensure]::Present
                    }
                }
            }

            BeforeDiscovery {
                $testCasesToFail = @(
                    @{
                        ZoneName   = '0.168.192.in-addr.arpa'
                        IpAddress  = '192.168.0.9'
                        Name       = 'quarks.contoso.com'
                        DnsServer  = 'localhost'
                        TimeToLive = '02:00:00' # Undesired
                        Ensure     = 'Present'
                    }
                )
            }

            It 'Should return $false when the object is not found' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = '0.168.192.in-addr.arpa'
                            IpAddress = '192.168.0.9'
                            Name      = 'quarks.contoso.com'
                            Ensure    = [Ensure]::Absent
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
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = $ZoneName
                            IpAddress = $IpAddress
                            Name      = $Name
                            Ensure    = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }

                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }
        }
    }
}

Describe 'Testing DnsRecordPtr Set Method' -Tag 'Set', 'DnsRecord', 'DnsRecordPtr' {
    BeforeAll {
        # Mock the Add-DnsServerResourceRecord cmdlet to return nothing
        Mock -CommandName Add-DnsServerResourceRecord -MockWith {
            Write-Verbose 'Mock Add-DnsServerResourceRecord Called' -Verbose
        } -Verifiable

        # Mock the Remove-DnsServerResourceRecord cmdlet to return nothing
        Mock -CommandName Remove-DnsServerResourceRecord -MockWith {
            Write-Verbose 'Mock Remove-DnsServerResourceRecord Called' -Verbose
        } -Verifiable

        Mock -CommandName Set-DnsServerResourceRecord -MockWith {
            Write-Verbose 'Mock Set-DnsServerResourceRecord Called' -Verbose
        } -Verifiable
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $mockInstancesPath = Resolve-Path -Path $PSScriptRoot

            Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                Write-Verbose 'Mock Get-DnsServerResourceRecord Called' -Verbose

                $mockRecord = Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\PtrRecordInstance.xml"

                # Set a wrong value
                $mockRecord.TimeToLive = [System.TimeSpan] '2:00:00'

                return $mockRecord
            }
        }

        Context 'When the configuration should be absent' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.168.192.in-addr.arpa'
                        IpAddress = '192.168.0.9'
                        Name      = 'quarks.contoso.com'
                        Ensure    = [Ensure]::Absent
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

                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName   = '0.168.192.in-addr.arpa'
                        IpAddress  = '192.168.0.9'
                        Name       = 'quarks.contoso.com'
                        TimeToLive = '1:00:00'
                        Ensure     = [Ensure]::Present
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
                    Write-Verbose 'Mock Get-DnsServerResourceRecord Called' -Verbose

                    return
                }
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { $script:instanceDesiredState.Set() } | Should -Not -Throw
                }

                Should -Invoke -CommandName Add-DnsServerResourceRecord -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'Test bad inputs (both IPv4 and IPv6)' -Tag 'Test', 'DnsRecord', 'DnsRecordPtr' {
    It 'Throws when the IPv4 address is malformatted' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0
            $malformattedIPv4State = [DnsRecordPtr] @{
                ZoneName  = '0.168.192.in-addr.arpa'
                IpAddress = '192.168.0.DS9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $malformattedIPv4State.Get() } | Should -Throw -ExpectedMessage ('*' + '"Cannot convert value "{0}" to type "System.Net.IPAddress". Error: "An invalid IP address was specified.""' -f $malformattedIPv4State.IpAddress)
        }
    }

    It 'Throws when the IPv6 address is malformatted' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $malformattedIPv6State = [DnsRecordPtr] @{
                ZoneName  = '0.0.d.f.ip6.arpa'
                IpAddress = 'fd00::1::9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $malformattedIPv6State.Get() } | Should -Throw -ExpectedMessage ('*' + '"Cannot convert value "{0}" to type "System.Net.IPAddress". Error: "An invalid IP address was specified.""' -f $malformattedIPv6State.IpAddress)
        }
    }

    It 'Throws when placed in an incorrect IPv4 reverse lookup zone' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $wrongIPv4ZoneState = [DnsRecordPtr] @{
                ZoneName  = '0.168.192.in-addr.arpa'
                IpAddress = '192.168.2.9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $wrongIPv4ZoneState.Get() } | Should -Throw -ExpectedMessage ('"{0}" does not belong to the "{1}" zone.' -f $wrongIPv4ZoneState.IpAddress, $wrongIPv4ZoneState.ZoneName)
        }
    }

    It 'Throws when placed in an incorrect IPv6 reverse lookup zone' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $wrongIPv6ZoneState = [DnsRecordPtr] @{
                ZoneName  = '1.0.0.d.f.ip6.arpa'
                IpAddress = 'fd00::9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $wrongIPv6ZoneState.Get() } | Should -Throw -ExpectedMessage ('"{0}" does not belong to the "{1}" zone.' -f $wrongIPv6ZoneState.IpAddress, $wrongIPv6ZoneState.ZoneName)
        }
    }

    It 'Throws trying to put an IPv6 address into an IPv4 reverse lookup zone' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $zoneVersionMismatchV6InV4State = [DnsRecordPtr] @{
                ZoneName  = '0.168.192.in-addr.arpa'
                IpAddress = 'fd00::d59'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $zoneVersionMismatchV6InV4State.Get() } | Should -Throw -ExpectedMessage ('The zone "{0}" is not an IPv6 reverse lookup zone.' -f $zoneVersionMismatchV6InV4State.ZoneName)
        }
    }

    It 'Throws trying to put an IPv4 address into an IPv6 reverse lookup zone' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $zoneVersionMismatchV4InV6State = [DnsRecordPtr] @{
                ZoneName  = '1.0.0.d.f.ip6.arpa'
                IpAddress = '192.168.2.9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $zoneVersionMismatchV4InV6State.Get() } | Should -Throw -ExpectedMessage ('The zone "{0}" is not an IPv4 reverse lookup zone.' -f $zoneVersionMismatchV4InV6State.ZoneName)
        }
    }
}
