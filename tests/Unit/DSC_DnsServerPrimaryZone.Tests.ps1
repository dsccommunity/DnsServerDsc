<#
    .SYNOPSIS
        Unit test for DSC_DnsServerPrimaryZone DSC resource.
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
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
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
    $script:dscResourceName = 'DSC_DnsServerPrimaryZone'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    Remove-Module -Name DnsServer -Force
}

Describe 'DSC_DnsServerPrimaryZone\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module

        $testZoneName = 'example.com'
        $testZoneFile = 'example.com.dns'
        $testDynamicUpdate = 'None'
        $fakeDnsFileZone = [PSCustomObject] @{
            DistinguishedName      = $null
            ZoneName               = $testZoneName
            ZoneType               = 'Primary'
            DynamicUpdate          = $testDynamicUpdate
            ReplicationScope       = 'None'
            DirectoryPartitionName = $null
            ZoneFile               = $testZoneFile
        }
    }
    BeforeEach {
        InModuleScope -Parameters @{
            testZoneName = $testZoneName
        } -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:testParams = @{
                Name    = $testZoneName
                Verbose = $false
            }
        }
    }
    Context 'When DNS zone exists' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        }
        It 'Should return a "System.Collections.Hashtable" object type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Get-TargetResource @testParams | Should -BeOfType [System.Collections.Hashtable]
            }
        }

        It 'Should return "Present" when "Ensure" = "Present"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams += @{
                    ZoneFile = 'example.com.dns'
                    Ensure   = 'Present'
                }

                $targetResource = Get-TargetResource @testParams
                $targetResource.Ensure | Should -Be 'Present'
            }
        }

        It 'Should return "Present" when "Ensure" = "Absent"' {
            Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams += @{
                    ZoneFile = 'example.com.dns'
                    Ensure   = 'Absent'
                }

                $targetResource = Get-TargetResource @testParams
                $targetResource.Ensure | Should -Be 'Present'
            }
        }
    }
    Context 'When DNS zone does not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone
        }
        It 'Should return "Absent" when "Ensure" = "Present"' {

            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams += @{
                    ZoneFile = 'example.com.dns'
                }

                $targetResource = Get-TargetResource @testParams
                $targetResource.Ensure | Should -Be 'Absent'
            }
        }


        It 'Should return "Absent" when "Ensure" = "Absent"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams += @{
                    ZoneFile = 'example.com.dns'
                    Ensure   = 'Absent'
                }

                $targetResource = Get-TargetResource @testParams
                $targetResource.Ensure | Should -Be 'Absent'
            }
        }
    }
}

Describe 'DSC_DnsServerPrimaryZone\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module

        $testZoneName = 'example.com'
        $testZoneFile = 'example.com.dns'
        $testDynamicUpdate = 'None'
        $fakeDnsFileZone = [PSCustomObject] @{
            DistinguishedName      = $null
            ZoneName               = $testZoneName
            ZoneType               = 'Primary'
            DynamicUpdate          = $testDynamicUpdate
            ReplicationScope       = 'None'
            DirectoryPartitionName = $null
            ZoneFile               = $testZoneFile
        }
    }
    BeforeEach {
        InModuleScope -Parameters @{
            testZoneName = $testZoneName
        } -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:testParams = @{
                Name    = $testZoneName
                Verbose = $false
            }
        }
    }
    Context 'When the DNS zone exists' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        }
        Context 'When the zone is in the desired state' {
            It 'Should return a "System.Boolean" object type' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Test-TargetResource @testParams | Should -BeOfType [System.Boolean]
                }
            }
            It 'Should be $true when "Ensure" = "Present"' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams += @{
                        Ensure = 'Present'
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }
            }
            It 'Should be $true "DynamicUpdate" is correct' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams += @{
                        Ensure        = 'Present'
                        DynamicUpdate = 'None'
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }
            }
        }
        Context 'When the zone is not in the desired state' {
            It 'Should be $false "Ensure" = "Absent"' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams += @{
                        Ensure = 'Absent'
                    }

                    Test-TargetResource @testParams | Should -BeFalse
                }
            }
            It 'Should be $false when "DynamicUpdate" is incorrect' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams += @{
                        ZoneFile      = 'example.com.dns'
                        Ensure        = 'Present'
                        DynamicUpdate = 'NonSecureAndSecure'
                    }

                    Test-TargetResource @testParams | Should -BeFalse
                }
            }

            It 'Should be $false when "ZoneFile" is incorrect' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams += @{
                        ZoneFile      = 'nonexistent.com.dns'
                        Ensure        = 'Present'
                        DynamicUpdate = 'None'
                    }

                    Test-TargetResource @testParams | Should -BeFalse
                }
            }
        }
    }

    Context 'When the DNS zone does not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone
        }
        Context 'When the zone is in the desired state' {
            It 'Should be $true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams += @{
                        Ensure = 'Absent'
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }
            }
        }
        Context 'When the zone is not in the desired state' {
            It 'Should be $false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams += @{
                        Ensure = 'Present'
                    }

                    Test-TargetResource @testParams | Should -BeFalse
                }
            }
        }
    }
}

Describe 'DSC_DnsServerPrimaryZone\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName 'Assert-Module'

        $testZoneName = 'example.com'
        $testZoneFile = 'example.com.dns'
        $testDynamicUpdate = 'None'
        $fakeDnsFileZone = [PSCustomObject] @{
            DistinguishedName      = $null
            ZoneName               = $testZoneName
            ZoneType               = 'Primary'
            DynamicUpdate          = $testDynamicUpdate
            ReplicationScope       = 'None'
            DirectoryPartitionName = $null
            ZoneFile               = $testZoneFile
        }
    }
    BeforeEach {
        InModuleScope -Parameters @{
            testZoneName = $testZoneName
        } -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:testParams = @{
                Name    = $testZoneName
                Verbose = $false
            }
        }
    }
    Context 'When the DNS zone does not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone
            Mock -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName }
        }
        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams += @{
                    Ensure        = 'Present'
                    DynamicUpdate = 'None'
                    ZoneFile      = 'example.com.dns'
                }

                Set-TargetResource @testParams
            }
            Should -Invoke -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName } -Scope It -Times 1 -Exactly
            should -Invoke -CommandName Get-DnsServerZone -Scope It -Times 1 -Exactly
        }
    }

    Context 'When the DNS zone does exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
            Mock -CommandName Remove-DnsServerZone
        }
        Context 'When the zone needs creating' {
            It 'Should call expected mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams += @{
                        Ensure        = 'Absent'
                        DynamicUpdate = 'None'
                        ZoneFile      = 'example.com.dns'
                    }

                    Set-TargetResource @testParams
                }
                Should -Invoke -CommandName Remove-DnsServerZone -Scope It -Times 1 -Exactly
                Should -Invoke -CommandName Get-DnsServerZone -Scope It -Times 1 -Exactly
            }
        }
        Context 'When the zone needs updating' {
            Context 'when DNS zone "DynamicUpdate" is incorrect' {
                BeforeAll {
                    Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                    Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonSecureAndSecure' }
                }
                It 'Should call expected mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams += @{
                            Ensure        = 'Present'
                            DynamicUpdate = 'NonSecureAndSecure'
                            ZoneFile      = 'example.com.dns'
                        }

                        Set-TargetResource @testParams
                    }
                    Should -Invoke -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonSecureAndSecure' } -Scope It -Times 1 -Exactly
                    Should -Invoke -CommandName Get-DnsServerZone -Scope It -Times 1 -Exactly
                }
            }
            Context 'When DNS zone "ZoneFile" is incorrect' {
                BeforeAll {
                    Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                    Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ZoneFile -eq 'nonexistent.com.dns' }
                }
                It 'Should call expected mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams += @{
                            Ensure        = 'Present'
                            DynamicUpdate = 'None'
                            ZoneFile      = 'nonexistent.com.dns'
                        }

                        Set-TargetResource @testParams
                    }
                    Should -Invoke -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ZoneFile -eq 'nonexistent.com.dns' } -Scope It -Times 1 -Exactly
                    Should -Invoke -CommandName Get-DnsServerZone -Scope It -Times 1 -Exactly
                }
            }
        }
    }
}
