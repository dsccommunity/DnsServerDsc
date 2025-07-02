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
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
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

        $rootHintsHashtable = Convert-RootHintsToHashtable -RootHints $rootHints
        $rootHintsCim = ConvertTo-CimInstance -Hashtable $rootHintsHashtable
    }

    Context 'When command completes' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
        }

        It 'Should return a "System.Collections.Hashtable" object type' {
            InModuleScope -Parameters @{
                rootHintsCim = $rootHintsCim
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    IsSingleInstance = 'Yes'
                    NameServer       = $rootHintsCim
                    Verbose          = $false
                }

                Get-TargetResource @params | Should -BeOfType [System.Collections.Hashtable]
            }
        }
    }

    Context 'When root hints exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
        }

        It 'Should return NameServer = PredefinedValue' {
            InModuleScope -Parameters @{
                rootHintsCim       = $rootHintsCim
                rootHintsHashtable = $rootHintsHashtable
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    IsSingleInstance = 'Yes'
                    NameServer       = $rootHintsCim
                    Verbose          = $false
                }

                $targetResource = Get-TargetResource @params
                Test-DscParameterState -CurrentValues $targetResource.NameServer -DesiredValues $rootHintsHashtable | Should -BeTrue
            }
        }
    }

    Context 'when root hints do not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return @() }
        }

        It 'Should return an empty NameServer' {
            InModuleScope -Parameters @{
                rootHintsCim = $rootHintsCim
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    IsSingleInstance = 'Yes'
                    NameServer       = $rootHintsCim
                    Verbose          = $false
                }

                $targetResource = Get-TargetResource @params
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

        $rootHintsHashtable = Convert-RootHintsToHashtable -RootHints $rootHints
        $rootHintsCim = ConvertTo-CimInstance -Hashtable $rootHintsHashtable
    }

    Context 'When command completes' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
        }

        It 'Should return a "System.Boolean" object type' {
            InModuleScope -Parameters @{
                rootHintsCim = $rootHintsCim
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    IsSingleInstance = 'Yes'
                    NameServer       = $rootHintsCim
                    Verbose          = $false
                }

                Test-TargetResource @params | Should -BeOfType [System.Boolean]
            }
        }
    }

    Context 'When forwarders match' {
        BeforeAll {
            Mock -CommandName Get-DnsServerRootHint -MockWith { return $rootHints }
        }

        It 'Should be $true' {
            InModuleScope -Parameters @{
                rootHintsCim = $rootHintsCim
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    IsSingleInstance = 'Yes'
                    NameServer       = $rootHintsCim
                    Verbose          = $false
                }

                Test-TargetResource @params | Should -BeTrue
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
            InModuleScope -Parameters @{
                rootHintsCim = $rootHintsCim
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    IsSingleInstance = 'Yes'
                    NameServer       = $rootHintsCim
                    Verbose          = $false
                }

                Test-TargetResource @params | Should -BeFalse
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

        $rootHintsHashtable = Convert-RootHintsToHashtable -RootHints $rootHints
        $rootHintsCim = ConvertTo-CimInstance -Hashtable $rootHintsHashtable
    }

    It 'Should call Add-DnsServerRootHint 2 times' {
        InModuleScope -Parameters @{
            rootHintsCim = $rootHintsCim
        } -ScriptBlock {
            Set-StrictMode -Version 1.0

            $params = @{
                IsSingleInstance = 'Yes'
                NameServer       = $rootHintsCim
                Verbose          = $false
            }

            Set-TargetResource @params
        }

        Should -Invoke -CommandName Add-DnsServerRootHint -Times 2 -Exactly -Scope It
    }
}

Describe 'DSC_DnsServerRootHint\Convert-RootHintsToHashtable' {
    BeforeAll {
        $emptyRootHints = @()
        $rootHintWithoutIP = @(
            @{
                NameServer = @{
                    RecordData = @{
                        NameServer = 'ns1'
                    }
                }
                IPAddress  = $null
            }
        )
        $rootHintWithIPv4 = @(
            @{
                NameServer = @{
                    RecordData = @{
                        NameServer = 'ns2'
                    }
                }
                IPAddress  = @{
                    RecordData = @{
                        IPv6Address = @{
                            IPAddressToString = '192.0.2.1'
                        }
                    }
                }
            }
        )
        $rootHintWithIPv6 = @(
            @{
                NameServer = @{
                    RecordData = @{
                        NameServer = 'ns3'
                    }
                }
                IPAddress  = @{
                    RecordData = @{
                        IPv6Address = @{
                            IPAddressToString = '2001:db8::1'
                        }
                    }
                }
            }
        )
    }

    It 'Should return an empty hashtable when the input array is empty' {
        $result = Convert-RootHintsToHashtable -RootHints $emptyRootHints
        $result.Count | Should -Be 0
    }

    It 'Should correctly skip elements without an IPAddress' {
        $result = Convert-RootHintsToHashtable -RootHints $rootHintWithoutIP
        $result.Count | Should -Be 0
    }

    It 'Should correctly handle elements with an IPv4 address' {
        $result = Convert-RootHintsToHashtable -RootHints $rootHintWithIPv4
        $result.Count | Should -Be 1
        $result.ns2 | Should -Be '192.0.2.1'
    }

    It 'Should correctly handle elements with an IPv6 address' {
        $result = Convert-RootHintsToHashtable -RootHints $rootHintWithIPv6
        $result.Count | Should -Be 1
        $result.ns3 | Should -Be '2001:db8::1'
    }
}
