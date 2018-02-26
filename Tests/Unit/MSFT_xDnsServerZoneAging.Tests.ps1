$Global:DSCModuleName   = 'xDnsServer'
$Global:DSCResourceName = 'MSFT_xDnsServerZoneAging'

#region HEADER

# Unit Test Template Version: 1.2.1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit

#endregion HEADER

function Invoke-TestSetup {
    # TODO: Optional init code goes here...
}

function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    # TODO: Other Optional Cleanup Code Goes Here...
}

# Begin Testing
try
{
    Invoke-TestSetup

    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        $zoneName = 'contoso.com'
        $getParameterEnable = @{
            Name              = $zoneName
            Enabled           = $true
        }
        $getParameterDisable = @{
            Name              = $zoneName
            Enabled           = $false
        }
        $testParameterEnable = @{
            Name              = $zoneName
            Enabled           = $true
            RefreshInterval   = 168
            NoRefreshInterval = 168
        }
        $testParameterDisable = @{
            Name              = $zoneName
            Enabled           = $false
            RefreshInterval   = 168
            NoRefreshInterval = 168
        }
        $setParameterEnable = @{
            Name              = $zoneName
            Enabled           = $true
        }
        $setParameterDisable = @{
            Name              = $zoneName
            Enabled           = $false
        }
        $setParameterRefreshInterval = @{
            Name              = $zoneName
            Enabled           = $true
            RefreshInterval   = 24
        }
        $setParameterNoRefreshInterval = @{
            Name              = $zoneName
            Enabled           = $true
            NoRefreshInterval = 36
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
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            Context "The zone aging on $zoneName is enabled" {

                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                It 'Returns a "System.Collections.Hashtable" object type' {

                    # Act
                    $targetResource = Get-TargetResource @getParameterDisable

                    # Assert
                    $targetResource -is [System.Collections.Hashtable] | Should Be $true
                }

                It "Returns valid values when aging is enabled" {

                    # Act
                    $targetResource = Get-TargetResource @getParameterEnable

                    # Assert
                    $targetResource.Name              | Should Be $testParameterEnable.Name
                    $targetResource.AgingEnabled      | Should Be $testParameterEnable.AgingEnabled
                    $targetResource.RefreshInterval   | Should Be $testParameterEnable.RefreshInterval
                    $targetResource.NoRefreshInterval | Should Be $testParameterEnable.NoRefreshInterval
                }
            }

            Context "The zone aging on $zoneName is disabled" {

                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                It "Returns valid values when aging is not enabled" {

                    # Act
                    $targetResource = Get-TargetResource @getParameterDisable

                    # Assert
                    $targetResource.Name              | Should Be $testParameterDisable.Name
                    $targetResource.AgingEnabled      | Should Be $testParameterDisable.AgingEnabled
                    $targetResource.RefreshInterval   | Should Be $testParameterDisable.RefreshInterval
                    $targetResource.NoRefreshInterval | Should Be $testParameterDisable.NoRefreshInterval
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            Context "The zone aging on $zoneName is enabled" {

                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                It 'Returns a "System.Boolean" object type' {

                    # Act
                    $targetResource = Test-TargetResource @testParameterDisable

                    # Assert
                    $targetResource -is [System.Boolean] | Should Be $true
                }

                It 'Passes when everything matches (enabled)' {

                    # Act
                    $targetResource = Test-TargetResource @testParameterEnable

                    # Assert
                    $targetResource | Should Be $true
                }

                It 'Fails when everything matches (enabled)' {

                    # Act
                    $targetResource = Test-TargetResource @testParameterDisable

                    # Assert
                    $targetResource | Should Be $false
                }
            }

            Context "The zone aging on $zoneName is disabled" {

                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                It 'Passes when everything matches (disabled)' {

                    # Act
                    $targetResource = Test-TargetResource @testParameterDisable

                    # Assert
                    $targetResource | Should Be $true
                }

                It 'Fails when everything matches (disabled)' {

                    # Act
                    $targetResource = Test-TargetResource @testParameterEnable

                    # Assert
                    $targetResource | Should Be $false
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            Context "The zone aging on $zoneName is enabled" {

                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                It "Disable the DNS zone aging" {

                    # Arrange
                    Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterDisable -Verifiable

                    # Act
                    Set-TargetResource @setParameterDisable

                    # Assert
                    Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterDisable -Times 1 -Exactly -Scope It
                }

                It "Set the DNS zone refresh interval" {

                    # Arrange
                    Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterRefreshInterval -Verifiable

                    # Act
                    Set-TargetResource @setParameterRefreshInterval

                    # Assert
                    Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterRefreshInterval -Times 1 -Exactly -Scope It
                }

                It "Set the DNS zone no refresh interval" {

                    # Arrange
                    Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterNoRefreshInterval -Verifiable

                    # Act
                    Set-TargetResource @setParameterNoRefreshInterval

                    # Assert
                    Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterNoRefreshInterval -Times 1 -Exactly -Scope It
                }
            }

            Context "The zone aging on $zoneName is disabled" {

                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                It "Enable the DNS zone aging" {

                    # Arrange
                    Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterEnable -Verifiable

                    # Act
                    Set-TargetResource @setParameterEnable

                    # Assert
                    Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterEnable -Times 1 -Exactly -Scope It
                }
            }



            # It "Calls Invoke-CimMethod called once when Zone Transfer Type does not match" {
            #     Mock -CommandName Get-DnsServerZoneAging -MockWith {return $fakeCimInstanceNamed}
            #     Set-TargetResource @testParamsAny
            #     Assert-MockCalled -CommandName Invoke-CimMethod -Times 1 -Exactly -Scope It
            # }

            # It "Calls Invoke-CimMethod not called when Zone Transfer Secondaries matches" {
            #     Mock -CommandName Get-DnsServerZoneAging -MockWith {return $fakeCimInstanceSpecific}
            #     Set-TargetResource @testParamsSpecific
            #     Assert-MockCalled -CommandName Invoke-CimMethod -Times 0 -Exactly -Scope It
            # }

            # It "Calls Invoke-CimMethod called once when Zone Transfer Secondaries does not match" {
            #     Mock -CommandName Get-DnsServerZoneAging -MockWith {return $fakeCimInstanceSpecific}
            #     Set-TargetResource @testParamsSpecificDifferent
            #     Assert-MockCalled -CommandName Invoke-CimMethod -Times 1 -Exactly -Scope It
            # }
        }
        #endregion
    }
}
finally
{
    Invoke-TestCleanup
}
