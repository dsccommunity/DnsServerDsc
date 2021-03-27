$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceName = 'DSC_xDnsServerZoneTransfer'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        #region Pester Test Initialization
        $testName = 'example.com'
        $testType = 'Any'
        $testSecondaryServer = '192.168.0.1', '192.168.0.2'

        $testParams = @{
            Name    = $testName
            Type    = $testType
            Verbose = $true
        }

        $testParamsAny = @{
            Name            = $testName
            Type            = 'Any'
            SecondaryServer = ''
            Verbose         = $true
        }

        $testParamsSpecific = @{
            Name            = $testName
            Type            = 'Specific'
            SecondaryServer = $testSecondaryServer
            Verbose         = $true
        }

        $testParamsSpecificDifferent = @{
            Name            = $testName
            Type            = 'Specific'
            SecondaryServer = '192.168.0.1', '192.168.0.2', '192.168.0.3'
            Verbose         = $true
        }

        $fakeCimInstanceAny = @{
            Name              = $testName
            SecureSecondaries = $XferId2Name.IndexOf('Any')
            SecondaryServers  = ''
        }

        $fakeCimInstanceNamed = @{
            Name              = $testName
            SecureSecondaries = $XferId2Name.IndexOf('Named')
            SecondaryServers  = ''
        }

        $fakeCimInstanceSpecific = @{
            Name              = $testName
            SecureSecondaries = $XferId2Name.IndexOf('Specific')
            SecondaryServers  = $testSecondaryServer
        }
        #endregion

        #region Function Get-TargetResource
        Describe 'DSC_xDnsServerZoneTransfer\Get-TargetResource' {
            Mock -CommandName Assert-Module

            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceAny }
                $targetResource = Get-TargetResource @testParams
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It "Returns SecondaryServer = $($testParams.SecondaryServer) when zone transfers set to specific" {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceSpecific }
                $targetResource = Get-TargetResource @testParams
                $targetResource.SecondaryServers | Should Be $testParams.SecondaryServers
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'DSC_xDnsServerZoneTransfer\Test-TargetResource' {
            Mock -CommandName Assert-Module

            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceAny }
                $targetResource = Test-TargetResource @testParamsAny
                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Passes when Zone Transfer Type matches' {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceAny }
                Test-TargetResource @testParamsAny | Should Be $true
            }

            It "Fails when Zone Transfer Type does not match" {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceNamed }
                Test-TargetResource @testParamsAny | Should Be $false
            }

            It 'Passes when Zone Transfer Secondaries matches' {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceSpecific }
                Test-TargetResource @testParamsSpecific | Should Be $true
            }

            It 'Passes when Zone Transfer Secondaries does not match' {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceSpecific }
                Test-TargetResource @testParamsSpecificDifferent | Should Be $false
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe 'DSC_xDnsServerZoneTransfer\Set-TargetResource' {
            Mock -CommandName Assert-Module

            function Invoke-CimMethod
            {
                [CmdletBinding()]
                param ( $InputObject, $MethodName, $Arguments )
            }

            Mock -CommandName Invoke-CimMethod
            Mock -CommandName Restart-Service

            It "Calls Invoke-CimMethod not called when Zone Transfer Type matches" {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceAny }
                Set-TargetResource @testParamsAny
                Assert-MockCalled -CommandName Invoke-CimMethod -Times 0 -Exactly -Scope It
            }

            It "Calls Invoke-CimMethod called once when Zone Transfer Type does not match" {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceNamed }
                Set-TargetResource @testParamsAny
                Assert-MockCalled -CommandName Invoke-CimMethod -Times 1 -Exactly -Scope It
            }

            It "Calls Invoke-CimMethod not called when Zone Transfer Secondaries matches" {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceSpecific }
                Set-TargetResource @testParamsSpecific
                Assert-MockCalled -CommandName Invoke-CimMethod -Times 0 -Exactly -Scope It
            }

            It "Calls Invoke-CimMethod called once when Zone Transfer Secondaries does not match" {
                Mock -CommandName Get-CimInstance -MockWith { return $fakeCimInstanceSpecific }
                Set-TargetResource @testParamsSpecificDifferent
                Assert-MockCalled -CommandName Invoke-CimMethod -Times 1 -Exactly -Scope It
            }
        }
    } #end InModuleScope
}
finally
{
    Invoke-TestCleanup
}
