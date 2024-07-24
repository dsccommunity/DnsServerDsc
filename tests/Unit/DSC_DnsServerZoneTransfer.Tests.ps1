# TODO: This is not testing one level of indirection. Also no tests for the Test-ResourceProperties rewrite

<#
    .SYNOPSIS
        Unit test for DSC_DnsServerZoneTransfer DSC resource.
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
    $script:dscResourceName = 'DSC_DnsServerZoneTransfer'

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

Describe 'DSC_DnsServerZoneTransfer\Get-TargetResource' -Tag 'Get' {
    Context 'When command is invoked' {
        BeforeAll {
            $XferId2Name = @('Any', 'Named', 'Specific', 'None')

            Mock -CommandName Assert-Module
            Mock -CommandName Get-CimInstance -MockWith { return @{
                    Name              = 'example.com'
                    SecureSecondaries = $XferId2Name.IndexOf('Any')
                    SecondaryServers  = ''
                }
            }
        }
        It 'Should return the expected values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name = 'example.com'
                    Type = 'Any'
                }

                $targetResource = Get-TargetResource @params
                $targetResource | Should -BeOfType [System.Collections.Hashtable]
                $targetResource.Name | Should -Be 'example.com'
                $targetResource.Type | Should -Be 'Any'
                $targetResource.SecondaryServer | Should -Be ''
            }
        }
    }


}

Describe 'DSC_DnsServerZoneTransfer\Test-TargetResource' -Tag 'Test' {
    Context 'When command is invoked' {
        Context 'When the system is in the desired state' {
            BeforeAll {
                Mock -CommandName Assert-Module
                Mock -CommandName Test-ResourceProperties -MockWith { return $true }
            }
            It 'Should return $true and call expected mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Name    = 'example.com'
                        Type    = 'None'
                        Debug   = $false
                        Verbose = $false
                    }

                    Test-TargetResource @params | Should -BeTrue
                }
                Should -Invoke -CommandName Assert-Module -Scope It -Times 1 -Exactly
                Should -Invoke -CommandName Test-ResourceProperties -Scope It -Times 1 -Exactly
            }
        }
        Context 'When the system is not in the desired state' {
            BeforeAll {
                Mock -CommandName Assert-Module
                Mock -CommandName Test-ResourceProperties
            }
            It 'Should return $false and call expected mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $params = @{
                        Name    = 'example.com'
                        Type    = 'None'
                        Debug   = $false
                        Verbose = $false
                    }

                    Test-TargetResource @params | Should -BeFalse
                }
                Should -Invoke -CommandName Assert-Module -Scope It -Times 1 -Exactly
                Should -Invoke -CommandName Test-ResourceProperties -Scope It -Times 1 -Exactly
            }

        }
    }
    #     BeforeAll {
    #         Mock -CommandName Assert-Module

    #         $testName = 'example.com'
    #         $testSecondaryServer = '192.168.0.1', '192.168.0.2'
    #         $XferId2Name = @('Any', 'Named', 'Specific', 'None')

    #         $fakeCimInstanceAny = @{
    #             Name              = $testName
    #             SecureSecondaries = $XferId2Name.IndexOf('Any')
    #             SecondaryServers  = ''
    #         }

    #         $fakeCimInstanceNamed = @{
    #             Name              = $testName
    #             SecureSecondaries = $XferId2Name.IndexOf('Named')
    #             SecondaryServers  = ''
    #         }

    #         $fakeCimInstanceSpecific = @{
    #             Name              = $testName
    #             SecureSecondaries = $XferId2Name.IndexOf('Specific')
    #             SecondaryServers  = $testSecondaryServer
    #         }

    #         InModuleScope -ScriptBlock {
    #             Set-StrictMode -Version 1.0

    #             $script:defaultParamsAny = @{
    #                 Name            = 'example.com'
    #                 Type            = 'Any'
    #                 SecondaryServer = ''
    #                 Verbose         = $VerbosePreference
    #             }

    #             $script:defaultParamsSpecific = @{
    #                 Name            = 'example.com'
    #                 Type            = 'Specific'
    #                 SecondaryServer = '192.168.0.1', '192.168.0.2'
    #                 Verbose         = $VerbosePreference
    #             }

    #             $script:defaultParamsSpecificDifferent = @{
    #                 Name            = 'example.com'
    #                 Type            = 'Specific'
    #                 SecondaryServer = '192.168.0.1', '192.168.0.2', '192.168.0.3'
    #                 Verbose         = $VerbosePreference
    #             }
    #         }
    #     }

    #     BeforeEach {
    #         InModuleScope -ScriptBlock {
    #             Set-StrictMode -Version 1.0

    #             $script:mockTestAnyParameters = $defaultParamsAny.Clone()
    #             $script:mockTestSpecificParameters = $defaultParamsSpecific.Clone()
    #             $script:mockTestSpecificDifferentParameters = $defaultParamsSpecificDifferent.Clone()
    #         }
    #     }

    #     Context 'When the system is in the desired state' {
    #         Context 'When the command runs successfully' {
    #             BeforeAll {
    #                 Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceAny }
    #             }
    #             It 'Should return a "System.Boolean" object type' {
    #                 InModuleScope -ScriptBlock {
    #                     Set-StrictMode -Version 1.0

    #                     $targetResource = Test-TargetResource @mockTestAnyParameters
    #                     $targetResource -is [System.Boolean] | Should -BeTrue
    #                 }
    #             }
    #         }
    #         Context 'When Zone Transfer Type matches' {
    #             BeforeAll {
    #                 Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceAny }
    #             }
    #             It 'Should be $true' {
    #                 InModuleScope -ScriptBlock {
    #                     Set-StrictMode -Version 1.0

    #                     Test-TargetResource @mockTestAnyParameters | Should -BeTrue
    #                 }
    #             }
    #         }
    #         Context 'When Zone Transfer Secondaries matches' {
    #             BeforeAll {
    #                 Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceSpecific }
    #             }
    #             It 'Should be $true' {
    #                 InModuleScope -ScriptBlock {
    #                     Set-StrictMode -Version 1.0

    #                     Test-TargetResource @mockTestSpecificParameters | Should -BeTrue
    #                 }
    #             }
    #         }
    #     }
    #     Context 'When the system is not in the desired state' {
    #         Context 'When Zone Transfer Type does not match' {
    #             BeforeAll {
    #                 Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceNamed }
    #             }
    #             It 'Should be $false' {
    #                 InModuleScope -ScriptBlock {
    #                     Set-StrictMode -Version 1.0

    #                     Test-TargetResource @mockTestAnyParameters | Should -BeFalse
    #                 }
    #             }
    #         }
    #         Context 'When Zone Transfer Secondaries does not match' {
    #             BeforeAll {
    #                 Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceSpecific }
    #             }
    #             It 'Should be $false' {
    #                 InModuleScope -ScriptBlock {
    #                     Set-StrictMode -Version 1.0

    #                     Test-TargetResource @mockTestSpecificDifferentParameters | Should -BeFalse
    #                 }
    #             }
    #         }
    #     }
}

Describe 'DSC_DnsServerZoneTransfer\Set-TargetResource' -Tag 'Set' {
    Context 'When command is invoked' {
        BeforeAll {
            Mock -CommandName Test-ResourceProperties
            Mock -CommandName Restart-Service
        }
        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name    = 'example.com'
                    Type    = 'Any'
                    Verbose = $false
                    Debug   = $false
                }
                Set-TargetResource @params
            }
            Should -Invoke Test-ResourceProperties -Scope It -Times 1 -Exactly
            Should -Invoke Restart-Service -Scope It -Times 1 -Exactly
        }
    }
}

Describe 'DSC_DnsServerZoneTransfer\Test-TargetResourceProperties' -Tag 'Private' {
    BeforeAll {
        $XferId2Name = @('Any', 'Named', 'Specific', 'None')
    }
    Context 'When ZoneTransfer value does match' {
        Context 'When ZoneTransfer is "Specific or 2" and SecondaryServer does not match' {
            BeforeAll {
                Mock -CommandName Get-CimInstance -MockWith { return @{
                        Name              = 'example.com'
                        SecureSecondaries = $XferId2Name.IndexOf('Specific')
                        SecondaryServers  = '192.168.20.1'
                    }
                }
            }
            Context 'When Apply = $true' {
                BeforeAll {
                    Mock -CommandName Invoke-CimMethod -RemoveParameterType InputObject
                }
                It 'Should return $false and call expected mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name            = 'example.com'
                            Type            = 'Specific'
                            SecondaryServer = '192.168.20.2'
                            Apply           = $true
                            Verbose         = $false
                        }

                        Test-ResourceProperties @params | Should -BeFalse
                    }
                    Should -Invoke -CommandName Get-CimInstance -Scope It -Times 1 -Exactly
                    Should -Invoke -CommandName Invoke-CimMethod -Scope It -Times 1 -Exactly
                }

            }
            Context 'When Apply = $false' {
                It 'Should return $false and call expected mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name            = 'example.com'
                            Type            = 'Specific'
                            SecondaryServer = '192.168.20.2'
                            Apply           = $false
                            Verbose         = $false
                        }

                        Test-ResourceProperties @params | Should -BeFalse
                    }
                    Should -Invoke -CommandName Get-CimInstance -Scope It -Times 1 -Exactly
                }
            }
        }
        Context 'When ZoneTransfer is not "Specific or 2"' {
            BeforeAll {
                Mock -CommandName Get-CimInstance -MockWith { return @{
                        Name              = 'example.com'
                        SecureSecondaries = $XferId2Name.IndexOf('None')
                    }
                }
            }
            Context 'When Apply = $false' {
                It 'Should return $true and call expected mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name    = 'example.com'
                            Type    = 'None'
                            Apply   = $false
                            Verbose = $false
                        }

                        Test-ResourceProperties @params | Should -BeTrue
                    }
                    Should -Invoke -CommandName Get-CimInstance -Scope It -Times 1 -Exactly
                }
            }
            Context 'When Apply = $true' {
                It 'Should return $true and call expected mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name    = 'example.com'
                            Type    = 'None'
                            Apply   = $true
                            Verbose = $false
                        }

                        Test-ResourceProperties @params | Should -BeFalse
                    }
                    Should -Invoke -CommandName Get-CimInstance -Scope It -Times 1 -Exactly
                }
            }
        }

        Context 'When ZoneTransfer value does not match' {
            BeforeAll {
                Mock -CommandName Get-CimInstance -MockWith { return @{
                        Name              = 'example.com'
                        SecureSecondaries = $XferId2Name.IndexOf('None')
                    }
                }
            }
            Context 'When Apply = $true' {
                BeforeAll {
                    Mock -CommandName Invoke-CimMethod -RemoveParameterType InputObject
                }
                It 'Should return $false and call expected mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name    = 'example.com'
                            Type    = 'Any'
                            Apply   = $true
                            Verbose = $false
                        }

                        Test-ResourceProperties @params | Should -BeFalse
                    }
                    Should -Invoke -CommandName Get-CimInstance -Scope It -Times 1 -Exactly
                    Should -Invoke -CommandName Invoke-CimMethod -Scope It -Times 1 -Exactly
                }
            }
            Context 'When Apply = $false' {
                It 'Should return $false and call expected mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $params = @{
                            Name    = 'example.com'
                            Type    = 'Named'
                            Apply   = $false
                            Verbose = $false
                        }

                        Test-ResourceProperties @params | Should -BeFalse
                    }
                    Should -Invoke -CommandName Get-CimInstance -Scope It -Times 1 -Exactly
                }
            }
        }
    }
}
