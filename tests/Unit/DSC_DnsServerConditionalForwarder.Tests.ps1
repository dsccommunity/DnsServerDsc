<#
    .SYNOPSIS
        Unit test for DSC_DnsServerConditionalForwarder DSC resource.
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
    $script:dscResourceName = 'DSC_DnsServerConditionalForwarder'

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

Context 'DSC_DnsServerConditionalForwarder\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock Get-DnsServerZone {
            @{
                MasterServers          = '1.1.1.1', '2.2.2.2'
                ZoneType               = $script:zoneType
                IsDsIntegrated         = $script:isDsIntegrated
                ReplicationScope       = $script:ReplicationScope
                DirectoryPartitionName = 'CustomName'
            }
        }

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:defaultParameters = @{
                Ensure           = 'Present'
                Name             = 'domain.name'
                MasterServers    = '1.1.1.1', '2.2.2.2'
                ReplicationScope = 'Domain'
                Verbose          = $VerbosePreference
            }
        }
    }
    BeforeEach {
        $script:zoneType = 'Forwarder'
        $script:isDsIntegrated = $true
        $script:ReplicationScope = 'Domain'

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockGetParameters = $defaultParameters.Clone()
            $mockGetParameters.Remove('Ensure')
            $mockGetParameters.Remove('MasterServers')
            $mockGetParameters.Remove('ReplicationScope')
        }
    }

    Context 'When the system is in the desired state' {
        Context 'When the zone is present on the server' {
            It 'Should exist, and is AD integrated' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $getTargetResourceResult = Get-TargetResource @mockGetParameters

                    $getTargetResourceResult.MasterServers | Should -Be '1.1.1.1', '2.2.2.2'
                    $getTargetResourceResult.ZoneType | Should -Be 'Forwarder'
                    $getTargetResourceResult.ReplicationScope | Should -Be 'Domain'
                }
            }

            It 'When the zone exists, and is not AD integrated' {
                $script:isDsIntegrated = $false

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $getTargetResourceResult = Get-TargetResource @mockGetParameters

                    $getTargetResourceResult.ReplicationScope | Should -Be 'None'
                }
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When the zone is present on the server' {
            It 'When the zone exists, and is not a forwarder' {
                $script:ZoneType = 'Primary'

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $getTargetResourceResult = Get-TargetResource @mockGetParameters

                    $getTargetResourceResult.ZoneType | Should -Be 'Primary'
                }
            }
        }

        Context 'When the zone is not present on the server' {
            BeforeAll {
                Mock Get-DnsServerZone
            }

            It 'When the zone does not exist, sets Ensure to Absent' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $getTargetResourceResult = Get-TargetResource @mockGetParameters

                    $getTargetResourceResult.Ensure | Should -Be 'Absent'
                }
            }
        }
    }
}

Context 'DSC_DnsServerConditionalForwarder\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock Add-DnsServerConditionalForwarderZone
        Mock Get-DnsServerZone {
            @{
                MasterServers          = '1.1.1.1', '2.2.2.2'
                ZoneType               = $script:zoneType
                IsDsIntegrated         = $script:isDsIntegrated
                ReplicationScope       = $script:ReplicationScope
                DirectoryPartitionName = 'CustomName'
            }
        }
        Mock Remove-DnsServerZone
        Mock Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 }
        Mock Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 }
    }

    BeforeEach {
        $script:zoneType = 'Forwarder'
        $script:isDsIntegrated = $true
        $script:ReplicationScope = 'Domain'

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockSetParameters = $defaultParameters.Clone()
        }
    }
    Context 'When the system is not in the desired state' {
        Context 'When the zone is present on the server' {
            It 'When Ensure is present, and a zone of a different type exists, removes and recreates the zone' {
                $script:zoneType = 'Stub'

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Set-TargetResource @mockSetParameters
                }

                Should -Invoke Add-DnsServerConditionalForwarderZone -Scope It
                Should -Invoke Remove-DnsServerZone -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
            }

            It 'When Ensure is present, requested replication scope is none, and a DsIntegrated zone exists, removes and recreates the zone' {
                $script:isDsIntegrated = $true

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockSetParameters.ReplicationScope = 'None'
                    Set-TargetResource @mockSetParameters
                }

                Should -Invoke Add-DnsServerConditionalForwarderZone -Scope It
                Should -Invoke Remove-DnsServerZone -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
            }

            It 'When Ensure is present, requested zone storage is AD, and a file based zone exists, removes and recreates the zone' {
                $script:isDsIntegrated = $false

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Set-TargetResource @mockSetParameters
                }

                Should -Invoke Add-DnsServerConditionalForwarderZone -Scope It
                Should -Invoke Remove-DnsServerZone -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
            }

            It 'When Ensure is present, and master servers differs, updates list of master servers' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockSetParameters.MasterServers = '3.3.3.3', '4.4.4.4'

                    Set-TargetResource @mockSetParameters
                }

                Should -Invoke Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                Should -Invoke Remove-DnsServerZone -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 1 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
            }

            It 'When Ensure is present, and the replication scope differs, attempts to move the zone' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockSetParameters.ReplicationScope = 'Forest'
                    Set-TargetResource @mockSetParameters
                }

                Should -Invoke Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                Should -Invoke Remove-DnsServerZone -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 1 -Scope It
            }

            It 'When Ensure is present, the replication scope is custom, and the directory partition name differs, attempts to move the zone' {
                $script:ReplicationScope = 'Custom'

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockSetParameters.ReplicationScope = 'Custom'
                    $mockSetParameters.DirectoryPartitionName = 'New'
                    Set-TargetResource @mockSetParameters
                }

                Should -Invoke Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                Should -Invoke Remove-DnsServerZone -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 1 -Scope It
            }

            It 'When Ensure is absent, removes the zone' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockSetParameters.Ensure = 'Absent'
                    Set-TargetResource @mockSetParameters
                }

                Should -Invoke Remove-DnsServerZone -Scope It
                Should -Invoke Add-DnsServerConditionalForwarderZone -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
            }
        }

        Context 'When the zone is not present on the server' {
            BeforeAll {
                Mock Get-DnsServerZone
            }

            It 'When Ensure is present, attempts to create the zone' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Set-TargetResource @mockSetParameters
                }

                Should -Invoke Add-DnsServerConditionalForwarderZone -Scope It
                Should -Invoke Remove-DnsServerZone -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 } -Times 0 -Scope It
                Should -Invoke Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 } -Times 0 -Scope It
            }
        }
    }
}

Context 'DSC_DnsServerConditionalForwarder\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        Mock Get-DnsServerZone {
            @{
                MasterServers          = '1.1.1.1', '2.2.2.2'
                ZoneType               = $script:zoneType
                IsDsIntegrated         = $script:isDsIntegrated
                ReplicationScope       = $script:ReplicationScope
                DirectoryPartitionName = 'CustomName'
            }
        }

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:defaultParameters = @{
                Ensure           = 'Present'
                Name             = 'domain.name'
                MasterServers    = '1.1.1.1', '2.2.2.2'
                ReplicationScope = 'Domain'
                Verbose          = $VerbosePreference
            }
        }
    }
    BeforeEach {
        $script:zoneType = 'Forwarder'
        $script:isDsIntegrated = $true
        $script:ReplicationScope = 'Domain'

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockTestParameters = $defaultParameters.Clone()
        }
    }
    Context 'When the system is in the desired state' {
        Context 'When the zone is present on the server' {
            It 'When Ensure is present, and the list of master servers matches, returns true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Test-TargetResource @mockTestParameters | Should -BeTrue
                }
            }
        }

        Context 'When the zone is not present on the server' {
            BeforeAll {
                Mock Get-DnsServerZone
            }

            It 'When Ensure is is absent, returns true' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockTestParameters.Ensure = 'Absent'

                    Test-TargetResource @mockTestParameters | Should -BeTrue
                }
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When the zone is present on the server' {
            It 'When Ensure is present, and the list of master servers differs, returns false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockTestParameters.MasterServers = '3.3.3.3', '4.4.4.4'

                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }

            It 'When Ensure is present, and the ZoneType does not match, returns false' {
                $script:ZoneType = 'Primary'

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }

            It 'When Ensure is present, and the zone is AD Integrated, and ReplicationScope is None, returns false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockTestParameters.ReplicationScope = 'None'

                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }

            It 'When Ensure is present, and the zone is not AD integrated, and ReplicationScope is Domain, returns false' {
                $script:isDsIntegrated = $false

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }

            It 'When Ensure is present, and the replication scope differs, returns false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockTestParameters.ReplicationScope = 'Forest'

                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }

            It 'When Ensure is present, and ReplicationScope is Custom, and the DirectoryPartitionName does not match, returns false' {
                $script:ReplicationScope = 'Custom'

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockTestParameters.ReplicationScope = 'Custom'
                    $mockTestParameters.DirectoryPartitionName = 'NewName'

                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }

            It 'When Ensure is absent, returns false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockTestParameters.Ensure = 'Absent'

                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }

            It 'When Ensure is absent, and a zone of a different type exists, returns true' {
                $script:ZoneType = 'Primary'

                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockTestParameters.Ensure = 'Absent'

                    Test-TargetResource @mockTestParameters | Should -BeTrue
                }
            }
        }

        Context 'When the zone is not present on the server' {
            BeforeAll {
                Mock Get-DnsServerZone
            }

            It 'When Ensure is present, returns false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    Test-TargetResource @mockTestParameters | Should -BeFalse
                }
            }
        }
    }
}

Context 'DSC_DnsServerConditionalForwarder\Test-DscDnsServerConditionalForwarderParameter' -Tag 'Helper' {
    BeforeAll {
        Mock Get-DnsServerZone {
            @{
                MasterServers          = '1.1.1.1', '2.2.2.2'
                ZoneType               = $script:zoneType
                IsDsIntegrated         = $script:isDsIntegrated
                ReplicationScope       = $script:ReplicationScope
                DirectoryPartitionName = 'CustomName'
            }
        }
        Mock Remove-DnsServerZone
        Mock Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -gt 0 }
        Mock Set-DnsServerConditionalForwarderZone -ParameterFilter { $MasterServers.Count -eq 0 }

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:defaultParameters = @{
                Ensure           = 'Present'
                Name             = 'domain.name'
                MasterServers    = '1.1.1.1', '2.2.2.2'
                ReplicationScope = 'Domain'
                Verbose          = $VerbosePreference
            }
        }
    }
    BeforeEach {
        $script:zoneType = 'Forwarder'
        $script:isDsIntegrated = $true
        $script:ReplicationScope = 'Domain'

        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockHelperParameters = $defaultParameters.Clone()
        }
    }
    It 'When Ensure is present, and MasterServers is not set, throws an error' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $mockHelperParameters.Remove('MasterServers')

            { Test-TargetResource @mockHelperParameters } | Should -Throw -ErrorId 'MasterServersIsMandatory*'
        }
    }

    It 'When Ensure is absent, and MasterServers is not set, does not not throw an error' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            { Test-TargetResource @mockHelperParameters } | Should -Not -Throw
        }
    }

    It 'When Ensure is present, and ReplicationScope is Custom, and DirectoryPartitionName is not set, throws an error' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $mockHelperParameters.ReplicationScope = 'Custom'
            $mockHelperParameters.DirectoryPartitionName = $null

            { Test-TargetResource @mockHelperParameters } | Should -Throw -ErrorId 'DirectoryPartitionNameIsMandatory*'
        }
    }
}
