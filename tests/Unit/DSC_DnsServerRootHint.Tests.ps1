<#
    .SYNOPSIS
        Unit test for DSC_DnsServerRootHint DSC resource.
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
    $script:dscResourceName = 'DSC_DnsServerRootHint'

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

Describe 'DSC_DnsServerRootHint\Get-TargetResource' {
    BeforeAll {
        Mock -CommandName Assert-Module

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
    }
    BeforeEach {
        InModuleScope -Parameters @{
            rootHints = $rootHints
        } -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:rootHintsHashtable = Convert-RootHintsToHashtable -RootHints $rootHints
            $script:rootHintsCim = ConvertTo-CimInstance -Hashtable $rootHintsHashtable
        }
    }

    Context 'When command completes' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
        }
        It 'Should return a "System.Collections.Hashtable" object type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Get-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose:$false
                $targetResource -is [System.Collections.Hashtable] | Should -BeTrue
            }
        }
    }

    Context 'When root hints exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
        }
        It "Should return NameServer = PredefinedValue" {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Get-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose:$false
                Test-DscDnsParameterState -CurrentValues $targetResource.NameServer -DesiredValues $rootHintsHashtable | Should -BeTrue
            }
        }
    }

    Context 'when root hints do not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return @() }
        }
        It 'Should return an empty NameServer' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Get-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose:$false
                $targetResource.NameServer.Count | Should -Be 0
            }
        }
    }
}


Describe 'DSC_DnsServerRootHint\Test-TargetResource' {
    BeforeAll {
        Mock -CommandName Assert-Module

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
    }
    BeforeEach {
        InModuleScope -Parameters @{
            rootHints = $rootHints
        } -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:rootHintsHashtable = Convert-RootHintsToHashtable -RootHints $rootHints
            $script:rootHintsCim = ConvertTo-CimInstance -Hashtable $rootHintsHashtable
        }
    }

    Context 'When command completes' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
        }
        It 'Should return a "System.Boolean" object type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $targetResource = Test-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose:$false
                $targetResource -is [System.Boolean] | Should -BeTrue
            }
        }
    }
    Context 'When forwarders match' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
        }
        It 'Should be $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Test-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose:$false | Should -BeTrue
            }
        }
    }
    Context 'When root hints do not match' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith {
                return @{
                    NameServer = @()
                }
            }
        }
        It 'Should be $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                Test-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose:$false | Should -BeFalse
            }
        }
    }
}

Describe 'DSC_DnsServerRootHint\Set-TargetResource' {
    BeforeAll {
        Mock -CommandName Remove-DnsServerRootHint -MockWith { }
        Mock -CommandName Add-DnsServerRootHint -MockWith { }
        Mock -CommandName Get-DnsServerRootHint -MockWith { }

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
    }
    BeforeEach {
        InModuleScope -Parameters @{
            rootHints = $rootHints
        } -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:rootHintsHashtable = Convert-RootHintsToHashtable -RootHints $rootHints
            $script:rootHintsCim = ConvertTo-CimInstance -Hashtable $rootHintsHashtable
        }
    }
    It "Should call Add-DnsServerRootHint 2 times" {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            Set-TargetResource -IsSingleInstance Yes -NameServer $rootHintsCim -Verbose:$false
        }
        Should -Invoke -CommandName Add-DnsServerRootHint -Times 2 -Exactly -Scope It
    }
}
