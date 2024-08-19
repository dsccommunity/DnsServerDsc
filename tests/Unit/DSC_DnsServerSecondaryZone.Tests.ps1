<#
    .SYNOPSIS
        Unit test for DSC_DnsServerSecondaryZone DSC resource.
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
    $script:dscResourceName = 'DSC_DnsServerSecondaryZone'

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

Describe 'DSC_DnsServerSecondaryZone\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the secondary zone exists' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone -MockWith {
                return     @{
                    Name          = 'example.com'
                    MasterServers = '192.168.0.2', '192.168.0.3'
                    ZoneType      = 'Secondary'
                }
            }
        }

        It 'Should return "Present"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name          = 'example.com'
                    MasterServers = '192.168.0.2', '192.168.0.3'
                    Verbose       = $false
                }

                $targetResource = Get-TargetResource @params
                $targetResource.Ensure | Should -Be 'Present'
            }

            Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
            Should -Invoke -CommandName Assert-Module -Times 1 -Exactly
        }
    }

    Context 'When the secondary zone does not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone
        }

        It 'Should return "Absent"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name          = 'example.com'
                    MasterServers = '192.168.0.2', '192.168.0.3'
                    Verbose       = $false
                }

                $targetResource = Get-TargetResource @params
                $targetResource.Ensure | Should -Be 'Absent'
            }

            Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
            Should -Invoke -CommandName Assert-Module -Times 1 -Exactly
        }
    }
}

Describe 'DSC_DnsServerSecondaryZone\Set-TargetResource' -Tag 'Set' {
    Context 'When the script runs' {
        BeforeAll {
            Mock -CommandName Test-ResourceProperties
            Mock -CommandName Restart-Service
        }

        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name          = 'example.com'
                    MasterServers = '192.168.0.2', '192.168.0.3'
                    Debug         = $true
                    Verbose       = $false
                }

                Set-TargetResource @params
            }

            Should -Invoke -CommandName Test-ResourceProperties -Times 1 -Exactly
            Should -Invoke -CommandName Restart-Service -Times 1 -Exactly

        }
    }
}

Describe 'DSC_DnsServerSecondaryZone\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Test-ResourceProperties -MockWith { return $true }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name          = 'example.com'
                    MasterServers = '192.168.0.2', '192.168.0.3'
                    Debug         = $true
                    Verbose       = $false
                }

                Test-TargetResource @params | Should -BeTrue
            }

            Should -Invoke -CommandName Test-ResourceProperties -Times 1 -Exactly
            Should -Invoke -CommandName Assert-Module -Times 1 -Exactly
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Test-ResourceProperties -MockWith { return $false }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name          = 'example.com'
                    MasterServers = '192.168.0.2', '192.168.0.3'
                    Verbose       = $false
                }

                Test-TargetResource @params | Should -BeFalse
            }

            Should -Invoke -CommandName Test-ResourceProperties -Times 1 -Exactly
            Should -Invoke -CommandName Assert-Module -Times 1 -Exactly
        }
    }
}

Describe 'DSC_DnsServerSecondaryZone\Test-ResourceProperties' -Tag 'Private' {
    Context 'When a zone exists' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone -MockWith {
                return @{
                    Name          = 'example.com'
                    MasterServers = @(
                        [System.Net.IPAddress]'192.168.0.2'
                        [System.Net.IPAddress]'192.168.0.3'
                    )
                    ZoneType      = 'Secondary'
                }
            }
        }

        Context 'When Ensure = Present' {
            Context 'When the zone is a secondary zone' {
                Context 'When MasterServers does not match' {
                    Context 'When Apply = $true' {
                        BeforeAll {
                            Mock -CommandName Set-DnsServerSecondaryZone
                        }

                        It 'Should be $false and call expected mocks' {
                            InModuleScope -ScriptBlock {
                                Set-StrictMode -Version 1.0

                                $params = @{
                                    Name          = 'example.com'
                                    MasterServers = '192.168.0.2', '192.168.0.4'
                                    Ensure        = 'Present'
                                    Apply         = $true
                                    Verbose       = $false
                                }
                                Test-ResourceProperties @params | Should -BeFalse
                            }

                            Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                            Should -Invoke -CommandName Set-DnsServerSecondaryZone -Times 1 -Exactly
                        }
                    }

                    Context 'When Apply = $true' {
                        It 'Should be $false and call expected mocks' {
                            InModuleScope -ScriptBlock {
                                Set-StrictMode -Version 1.0

                                $params = @{
                                    Name          = 'example.com'
                                    MasterServers = '192.168.0.2', '192.168.0.4'
                                    Ensure        = 'Present'
                                    Apply         = $false
                                    Verbose       = $false
                                }
                                Test-ResourceProperties @params | Should -BeFalse
                            }

                            Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                        }
                    }
                }

                Context 'When MasterServers do match' {
                    Context 'When Apply = $false' {
                        It 'Should return $true' {
                            InModuleScope -ScriptBlock {
                                Set-StrictMode -Version 1.0

                                $params = @{
                                    Name          = 'example.com'
                                    MasterServers = '192.168.0.2', '192.168.0.3'
                                    Ensure        = 'Present'
                                    Apply         = $false
                                    Verbose       = $false
                                }
                                Test-ResourceProperties @params | Should -BeTrue
                            }

                            Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                        }
                    }

                    Context 'When Apply = $true' {
                        It 'Should return $false' {
                            InModuleScope -ScriptBlock {
                                Set-StrictMode -Version 1.0

                                $params = @{
                                    Name          = 'example.com'
                                    MasterServers = '192.168.0.2', '192.168.0.3'
                                    Ensure        = 'Present'
                                    Apply         = $true
                                    Verbose       = $false
                                }
                                Test-ResourceProperties @params | Should -BeFalse
                            }

                            Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                        }
                    }
                }
            }

            Context 'When the zone is not a secondary zone' {
                BeforeAll {
                    Mock -CommandName Get-DnsServerZone -MockWith {
                        return @{
                            Name          = 'example.com'
                            MasterServers = @(
                                [System.Net.IPAddress]'192.168.0.2'
                                [System.Net.IPAddress]'192.168.0.3'
                            )
                            ZoneType      = 'Primary'
                        }
                    }
                }

                Context 'When Apply = $true' {
                    BeforeAll {
                        Mock -CommandName ConvertTo-DnsServerSecondaryZone
                    }

                    It 'Should be $false transfer and call expected mocks' {
                        InModuleScope -ScriptBlock {
                            Set-StrictMode -Version 1.0

                            $params = @{
                                Name          = 'example.com'
                                MasterServers = '192.168.0.2', '192.168.0.3'
                                Ensure        = 'Present'
                                Apply         = $true
                                Verbose       = $false
                            }
                            Test-ResourceProperties @params | Should -BeFalse
                        }

                        Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                        Should -Invoke -CommandName ConvertTo-DnsServerSecondaryZone -Times 1 -Exactly
                    }
                }

                Context 'When Apply = $false' {
                    It 'Should be $false and call expected mocks' {
                        InModuleScope -ScriptBlock {
                            Set-StrictMode -Version 1.0

                            $params = @{
                                Name          = 'example.com'
                                MasterServers = '192.168.0.2', '192.168.0.3'
                                Ensure        = 'Present'
                                Apply         = $false
                                Verbose       = $false
                            }
                            Test-ResourceProperties @params | Should -BeFalse
                        }

                        Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                    }
                }
            }
        }

        Context 'When Ensure = Absent' {
            Context 'When Apply = $true' {
                BeforeAll {
                    Mock -CommandName Remove-DnsServerZone
                }

                It 'Should return $false and remove the zone' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name          = 'example.com'
                            MasterServers = '192.168.0.2', '192.168.0.3'
                            Ensure        = 'Absent'
                            Apply         = $true
                            Verbose       = $false
                        }
                        Test-ResourceProperties @params | Should -BeFalse
                    }

                    Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                    Should -Invoke -CommandName Remove-DnsServerZone -Times 1 -Exactly
                }
            }

            Context 'When Apply = $false' {
                It 'Should return $false' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name          = 'example.com'
                            MasterServers = '192.168.0.2', '192.168.0.3'
                            Ensure        = 'Absent'
                            Apply         = $false
                            Verbose       = $false
                        }
                        Test-ResourceProperties @params | Should -BeFalse
                    }

                    Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                }
            }
        }
    }

    Context 'When the secondary zone does not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone
        }

        Context 'When Ensure = Present' {
            Context 'When Apply = $true' {
                BeforeAll {
                    Mock -CommandName Add-DnsServerSecondaryZone
                    Mock -CommandName Start-DnsServerZoneTransfer
                }

                It 'Should be $false add the zone and transfer' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name          = 'example.com'
                            MasterServers = '192.168.0.2', '192.168.0.3'
                            Ensure        = 'Present'
                            Apply         = $true
                            Verbose       = $false
                        }
                        Test-ResourceProperties @params | Should -BeFalse
                    }

                    Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                    Should -Invoke -CommandName Add-DnsServerSecondaryZone -Times 1 -Exactly
                    Should -Invoke -CommandName Start-DnsServerZoneTransfer -Times 1 -Exactly
                }
            }

            Context 'When Apply = $false' {
                It 'Should be $false' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name          = 'example.com'
                            MasterServers = '192.168.0.2', '192.168.0.3'
                            Apply         = $false
                            Ensure        = 'Present'
                            Verbose       = $false
                        }
                        Test-ResourceProperties @params | Should -BeFalse
                    }

                    Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                }
            }
        }

        Context 'When Ensure = Absent' {
            Context 'When Apply is $false' {
                It 'Should return $true' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name          = 'example.com'
                            MasterServers = '192.168.0.2', '192.168.0.3'
                            Ensure        = 'Absent'
                            Verbose       = $false
                        }
                        Test-ResourceProperties @params | Should -BeTrue
                    }

                    Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                }
            }

            Context 'When Apply is $true' {
                It 'Should return $false' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name          = 'example.com'
                            MasterServers = '192.168.0.2', '192.168.0.3'
                            Apply         = $true
                            Ensure        = 'Absent'
                            Verbose       = $false
                        }
                        Test-ResourceProperties @params | Should -BeFalse
                    }
                    
                    Should -Invoke -CommandName Get-DnsServerZone -Times 1 -Exactly
                }
            }
        }
    }
}
