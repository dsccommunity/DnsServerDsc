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
                Verbose = $true
            }
        }
    }
    It 'Returns a "System.Collections.Hashtable" object type' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Get-TargetResource @testParams
            $targetResource -is [System.Collections.Hashtable] | Should -BeTrue
        }
    }

    It 'Returns "Present" when DNS zone exists and "Ensure" = "Present"' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Get-TargetResource @testParams -ZoneFile 'example.com.dns'
            $targetResource.Ensure | Should -Be 'Present'
        }
    }

    It 'Returns "Absent" when DNS zone does not exists and "Ensure" = "Present"' {
        Mock -CommandName Get-DnsServerZone
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Get-TargetResource @testParams -ZoneFile 'example.com.dns'
            $targetResource.Ensure | Should -Be 'Absent'
        }
    }

    It 'Returns "Present" when DNS zone exists and "Ensure" = "Absent"' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Get-TargetResource @testParams -ZoneFile 'example.com.dns' -Ensure Absent
            $targetResource.Ensure | Should -Be 'Present'
        }
    }

    It 'Returns "Absent" when DNS zone does not exist and "Ensure" = "Absent"' {
        Mock -CommandName Get-DnsServerZone
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Get-TargetResource @testParams -ZoneFile 'example.com.dns' -Ensure Absent
            $targetResource.Ensure | Should -Be 'Absent'
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
                Verbose = $true
            }
        }
    }
    It 'Returns a "System.Boolean" object type' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $targetResource = Test-TargetResource @testParams
            $targetResource -is [System.Boolean] | Should -BeTrue
        }
    }

    It 'Passes when DNS zone exists and "Ensure" = "Present"' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Test-TargetResource @testParams -Ensure Present | Should -BeTrue
        }
    }

    It 'Passes when DNS zone does not exist and "Ensure" = "Absent"' {
        Mock -CommandName Get-DnsServerZone -MockWith { }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Test-TargetResource @testParams -Ensure Absent | Should -BeTrue
        }
    }

    It 'Passes when DNS zone "DynamicUpdate" is correct' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Test-TargetResource @testParams -Ensure Present -DynamicUpdate 'None' | Should -BeTrue
        }
    }

    It 'Fails when DNS zone exists and "Ensure" = "Absent"' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Test-TargetResource @testParams -Ensure Absent | Should -BeFalse
        }
    }

    It 'Fails when DNS zone does not exist and "Ensure" = "Present"' {
        Mock -CommandName Get-DnsServerZone -MockWith { }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Test-TargetResource @testParams -Ensure Present | Should -BeFalse
        }
    }

    It 'Fails when DNS zone "DynamicUpdate" is incorrect' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Test-TargetResource @testParams -Ensure Present -DynamicUpdate 'NonSecureAndSecure' -ZoneFile 'example.com.dns' | Should -BeFalse
        }
    }

    It 'Fails when DNS zone "ZoneFile" is incorrect' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Test-TargetResource @testParams -Ensure Present -DynamicUpdate 'None' -ZoneFile 'nonexistent.com.dns' | Should -BeFalse
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
                Verbose = $true
            }
        }
    }
    It 'Calls "Add-DnsServerPrimaryZone" when DNS zone does not exist and "Ensure" = "Present"' {
        Mock -CommandName Get-DnsServerZone
        Mock -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Set-TargetResource @testParams -Ensure Present -DynamicUpdate 'None' -ZoneFile 'example.com.dns'
        }
        Should -Invoke -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName } -Scope It
    }

    It 'Calls "Remove-DnsServerZone" when DNS zone does exist and "Ensure" = "Absent"' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        Mock -CommandName Remove-DnsServerZone
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Set-TargetResource @testParams -Ensure Absent -DynamicUpdate 'None' -ZoneFile 'example.com.dns'
        }
        Should -Invoke -CommandName Remove-DnsServerZone -Scope It
    }

    It 'Calls "Set-DnsServerPrimaryZone" when DNS zone "DynamicUpdate" is incorrect' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonSecureAndSecure' }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Set-TargetResource @testParams -Ensure Present -DynamicUpdate 'NonSecureAndSecure' -ZoneFile 'example.com.dns'
        }
        Should -Invoke -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonSecureAndSecure' } -Scope It
    }

    It 'Calls "Set-DnsServerPrimaryZone" when DNS zone "ZoneFile" is incorrect' {
        Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
        Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ZoneFile -eq 'nonexistent.com.dns' }
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Set-TargetResource @testParams -Ensure Present -DynamicUpdate 'None' -ZoneFile 'nonexistent.com.dns'
        }
        Should -Invoke -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ZoneFile -eq 'nonexistent.com.dns' } -Scope It
    }
}
