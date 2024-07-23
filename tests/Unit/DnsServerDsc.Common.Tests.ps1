<#
    .SYNOPSIS
        Unit test for DnsServerDsc.Common.
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
    $script:subModuleName = 'DnsServerDsc.Common'

    $script:parentModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
    $script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'

    $script:subModulePath = Join-Path -Path $script:subModulesFolder -ChildPath $script:subModuleName

    Import-Module -Name $script:subModulePath -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:subModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:subModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:subModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:subModuleName -All | Remove-Module -Force
}

Describe 'DnsServerDsc.Common\ConvertTo-FollowRfc1034' -Tag 'ConvertTo-FollowRfc1034' {
    BeforeAll {
        $hostname = 'mail.contoso.com'
        $convertedHostname = 'mail.contoso.com.'
    }

    Context 'When the hostname is not converted' {
        It 'Should not throw exception' {
            { $script:result = $hostname | ConvertTo-FollowRfc1034 -Verbose } | Should -Not -Throw
        }

        It 'Should end in a .' {
            $script:result | Should -Be "$hostname."
        }
    }

    Context 'When the hostname is already converted' {
        It 'Should return the same as the input string' {
            $convertedHostname | ConvertTo-FollowRfc1034 -Verbose | Should -Be $convertedHostname
        }
    }
}

Describe 'DnsServerDsc.Common\Convert-RootHintsToHashtable' -Tag 'Convert-RootHintsToHashtable' {
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
