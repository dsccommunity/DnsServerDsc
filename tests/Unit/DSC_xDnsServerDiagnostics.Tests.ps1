$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceName = 'DSC_xDnsServerDiagnostics'

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
            FilterIPAddressList                  = "192.168.1.1","192.168.1.2"
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
            FilterIPAddressList                  = "192.168.1.3","192.168.1.4"
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

        $commonParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        $commonParameters += [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

        $mockParameters = @{
            Verbose             = $true
            Debug               = $true
            ErrorAction         = 'stop'
            WarningAction       = 'Continue'
            InformationAction   = 'Continue'
            ErrorVariable       = 'err'
            WarningVariable     = 'warn'
            OutVariable         = 'out'
            OutBuffer           = 'outbuff'
            PipelineVariable    = 'pipe'
            InformationVariable = 'info'
            WhatIf              = $true
            Confirm             = $true
            UseTransaction      = $true
            DnsServer           = 'dns1.company.local'
        }
        #endregion Pester Test Initialization

        #region Example state 1
        Describe 'The system is not in the desired state' {
            Mock -CommandName Assert-Module

            Context 'Get-TargetResource' {
                It "Get method returns 'something'" {
                    Mock -CommandName Get-DnsServerDiagnostics -MockWith {$mockGetDnsServerDiagnostics}

                    $getResult = Get-TargetResource -DnsServer 'dns1.company.local'

                    foreach ($key in $getResult.Keys)
                    {
                        if ($null -ne $getResult[$key] -and $key -ne 'DnsServer')
                        {
                            $getResult[$key] | Should be $mockGetDnsServerDiagnostics.$key
                        }
                    }
                }

                It 'Get throws when DnsServerDiagnostics is not found' {
                    Mock -CommandName Get-DnsServerDiagnostics -MockWith {throw 'Invalid Class'}

                    {Get-TargetResource -DnsServer 'dns1.company.local'} | Should -Throw 'Invalid Class'
                }
            }

            Context 'Test-TargetResource' {
                $falseParameters = @{
                    DnsServer = 'dns1.company.local'
                }

                foreach ($key in $testParameters.Keys)
                {
                    if ($key -ne 'DnsServer')
                    {
                        $falseTestParameters = $falseParameters.Clone()
                        $falseTestParameters.Add($key,$testParameters[$key])

                        It "Test method returns false when testing $key" {
                            Mock -CommandName Get-TargetResource -MockWith {$mockGetDnsServerDiagnostics}

                            Test-TargetResource @falseTestParameters | Should -BeFalse
                        }
                    }
                }
            }

            Context 'Error handling' {
                It 'Test throws when DnsServerDiagnostics is not found' {
                    Mock -CommandName Get-DnsServerDiagnostics -MockWith {throw 'Invalid Class'}

                    {Get-TargetResource -DnsServer 'dns1.company.local'} | Should -Throw 'Invalid Class'
                }
            }

            Context 'Set-TargetResource' {
                It 'Set method calls Set-CimInstance' {
                    Mock -CommandName Get-DnsServerDiagnostics -MockWith {$mockGetDnsServerDiagnostics}
                    Mock -CommandName Set-DnsServerDiagnostics

                    Set-TargetResource @testParameters

                    Assert-MockCalled Set-DnsServerDiagnostics -Exactly 1
                }
            }
        }
        #endregion Example state 1

        #region Example state 2
        Describe 'The system is in the desired state' {
            Context 'Test-TargetResource' {
                Mock -CommandName Get-TargetResource -MockWith { $mockGetDnsServerDiagnostics }

                $trueParameters = @{
                    DnsServer = 'dns1.company.local'
                }

                foreach ($key in $testParameters.Keys)
                {
                    if ($key -ne 'DnsServer')
                    {
                        $trueTestParameters = $trueParameters.Clone()

                        $trueTestParameters.Add($key,$mockGetDnsServerDiagnostics.$key)

                        It "Test method returns true when testing $key" {
                            $result = Test-TargetResource @trueTestParameters
                            $result | Should -BeTrue
                        }
                    }
                }

            }
        }
        #endregion Example state 2

        #region Non-Exported Function Unit Tests

        Describe 'Private functions' {
            Context 'Remove-CommonParameters' {
                It 'Should not contain any common parameters' {
                    $removeResults = Remove-CommonParameter $mockParameters

                    foreach ($key in $removeResults.Keys)
                    {
                        $commonParameters -notcontains $key | Should -BeTrue
                    }
                }
            }
        }
        #endregion Non-Exported Function Unit Tests
    }
}
finally
{
    Invoke-TestCleanup
}
