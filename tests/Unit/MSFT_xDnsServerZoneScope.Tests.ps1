$script:dscModuleName = 'xDnsServer'
$script:dscResourceName = 'MSFT_xDnsServerZoneScope'

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
        $mocks = @{
            ZoneScopePresent = {
                [PSCustomObject]@{
                    ZoneName = 'contoso.com'
                    Name     = 'ZoneScope'
                }
            }
            Absent  = { }
        }
        #endregion

        #region Function Get-TargetResource
        Describe "MSFT_xDnsServerZoneScope\Get-TargetResource" -Tag 'Get' {
            Context 'When the system is in the desired state' {
                It 'Should set Ensure to Present when the Zone Scope is Present' {
                    Mock -CommandName Get-DnsServerZoneScope $mocks.ZoneScopePresent

                    $getTargetResourceResult = Get-TargetResource -ZoneName 'contoso.com' -Name 'ZoneScope'
                    $getTargetResourceResult.Ensure | Should -Be 'Present'
                    $getTargetResourceResult.Name | Should -Be 'ZoneScope'
                    $getTargetResourceResult.ZoneName | Should -Be 'contoso.com'

                    Assert-MockCalled -CommandName Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
                }
            }

            Context 'When the system is not in the desired state' {
                It 'Should set Ensure to Absent when the Zone Scope is not present' {
                    Mock -CommandName Get-DnsServerZoneScope $mocks.Absent

                    $getTargetResourceResult = Get-TargetResource -ZoneName 'contoso.com' -Name 'ZoneScope'
                    $getTargetResourceResult.Ensure | Should -Be 'Absent'
                    $getTargetResourceResult.Name | Should -Be 'ZoneScope'
                    $getTargetResourceResult.ZoneName | Should -Be 'contoso.com'

                    Assert-MockCalled -CommandName Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
                }
            }
        }
        #endregion Function Get-TargetResource

        #region Function Test-TargetResource
        Describe "MSFT_xDnsServerZoneScope\Test-TargetResource" -Tag 'Test' {
            Context 'When the system is in the desired state' {
                It 'Should return True when the Zone Scope exists' {
                    Mock -CommandName Get-DnsServerZoneScope $mocks.ZoneScopePresent
                    $params = @{
                        Ensure   = 'Present'
                        ZoneName = 'contoso.com'
                        Name     = 'ZoneScope'
                    }
                    Test-TargetResource @params | Should -BeTrue

                    Assert-MockCalled -CommandName Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
                }
            }

            Context 'When the system is not in the desired state' {
                It 'Should return False when the Ensure doesnt match' {
                    Mock -CommandName Get-DnsServerZoneScope $mocks.Absent
                    $params = @{
                        Ensure   = 'Present'
                        ZoneName = 'contoso.com'
                        Name     = 'ZoneScope'
                    }
                    Test-TargetResource @params | Should -BeFalse

                    Assert-MockCalled -CommandName Get-DnsServerZoneScope -Exactly -Times 1 -Scope It
                }
            }
       }
        #endregion

        #region Function Set-TargetResource
        Describe "MSFT_xDnsServerZoneScope\Set-TargetResource" -Tag 'Set' {
            Context 'When configuring DNS Server Zone Scopes' {
                It 'Calls Add-DnsServerZoneScope in the set method when the subnet does not exist' {
                    Mock -CommandName Get-DnsServerZoneScope
                    Mock -CommandName Add-DnsServerZoneScope

                    $params = @{
                        Ensure   = 'Present'
                        ZoneName = 'contoso.com'
                        Name     = 'ZoneScope'
                    }
                    Set-TargetResource @params

                    Assert-MockCalled Add-DnsServerZoneScope -Scope It -ParameterFilter {
                        $Name -eq 'ZoneScope' -and $ZoneName -eq 'contoso.com'
                    }
                }

                It 'Calls Remove-DnsServerZoneScope in the set method when Ensure is Absent' {
                    Mock -CommandName Remove-DnsServerZoneScope
                    Mock -CommandName Get-DnsServerZoneScope { return $mocks.ZoneScopePresent }
                    $params = @{
                        Ensure   = 'Absent'
                        ZoneName = 'contoso.com'
                        Name     = 'ZoneScope'
                    }
                    Set-TargetResource @params

                    Assert-MockCalled Remove-DnsServerZoneScope -Scope It
                }
            }
        }
        #endregion
    } #end InModuleScope
}
finally
{
    Invoke-TestCleanup
}
