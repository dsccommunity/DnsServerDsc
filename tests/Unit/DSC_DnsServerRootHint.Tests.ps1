$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceName = 'DSC_DnsServerRootHint'

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
        $rootHints = @(
            [PSCustomObject]  @{
                NameServer = @{
                    RecordData = @{
                        NameServer = 'B.ROOT-SERVERS.NET.'
                    }
                }
                IPAddress  = @{
                    RecordData = @{
                        IPv4Address = @{
                            IPAddressToString = [IPAddress] '199.9.14.201'
                        }
                    }

                }
            },
            [PSCustomObject] @{
                NameServer = @{
                    RecordData = @{
                        NameServer = 'M.ROOT-SERVERS.NET.'
                    }
                }
                IPAddress  = @{
                    RecordData = @{
                        IPv4Address = @{
                            IPAddressToString = [IPAddress] '202.12.27.33'
                        }
                    }

                }
            }
        )

        $rootHintsHashtable = Convert-RootHintsToHashtable -RootHints $rootHints
        $rootHintsCim = ConvertTo-CimInstance -Hashtable $rootHintsHashtable
        #endregion

        #region Function Get-TargetResource
        Describe 'DSC_DnsServerRootHint\Get-TargetResource' {
            Mock -CommandName Assert-Module

            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
                $targetResource = Get-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It "Returns NameServer = <PredefinedValue> when root hints exist" {
                Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
                $targetResource = Get-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose
                Test-DscDnsParameterState -CurrentValues $targetResource.NameServer -DesiredValues $rootHintsHashtable | Should -Be $true
            }

            It "Returns an empty NameServer when root hints don't exist" {
                Mock -CommandName Get-DnsServerRootHint -MockWith { return @() }
                $targetResource = Get-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose
                $targetResource.NameServer.Count | Should Be 0
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'DSC_DnsServerRootHint\Test-TargetResource' {
            Mock -CommandName Assert-Module

            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
                $targetResource = Test-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose
                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Passes when forwarders match' {
                Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
                Test-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose | Should Be $true
            }

            It "Fails when root hints don't match" {
                Mock -CommandName Get-DnsServerRootHint -MockWith { return @{ NameServer = @() } }
                Test-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose | Should Be $false
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe 'DSC_DnsServerRootHint\Set-TargetResource' {
            It "Calls Add-DnsServerRootHint 2 times" {
                Mock -CommandName Remove-DnsServerRootHint -MockWith { }
                Mock -CommandName Add-DnsServerRootHint -MockWith { }
                Mock -CommandName Get-DnsServerRootHint -MockWith { }
                Set-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose
                Assert-MockCalled -CommandName Add-DnsServerRootHint -Times 2 -Exactly -Scope It
            }
        }
    } #end InModuleScope
}
finally
{
    Invoke-TestCleanup
}
