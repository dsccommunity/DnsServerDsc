<#
    .SYNOPSIS
        Unit test for DSC_DnsServerZoneScope DSC resource.
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
    $script:dscResourceName = 'DSC_DnsServerZoneScope'

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

Describe 'DSC_DnsServerZoneScope\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        $ZoneScopePresent = {
            [PSCustomObject]@{
                ZoneName  = 'contoso.com'
                ZoneScope = 'ZoneScope'
                FileName  = 'ZoneScope.dns'
            }
        }
    }
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZoneScope -MockWith $ZoneScopePresent
        }
        It 'Should set Ensure to Present when the Zone Scope is Present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    ZoneName = 'contoso.com'
                    Name     = 'ZoneScope'
                    Verbose  = $false
                }

                $getTargetResourceResult = Get-TargetResource @params
                $getTargetResourceResult.Ensure | Should -Be 'Present'
                $getTargetResourceResult.Name | Should -Be 'ZoneScope'
                $getTargetResourceResult.ZoneName | Should -Be 'contoso.com'
                $getTargetResourceResult.ZoneFile | Should -Be 'ZoneScope.dns'
            }

            Should -Invoke -CommandName Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZoneScope
        }
        It 'Should set Ensure to Absent when the Zone Scope is not present' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    ZoneName = 'contoso.com'
                    Name     = 'ZoneScope'
                    Verbose  = $false
                }

                $getTargetResourceResult = Get-TargetResource @params
                $getTargetResourceResult.Ensure | Should -Be 'Absent'
                $getTargetResourceResult.Name | Should -Be 'ZoneScope'
                $getTargetResourceResult.ZoneName | Should -Be 'contoso.com'
            }

            Should -Invoke -CommandName Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_DnsServerZoneScope\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        $ZoneScopePresent = {
            [PSCustomObject]@{
                ZoneName  = 'contoso.com'
                ZoneScope = 'ZoneScope'
                FileName  = 'ZoneScope.dns'
            }
        }
    }
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZoneScope $ZoneScopePresent
        }
        It 'Should return True when the Zone Scope exists' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Ensure   = 'Present'
                    ZoneName = 'contoso.com'
                    Name     = 'ZoneScope'
                    Verbose  = $false
                }
                Test-TargetResource @params | Should -BeTrue
            }

            Should -Invoke -CommandName Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZoneScope
        }
        It 'Should return False when the Ensure doesnt match' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Ensure   = 'Present'
                    ZoneName = 'contoso.com'
                    Name     = 'ZoneScope'
                    Verbose  = $false
                }
                Test-TargetResource @params | Should -BeFalse
            }

            Should -Invoke -CommandName Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_DnsServerZoneScope\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        $ZoneScopePresent = {
            [PSCustomObject]@{
                ZoneName  = 'contoso.com'
                ZoneScope = 'ZoneScope'
                FileName  = 'ZoneScope.dns'
            }
        }
    }
    Context 'When the subnet does not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZoneScope
            Mock -CommandName Add-DnsServerZoneScope
        }
        It 'Should call Add-DnsServerZoneScope in the set method' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Ensure   = 'Present'
                    ZoneName = 'contoso.com'
                    Name     = 'ZoneScope'
                    Verbose  = $false
                }

                Set-TargetResource @params
            }

            Should -Invoke Add-DnsServerZoneScope -Scope It -ParameterFilter {
                $Name -eq 'ZoneScope' -and $ZoneName -eq 'contoso.com'
            }
            Should -Invoke Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
        }
    }
    Context 'When Ensure is Absent' {
        BeforeAll {
            Mock -CommandName Remove-DnsServerZoneScope
            Mock -CommandName Get-DnsServerZoneScope -MockWith { return $ZoneScopePresent }
        }
        It 'Should call Remove-DnsServerZoneScope in the set method' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Ensure   = 'Absent'
                    ZoneName = 'contoso.com'
                    Name     = 'ZoneScope'
                    Verbose  = $false
                }

                Set-TargetResource @params
            }

            Should -Invoke Remove-DnsServerZoneScope -Exactly -Times 1 -Scope It
            Should -Invoke Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
        }
    }
}
