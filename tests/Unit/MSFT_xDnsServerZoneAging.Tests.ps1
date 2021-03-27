$script:dscModuleName = 'xDnsServer'
$script:dscResourceName = 'DSC_xDnsServerZoneAging'

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
        $zoneName = 'contoso.com'

        $getParameterEnable = @{
            Name    = $zoneName
            Enabled = $true
            Verbose = $true
        }

        $getParameterDisable = @{
            Name    = $zoneName
            Enabled = $false
            Verbose = $true
        }

        $testParameterEnable = @{
            Name              = $zoneName
            Enabled           = $true
            RefreshInterval   = 168
            NoRefreshInterval = 168
            Verbose           = $true
        }

        $testParameterDisable = @{
            Name              = $zoneName
            Enabled           = $false
            RefreshInterval   = 168
            NoRefreshInterval = 168
            Verbose           = $true
        }

        $setParameterEnable = @{
            Name    = $zoneName
            Enabled = $true
            Verbose = $true
        }

        $setParameterDisable = @{
            Name    = $zoneName
            Enabled = $false
            Verbose = $true
        }

        $setParameterRefreshInterval = @{
            Name            = $zoneName
            Enabled         = $true
            RefreshInterval = 24
            Verbose         = $true
        }

        $setParameterNoRefreshInterval = @{
            Name              = $zoneName
            Enabled           = $true
            NoRefreshInterval = 36
            Verbose           = $true
        }

        $setFilterEnable = {
            $Name -eq $zoneName -and
            $Aging -eq $true
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

        $fakeDnsServerZoneAgingEnabled = @{
            ZoneName          = $zoneName
            AgingEnabled      = $true
            RefreshInterval   = [System.TimeSpan]::FromHours(168)
            NoRefreshInterval = [System.TimeSpan]::FromHours(168)
        }

        $fakeDnsServerZoneAgingDisabled = @{
            ZoneName          = $zoneName
            AgingEnabled      = $false
            RefreshInterval   = [System.TimeSpan]::FromHours(168)
            NoRefreshInterval = [System.TimeSpan]::FromHours(168)
        }
        #endregion

        #region Function Get-TargetResource
        Describe 'DSC_xDnsServerZoneAging\Get-TargetResource' {
            Context "The zone aging on $zoneName is enabled" {
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                It 'Should return a "System.Collections.Hashtable" object type' {
                    $targetResource = Get-TargetResource @getParameterDisable

                    $targetResource | Should BeOfType [System.Collections.Hashtable]
                }

                It 'Should return valid values when aging is enabled' {
                    $targetResource = Get-TargetResource @getParameterEnable

                    $targetResource.Name | Should Be $testParameterEnable.Name
                    $targetResource.Enabled | Should Be $testParameterEnable.Enabled
                    $targetResource.RefreshInterval | Should Be $testParameterEnable.RefreshInterval
                    $targetResource.NoRefreshInterval | Should Be $testParameterEnable.NoRefreshInterval
                }
            }

            Context "The zone aging on $zoneName is disabled" {

                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                It 'Should return valid values when aging is not enabled' {
                    $targetResource = Get-TargetResource @getParameterDisable

                    $targetResource.Name | Should Be $testParameterDisable.Name
                    $targetResource.Enabled | Should Be $testParameterDisable.Enabled
                    $targetResource.RefreshInterval | Should Be $testParameterDisable.RefreshInterval
                    $targetResource.NoRefreshInterval | Should Be $testParameterDisable.NoRefreshInterval
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'DSC_xDnsServerZoneAging\Test-TargetResource' {
            Context "The zone aging on $zoneName is enabled" {
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                It 'Should return a "System.Boolean" object type' {
                    $targetResource = Test-TargetResource @testParameterDisable

                    $targetResource | Should BeOfType [System.Boolean]
                }

                It 'Should pass when everything matches (enabled)' {
                    $targetResource = Test-TargetResource @testParameterEnable

                    $targetResource | Should Be $true
                }

                It 'Should fail when everything matches (enabled)' {
                    $targetResource = Test-TargetResource @testParameterDisable

                    $targetResource | Should Be $false
                }
            }

            Context "The zone aging on $zoneName is disabled" {
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                It 'Should pass when everything matches (disabled)' {
                    $targetResource = Test-TargetResource @testParameterDisable

                    $targetResource | Should Be $true
                }

                It 'Should fail when everything matches (disabled)' {
                    $targetResource = Test-TargetResource @testParameterEnable

                    $targetResource | Should Be $false
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe 'DSC_xDnsServerZoneAging\Set-TargetResource' {
            Context "The zone aging on $zoneName is enabled" {
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                It 'Should disable the DNS zone aging' {
                    Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterDisable -Verifiable

                    Set-TargetResource @setParameterDisable

                    Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterDisable -Times 1 -Exactly -Scope It
                }

                It 'Should set the DNS zone refresh interval' {
                    Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterRefreshInterval -Verifiable

                    Set-TargetResource @setParameterRefreshInterval

                    Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterRefreshInterval -Times 1 -Exactly -Scope It
                }

                It 'Should set the DNS zone no refresh interval' {
                    Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterNoRefreshInterval -Verifiable

                    Set-TargetResource @setParameterNoRefreshInterval

                    Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterNoRefreshInterval -Times 1 -Exactly -Scope It
                }
            }

            Context "The zone aging on $zoneName is disabled" {
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                It 'Should enable the DNS zone aging' {
                    Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterEnable -Verifiable

                    Set-TargetResource @setParameterEnable

                    Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterEnable -Times 1 -Exactly -Scope It
                }
            }
        }
        #endregion
    }
}
finally
{
    Invoke-TestCleanup
}
