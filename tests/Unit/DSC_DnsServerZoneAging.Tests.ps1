<#
    .SYNOPSIS
        Unit test for DSC_DnsServerZoneAging DSC resource.
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
    $script:dscResourceName = 'DSC_DnsServerZoneAging'

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

Describe 'DSC_DnsServerZoneAging\Get-TargetResource' {
    BeforeAll {
        $zoneName = 'get.contoso.com'
    }
    Context "When zone aging is enabled" {
        BeforeAll {
            $fakeDnsServerZoneAgingEnabled = @{
                ZoneName          = $zoneName
                AgingEnabled      = $true
                RefreshInterval   = [System.TimeSpan]::FromHours(168)
                NoRefreshInterval = [System.TimeSpan]::FromHours(168)
            }

            Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }
        }
        BeforeEach {
            InModuleScope -Parameters @{
                zoneName = $zoneName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:getParameterEnable = @{
                    Name    = $zoneName
                    Enabled = $true
                    Verbose = $true
                }
                $script:getParameterDisable = @{
                    Name    = $zoneName
                    Enabled = $false
                    Verbose = $true
                }
                $script:testParameterEnable = @{
                    Name              = $zoneName
                    Enabled           = $true
                    RefreshInterval   = 168
                    NoRefreshInterval = 168
                    Verbose           = $true
                }
            }
        }
        It 'Should return a "System.Collections.Hashtable" object type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Get-TargetResource @getParameterDisable

                $targetResource | Should -BeOfType [System.Collections.Hashtable]
            }
        }
        It 'Should return valid values when aging is enabled' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Get-TargetResource @getParameterEnable

                $targetResource.Name | Should -Be $testParameterEnable.Name
                $targetResource.Enabled | Should -Be $testParameterEnable.Enabled
                $targetResource.RefreshInterval | Should -Be $testParameterEnable.RefreshInterval
                $targetResource.NoRefreshInterval | Should -Be $testParameterEnable.NoRefreshInterval
            }
        }
    }
    Context "When zone aging is disabled" {
        BeforeAll {
            $fakeDnsServerZoneAgingDisabled = @{
                ZoneName          = $zoneName
                AgingEnabled      = $false
                RefreshInterval   = [System.TimeSpan]::FromHours(168)
                NoRefreshInterval = [System.TimeSpan]::FromHours(168)
            }

            Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }
        }
        BeforeEach {
            InModuleScope -Parameters @{
                zoneName = $zoneName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:getParameterDisable = @{
                    Name    = $zoneName
                    Enabled = $false
                    Verbose = $true
                }
                $script:testParameterDisable = @{
                    Name              = $zoneName
                    Enabled           = $false
                    RefreshInterval   = 168
                    NoRefreshInterval = 168
                    Verbose           = $true
                }
            }
        }
        It 'Should return valid values when aging is not enabled' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Get-TargetResource @getParameterDisable

                $targetResource.Name | Should -Be $testParameterDisable.Name
                $targetResource.Enabled | Should -Be $testParameterDisable.Enabled
                $targetResource.RefreshInterval | Should -Be $testParameterDisable.RefreshInterval
                $targetResource.NoRefreshInterval | Should -Be $testParameterDisable.NoRefreshInterval
            }
        }
    }
}

Describe 'DSC_DnsServerZoneAging\Test-TargetResource' {
    BeforeAll {
        $zoneName = 'test.contoso.com'
    }
    Context "When zone aging is enabled" {
        BeforeAll {
            $fakeDnsServerZoneAgingEnabled = @{
                ZoneName          = $zoneName
                AgingEnabled      = $true
                RefreshInterval   = [System.TimeSpan]::FromHours(168)
                NoRefreshInterval = [System.TimeSpan]::FromHours(168)
            }

            Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }
        }
        BeforeEach {
            InModuleScope -Parameters @{
                zoneName = $zoneName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:testParameterEnable = @{
                    Name              = $zoneName
                    Enabled           = $true
                    RefreshInterval   = 168
                    NoRefreshInterval = 168
                    Verbose           = $true
                }

                $script:testParameterDisable = @{
                    Name              = $zoneName
                    Enabled           = $false
                    RefreshInterval   = 168
                    NoRefreshInterval = 168
                    Verbose           = $true
                }
            }
        }
        It 'Should return a "System.Boolean" object type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Test-TargetResource @testParameterDisable

                $targetResource | Should -BeOfType [System.Boolean]
            }
        }

        It 'Should pass when everything matches (enabled)' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Test-TargetResource @testParameterEnable

                $targetResource | Should -BeTrue
            }
        }

        It 'Should fail when everything matches (enabled)' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Test-TargetResource @testParameterDisable

                $targetResource | Should -BeFalse
            }
        }
    }

    Context "When zone aging is disabled" {
        BeforeAll {
            $fakeDnsServerZoneAgingDisabled = @{
                ZoneName          = $zoneName
                AgingEnabled      = $false
                RefreshInterval   = [System.TimeSpan]::FromHours(168)
                NoRefreshInterval = [System.TimeSpan]::FromHours(168)
            }

            Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }
        }
        BeforeEach {
            InModuleScope -Parameters @{
                zoneName = $zoneName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:testParameterEnable = @{
                    Name              = $zoneName
                    Enabled           = $true
                    RefreshInterval   = 168
                    NoRefreshInterval = 168
                    Verbose           = $true
                }

                $script:testParameterDisable = @{
                    Name              = $zoneName
                    Enabled           = $false
                    RefreshInterval   = 168
                    NoRefreshInterval = 168
                    Verbose           = $true
                }
            }
        }
        It 'Should pass when everything matches (disabled)' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Test-TargetResource @testParameterDisable

                $targetResource | Should -BeTrue
            }
        }
        It 'Should fail when everything matches (disabled)' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Test-TargetResource @testParameterEnable

                $targetResource | Should -BeFalse
            }
        }
    }
}

Describe 'DSC_DnsServerZoneAging\Set-TargetResource' {
    BeforeAll {
        $zoneName = 'set.contoso.com'
    }
    Context "When zone aging is enabled" {
        BeforeAll {
            $fakeDnsServerZoneAgingEnabled = @{
                ZoneName          = $zoneName
                AgingEnabled      = $true
                RefreshInterval   = [System.TimeSpan]::FromHours(168)
                NoRefreshInterval = [System.TimeSpan]::FromHours(168)
            }
            $setFilterDisable = {
                $Name -eq $zoneName -and
                $Aging -eq $false
            }
            $setFilterRefreshInterval = {
                $Name -eq $zoneName -and
                $RefreshInterval -eq ([System.TimeSpan]::FromHours(24))
            }
            $setFilterNoRefreshInterval = {
                $Name -eq $zoneName -and
                $NoRefreshInterval -eq ([System.TimeSpan]::FromHours(36))
            }

            Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }
        }
        BeforeEach {
            InModuleScope -Parameters @{
                zoneName = $zoneName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:setParameterDisable = @{
                    Name    = $zoneName
                    Enabled = $false
                    Verbose = $true
                }
                $script:setParameterRefreshInterval = @{
                    Name            = $zoneName
                    Enabled         = $true
                    RefreshInterval = 24
                    Verbose         = $true
                }
                $script:setParameterNoRefreshInterval = @{
                    Name              = $zoneName
                    Enabled           = $true
                    NoRefreshInterval = 36
                    Verbose           = $true
                }
            }
        }
        It 'Should disable the DNS zone aging' {
            Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterDisable -Verifiable
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Set-TargetResource @setParameterDisable
            }

            Should -Invoke -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterDisable -Times 1 -Exactly -Scope It
        }
        It 'Should set the DNS zone refresh interval' {
            Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterRefreshInterval -Verifiable

            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0
                Set-TargetResource @setParameterRefreshInterval
            }

            Should -Invoke -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterRefreshInterval -Times 1 -Exactly -Scope It
        }
        It 'Should set the DNS zone no refresh interval' {
            Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterNoRefreshInterval -Verifiable

            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Set-TargetResource @setParameterNoRefreshInterval
            }

            Should -Invoke -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterNoRefreshInterval -Times 1 -Exactly -Scope It
        }
    }

    Context "When zone aging is disabled" {
        BeforeAll {
            $fakeDnsServerZoneAgingDisabled = @{
                ZoneName          = $zoneName
                AgingEnabled      = $false
                RefreshInterval   = [System.TimeSpan]::FromHours(168)
                NoRefreshInterval = [System.TimeSpan]::FromHours(168)
            }
            $setFilterEnable = {
                $Name -eq $zoneName -and
                $Aging -eq $true
            }

            Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }
        }
        BeforeEach {
            InModuleScope -Parameters @{
                zoneName = $zoneName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:setParameterEnable = @{
                    Name    = $zoneName
                    Enabled = $true
                    Verbose = $true
                }
            }
        }
        It 'Should enable DNS zone aging' {
            Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterEnable -Verifiable

            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Set-TargetResource @setParameterEnable
            }

            Should -Invoke -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterEnable -Times 1 -Exactly -Scope It
        }
    }
}
