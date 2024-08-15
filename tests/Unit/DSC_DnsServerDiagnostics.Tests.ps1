<#
    .SYNOPSIS
        Unit test for DSC_DnsServerDiagnostics DSC resource.
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
    $script:dscResourceName = 'DSC_DnsServerDiagnostics'

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

Describe 'DSC_DnsServerDiagnostics\Get-TargetResource' -Tag 'Get' {
    Context 'When the resource exists' {
        BeforeAll {
            $mockGetDnsServerDiagnostics = @{
                DnsServer                            = 'dns1.company.local'
                Answers                              = $false
                EnableLogFileRollover                = $false
                EnableLoggingForLocalLookupEvent     = $false
                EnableLoggingForPluginDllEvent       = $false
                EnableLoggingForRecursiveLookupEvent = $false
                EnableLoggingForRemoteServerEvent    = $false
                EnableLoggingForServerStartStopEvent = $false
                EnableLoggingForTombstoneEvent       = $false
                EnableLoggingForZoneDataWriteEvent   = $false
                EnableLoggingForZoneLoadingEvent     = $false
                EnableLoggingToFile                  = $false
                EventLogLevel                        = 3
                FilterIPAddressList                  = '192.168.1.3', '192.168.1.4'
                FullPackets                          = $false
                LogFilePath                          = 'C:\Windows\System32\DNS_log\DNSDiagnostics.log'
                MaxMBFileSize                        = 400000000
                Notifications                        = $false
                Queries                              = $false
                QuestionTransactions                 = $false
                ReceivePackets                       = $false
                SaveLogsToPersistentStorage          = $false
                SendPackets                          = $false
                TcpPackets                           = $false
                UdpPackets                           = $false
                UnmatchedResponse                    = $false
                Update                               = $false
                UseSystemEventLog                    = $false
                WriteThrough                         = $false
            }

            Mock -CommandName Get-DnsServerDiagnostics -MockWith { $mockGetDnsServerDiagnostics }
        }

        It 'Should return "something"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $getResult = Get-TargetResource -DnsServer 'dns1.company.local'

                $getResult.DnsServer                            | Should -Be 'dns1.company.local'
                $getResult.Answers                              | Should -BeFalse
                $getResult.EnableLogFileRollover                | Should -BeFalse
                $getResult.EnableLoggingForLocalLookupEvent     | Should -BeFalse
                $getResult.EnableLoggingForPluginDllEvent       | Should -BeFalse
                $getResult.EnableLoggingForRecursiveLookupEvent | Should -BeFalse
                $getResult.EnableLoggingForRemoteServerEvent    | Should -BeFalse
                $getResult.EnableLoggingForServerStartStopEvent | Should -BeFalse
                $getResult.EnableLoggingForTombstoneEvent       | Should -BeFalse
                $getResult.EnableLoggingForZoneDataWriteEvent   | Should -BeFalse
                $getResult.EnableLoggingForZoneLoadingEvent     | Should -BeFalse
                $getResult.EnableLoggingToFile                  | Should -BeFalse
                $getResult.EventLogLevel                        | Should -Be 3
                $getResult.FilterIPAddressList                  | Should -Be @('192.168.1.3', '192.168.1.4')
                $getResult.FullPackets                          | Should -BeFalse
                $getResult.LogFilePath                          | Should -Be 'C:\Windows\System32\DNS_log\DNSDiagnostics.log'
                $getResult.MaxMBFileSize                        | Should -Be 400000000
                $getResult.Notifications                        | Should -BeFalse
                $getResult.Queries                              | Should -BeFalse
                $getResult.QuestionTransactions                 | Should -BeFalse
                $getResult.ReceivePackets                       | Should -BeFalse
                $getResult.SaveLogsToPersistentStorage          | Should -BeFalse
                $getResult.SendPackets                          | Should -BeFalse
                $getResult.TcpPackets                           | Should -BeFalse
                $getResult.UdpPackets                           | Should -BeFalse
                $getResult.UnmatchedResponse                    | Should -BeFalse
                $getResult.Update                               | Should -BeFalse
                $getResult.UseSystemEventLog                    | Should -BeFalse
                $getResult.WriteThrough                         | Should -BeFalse
            }
        }
    }
    Context 'When the resource does not exist' {
        BeforeAll {
            Mock -CommandName Get-DnsServerDiagnostics -MockWith { throw 'Invalid Class' }
        }

        It 'Get throws when DnsServerDiagnostics is not found' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0
                { Get-TargetResource -DnsServer 'dns1.company.local' } | Should -Throw 'Invalid Class'
            }
        }

        It 'Test throws when DnsServerDiagnostics is not found' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0
                { Get-TargetResource -DnsServer 'dns1.company.local' } | Should -Throw 'Invalid Class'
            }
        }
    }
}

Describe 'DSC_DnsServerDiagnostics\Test-TargetResource' -Tag 'Test' {
    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return @{
                    DnsServer                            = 'dns1.company.local'
                    Answers                              = $false
                    EnableLogFileRollover                = $false
                    EnableLoggingForLocalLookupEvent     = $false
                    EnableLoggingForPluginDllEvent       = $false
                    EnableLoggingForRecursiveLookupEvent = $false
                    EnableLoggingForRemoteServerEvent    = $false
                    EnableLoggingForServerStartStopEvent = $false
                    EnableLoggingForTombstoneEvent       = $false
                    EnableLoggingForZoneDataWriteEvent   = $false
                    EnableLoggingForZoneLoadingEvent     = $false
                    EnableLoggingToFile                  = $false
                    EventLogLevel                        = 3
                    FilterIPAddressList                  = '192.168.1.3', '192.168.1.4'
                    FullPackets                          = $false
                    LogFilePath                          = 'C:\Windows\System32\DNS_log\DNSDiagnostics.log'
                    MaxMBFileSize                        = 400000000
                    Notifications                        = $false
                    Queries                              = $false
                    QuestionTransactions                 = $false
                    ReceivePackets                       = $false
                    SaveLogsToPersistentStorage          = $false
                    SendPackets                          = $false
                    TcpPackets                           = $false
                    UdpPackets                           = $false
                    UnmatchedResponse                    = $false
                    Update                               = $false
                    UseSystemEventLog                    = $false
                    WriteThrough                         = $false
                }
            }
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'Answers'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLogFileRollover'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingForLocalLookupEvent'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingForPluginDllEvent'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingForRecursiveLookupEvent'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingForRemoteServerEvent'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingForServerStartStopEvent'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingForTombstoneEvent'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingForZoneDataWriteEvent'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingForZoneLoadingEvent'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableLoggingToFile'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EventLogLevel'
                    PropertyValue = 4
                }
                @{
                    PropertyName  = 'FilterIPAddressList'
                    PropertyValue = '192.168.1.1', '192.168.1.2'
                }
                @{
                    PropertyName  = 'FullPackets'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'LogFilePath'
                    PropertyValue = 'C:\Windows\System32\DNS\DNSDiagnostics.log'
                }
                @{
                    PropertyName  = 'MaxMBFileSize'
                    PropertyValue = 500000000
                }
                @{
                    PropertyName  = 'Notifications'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'Queries'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'QuestionTransactions'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'ReceivePackets'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'SaveLogsToPersistentStorage'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'SendPackets'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'TcpPackets'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'UdpPackets'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'UnmatchedResponse'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'Update'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'UseSystemEventLog'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'WriteThrough'
                    PropertyValue = $true
                }
            )
        }

        It 'Should return $false for property <PropertyName>' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceParameters = @{
                    DnsServer     = 'dns1.company.local'
                    $PropertyName = $PropertyValue
                }

                Test-TargetResource @testTargetResourceParameters | Should -BeFalse
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    DnsServer                            = 'dns1.company.local'
                    Answers                              = $false
                    EnableLogFileRollover                = $false
                    EnableLoggingForLocalLookupEvent     = $false
                    EnableLoggingForPluginDllEvent       = $false
                    EnableLoggingForRecursiveLookupEvent = $false
                    EnableLoggingForRemoteServerEvent    = $false
                    EnableLoggingForServerStartStopEvent = $false
                    EnableLoggingForTombstoneEvent       = $false
                    EnableLoggingForZoneDataWriteEvent   = $false
                    EnableLoggingForZoneLoadingEvent     = $false
                    EnableLoggingToFile                  = $false
                    EventLogLevel                        = 3
                    FilterIPAddressList                  = '192.168.1.3', '192.168.1.4'
                    FullPackets                          = $false
                    LogFilePath                          = 'C:\Windows\System32\DNS_log\DNSDiagnostics.log'
                    MaxMBFileSize                        = 400000000
                    Notifications                        = $false
                    Queries                              = $false
                    QuestionTransactions                 = $false
                    ReceivePackets                       = $false
                    SaveLogsToPersistentStorage          = $false
                    SendPackets                          = $false
                    TcpPackets                           = $false
                    UdpPackets                           = $false
                    UnmatchedResponse                    = $false
                    Update                               = $false
                    UseSystemEventLog                    = $false
                    WriteThrough                         = $false
                }
            }
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    PropertyName  = 'Answers'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLogFileRollover'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingForLocalLookupEvent'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingForPluginDllEvent'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingForRecursiveLookupEvent'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingForRemoteServerEvent'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingForServerStartStopEvent'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingForTombstoneEvent'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingForZoneDataWriteEvent'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingForZoneLoadingEvent'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableLoggingToFile'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EventLogLevel'
                    PropertyValue = 3
                }
                @{
                    PropertyName  = 'FilterIPAddressList'
                    PropertyValue = '192.168.1.3', '192.168.1.4'
                }
                @{
                    PropertyName  = 'FullPackets'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'LogFilePath'
                    PropertyValue = 'C:\Windows\System32\DNS_log\DNSDiagnostics.log'
                }
                @{
                    PropertyName  = 'MaxMBFileSize'
                    PropertyValue = 400000000
                }
                @{
                    PropertyName  = 'Notifications'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'Queries'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'QuestionTransactions'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'ReceivePackets'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'SaveLogsToPersistentStorage'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'SendPackets'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'TcpPackets'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'UdpPackets'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'UnmatchedResponse'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'Update'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'UseSystemEventLog'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'WriteThrough'
                    PropertyValue = $false
                }
            )
        }

        It 'Should return $true for property <PropertyName>' -TestCases $testCases {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testTargetResourceParameters = @{
                    DnsServer     = 'dns1.company.local'
                    $PropertyName = $PropertyValue
                }

                Test-TargetResource @testTargetResourceParameters | Should -BeTrue
            }
        }
    }
}

Describe 'DSC_DnsServerDiagnostics\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Set-DnsServerDiagnostics
    }
    
    It 'Should call expected mocks' {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $testParameters = @{
                DnsServer                            = 'dns1.company.local'
                Answers                              = $true
                EnableLogFileRollover                = $true
                EnableLoggingForLocalLookupEvent     = $true
                EnableLoggingForPluginDllEvent       = $true
                EnableLoggingForRecursiveLookupEvent = $true
                EnableLoggingForRemoteServerEvent    = $true
                EnableLoggingForServerStartStopEvent = $true
                EnableLoggingForTombstoneEvent       = $true
                EnableLoggingForZoneDataWriteEvent   = $true
                EnableLoggingForZoneLoadingEvent     = $true
                EnableLoggingToFile                  = $true
                EventLogLevel                        = 4
                FilterIPAddressList                  = '192.168.1.1', '192.168.1.2'
                FullPackets                          = $true
                LogFilePath                          = 'C:\Windows\System32\DNS\DNSDiagnostics.log'
                MaxMBFileSize                        = 500000000
                Notifications                        = $true
                Queries                              = $true
                QuestionTransactions                 = $true
                ReceivePackets                       = $true
                SaveLogsToPersistentStorage          = $true
                SendPackets                          = $true
                TcpPackets                           = $true
                UdpPackets                           = $true
                UnmatchedResponse                    = $true
                Update                               = $true
                UseSystemEventLog                    = $true
                WriteThrough                         = $true
            }

            Set-TargetResource @testParameters
        }
        Should -Invoke -CommandName Set-DnsServerDiagnostics -Times 1 -Exactly
    }
}
