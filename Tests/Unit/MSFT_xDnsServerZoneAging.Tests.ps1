$Global:DSCModuleName      = 'xDnsServer'
$Global:DSCResourceName    = 'MSFT_xDnsServerZoneAging'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        $getParameterEnable = @{
            Name              = 'contoso.com'
            AgingEnabled      = $true
        }
        $getParameterDisable = @{
            Name              = 'contoso.com'
            AgingEnabled      = $false
        }
        $testParameterEnable = @{
            Name              = 'contoso.com'
            AgingEnabled      = $true
            RefreshInterval   = 168
            NoRefreshInterval = 168
        }
        $testParameterDisable = @{
            Name              = 'contoso.com'
            AgingEnabled      = $false
            RefreshInterval   = 168
            NoRefreshInterval = 168
        }
        $setParameterEnable = @{
            Name              = 'contoso.com'
            AgingEnabled      = $true
        }
        $setParameterDisable = @{
            Name              = 'contoso.com'
            AgingEnabled      = $false
        }
        $setParameterRefreshInterval = @{
            Name              = 'contoso.com'
            AgingEnabled      = $true
            RefreshInterval   = 24
        }
        $setParameterNoRefreshInterval = @{
            Name              = 'contoso.com'
            AgingEnabled      = $true
            NoRefreshInterval = 36
        }
        $setFilterEnable = {
            $Name -eq 'contoso.com' -and
            $Aging -eq $true
        }
        $setFilterDisable = {
            $Name -eq 'contoso.com' -and
            $Aging -eq $false
        }
        $setFilterRefreshInterval = {
            $Name -eq 'contoso.com' -and
            $RefreshInterval -eq ([System.TimeSpan]::FromHours(24))
        }
        $setFilterNoRefreshInterval = {
            $Name -eq 'contoso.com' -and
            $NoRefreshInterval -eq ([System.TimeSpan]::FromHours(36))
        }
        $fakeDnsServerZoneAgingEnabled = @{
            ZoneName          = 'contoso.com'
            AgingEnabled      = $true
            RefreshInterval   = [System.TimeSpan]::FromHours(168)
            NoRefreshInterval = [System.TimeSpan]::FromHours(168)
        }
        $fakeDnsServerZoneAgingDisabled = @{
            ZoneName          = 'contoso.com'
            AgingEnabled      = $false
            RefreshInterval   = [System.TimeSpan]::FromHours(168)
            NoRefreshInterval = [System.TimeSpan]::FromHours(168)
        }
        #endregion

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            It 'Returns a "System.Collections.Hashtable" object type' {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                # Act
                $targetResource = Get-TargetResource @getParameterDisable

                # Assert
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It "Returns valid values when aging is enabled" {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                # Act
                $targetResource = Get-TargetResource @getParameterEnable

                # Assert
                $targetResource.Name              | Should Be $testParameterEnable.Name
                $targetResource.AgingEnabled      | Should Be $testParameterEnable.AgingEnabled
                $targetResource.RefreshInterval   | Should Be $testParameterEnable.RefreshInterval
                $targetResource.NoRefreshInterval | Should Be $testParameterEnable.NoRefreshInterval
            }

            It "Returns valid values when aging is not enabled" {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                # Act
                $targetResource = Get-TargetResource @getParameterDisable

                # Assert
                $targetResource.Name              | Should Be $testParameterDisable.Name
                $targetResource.AgingEnabled      | Should Be $testParameterDisable.AgingEnabled
                $targetResource.RefreshInterval   | Should Be $testParameterDisable.RefreshInterval
                $targetResource.NoRefreshInterval | Should Be $testParameterDisable.NoRefreshInterval
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            It 'Returns a "System.Boolean" object type' {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                # Act
                $targetResource = Test-TargetResource @testParameterDisable

                # Assert
                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Passes when everything matches (enabled)' {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                # Act
                $targetResource = Test-TargetResource @testParameterEnable

                # Assert
                $targetResource | Should Be $true
            }

            It 'Passes when everything matches (disabled)' {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                # Act
                $targetResource = Test-TargetResource @testParameterDisable

                # Assert
                $targetResource | Should Be $true
            }

            It 'Fails when everything matches (enabled)' {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }

                # Act
                $targetResource = Test-TargetResource @testParameterDisable

                # Assert
                $targetResource | Should Be $false
            }

            It 'Fails when everything matches (disabled)' {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }

                # Act
                $targetResource = Test-TargetResource @testParameterEnable

                # Assert
                $targetResource | Should Be $false
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            It "Enable the DNS zone aging" {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingDisabled }
                Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterEnable -Verifiable

                # Act
                Set-TargetResource @setParameterEnable

                # Assert
                Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterEnable -Times 1 -Exactly -Scope It
            }

            It "Disable the DNS zone aging" {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }
                Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterDisable -Verifiable

                # Act
                Set-TargetResource @setParameterDisable

                # Assert
                Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterDisable -Times 1 -Exactly -Scope It
            }

            It "Set the DNS zone refresh interval" {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }
                Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterRefreshInterval -Verifiable

                # Act
                Set-TargetResource @setParameterRefreshInterval

                # Assert
                Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterRefreshInterval -Times 1 -Exactly -Scope It
            }

            It "Set the DNS zone no refresh interval" {

                # Arrange
                Mock -CommandName Get-DnsServerZoneAging -MockWith { return $fakeDnsServerZoneAgingEnabled }
                Mock -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterNoRefreshInterval -Verifiable

                # Act
                Set-TargetResource @setParameterNoRefreshInterval

                # Assert
                Assert-MockCalled -CommandName Set-DnsServerZoneAging -ParameterFilter $setFilterNoRefreshInterval -Times 1 -Exactly -Scope It
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
    } #end InModuleScope
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
