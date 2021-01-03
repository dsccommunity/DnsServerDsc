$script:dscModuleName = 'xDnsServer'
$script:dscResourceName = 'MSFT_xDnsRecordSrv'

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
        $dnsRecordsToTest = @(
            @{
                TestParameters = @{
                    Zone      = 'contoso.com'
                    SymbolicName = "xmpp"
                    Protocol  = "TCP"
                    Port      = 5222
                    Target    = 'chat.contoso.com'
                    Priority  = 20
                    Weight    = 30
                    TTL       = '02:00:00'
                    DnsServer = 'localhost'
                    Ensure    = 'Present'
                    Verbose   = $true
                }
                MockRecord     = Import-Clixml -Path "$PSScriptRoot\MockObjects\SrvRecordInstance.xml"
            }
        )
        #endregion

        #region Function Get-TargetResource
        Describe 'MSFT_xDnsRecordSrv\Get-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                Context "When managing SRV type DNS record" {
                    $presentParameters = $dnsRecord.TestParameters

                    It "Should return Ensure is Present when DNS record exists" {
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $dnsRecord.MockRecord }
                        (Get-TargetResource @presentParameters).Ensure | Should Be 'Present'
                    }

                    It "Should returns Ensure is Absent when DNS record does not exist" {
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $null }
                        (Get-TargetResource @presentParameters).Ensure | Should Be 'Absent'
                    }
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe 'MSFT_xDnsRecordSrv\Test-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                Context "When managing SRV type DNS record" {
                    $presentParameters = $dnsRecord.TestParameters
                    $absentParameters = $presentParameters.Clone()
                    $absentParameters['Ensure'] = 'Absent'

                    $undefinedOptionalParameters = $presentParameters.Clone()
                    $undefinedOptionalParameters.Remove('TTL')

                    It "Should fail when no DNS record exists and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith { return $absentParameters }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, symbolic name does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Zone         = $presentParameters.Zone
                                SymbolicName = "doom"
                                Protocol     = $presentParameters.Protocol
                                Port         = $presentParameters.Port
                                Target       = $presentParameters.Target
                                DnsServer    = $presentParameters.DnsServer
                                Priority     = $presentParameters.Priority
                                Weight       = $presentParameters.Weight
                                TTL          = $presentParameters.TTL
                                Ensure       = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, protocol does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Zone         = $presentParameters.Zone
                                SymbolicName = $presentParameters.SymbolicName
                                Protocol     = "udp"
                                Port         = $presentParameters.Port
                                Target       = $presentParameters.Target
                                DnsServer    = $presentParameters.DnsServer
                                Priority     = $presentParameters.Priority
                                Weight       = $presentParameters.Weight
                                TTL          = $presentParameters.TTL
                                Ensure       = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, port does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Zone         = $presentParameters.Zone
                                SymbolicName = $presentParameters.SymbolicName
                                Protocol     = $presentParameters.Protocol
                                Port         = 666
                                Target       = $presentParameters.Target
                                DnsServer    = $presentParameters.DnsServer
                                Priority     = $presentParameters.Priority
                                Weight       = $presentParameters.Weight
                                TTL          = $presentParameters.TTL
                                Ensure       = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, target does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Zone         = $presentParameters.Zone
                                SymbolicName = $presentParameters.SymbolicName
                                Protocol     = $presentParameters.Protocol
                                Port         = $presentParameters.Port
                                Target       = "bad.contoso.com"
                                DnsServer    = $presentParameters.DnsServer
                                Priority     = $presentParameters.Priority
                                Weight       = $presentParameters.Weight
                                TTL          = $presentParameters.TTL
                                Ensure       = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, Priority does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                SymbolicName = $presentParameters.SymbolicName
                                Protocol     = $presentParameters.Protocol
                                Port         = $presentParameters.Port
                                Zone      = $presentParameters.Zone
                                Target    = $presentParameters.Target
                                DnsServer = $presentParameters.DnsServer
                                Priority  = 50
                                Weight    = $presentParameters.Weight
                                TTL       = $presentParameters.TTL
                                Ensure    = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, Weight does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                SymbolicName = $presentParameters.SymbolicName
                                Protocol     = $presentParameters.Protocol
                                Port         = $presentParameters.Port
                                Zone      = $presentParameters.Zone
                                Target    = $presentParameters.Target
                                DnsServer = $presentParameters.DnsServer
                                Priority  = $presentParameters.Priority
                                Weight    = 50
                                TTL       = $presentParameters.TTL
                                Ensure    = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, TTL does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                SymbolicName = $presentParameters.SymbolicName
                                Protocol     = $presentParameters.Protocol
                                Port         = $presentParameters.Port
                                Zone      = $presentParameters.Zone
                                Target    = $presentParameters.Target
                                DnsServer = $presentParameters.DnsServer
                                Priority  = $presentParameters.Priority
                                Weight    = $presentParameters.Weight
                                TTL       = "00:05:00"
                                Ensure    = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should pass when a record exists and TTL is not defined, and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                SymbolicName = $presentParameters.SymbolicName
                                Protocol     = $presentParameters.Protocol
                                Port         = $presentParameters.Port
                                Zone      = $presentParameters.Zone
                                Target    = $presentParameters.Target
                                DnsServer = $presentParameters.DnsServer
                                Priority  = $presentParameters.Priority
                                Weight    = $presentParameters.Weight
                                TTL       = $presentParameters.TTL
                                Ensure    = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @undefinedOptionalParameters | Should Be $true
                    }

                    It "Should fail when a record exists and Ensure is Absent" {
                        Mock -CommandName Get-TargetResource -MockWith { return $presentParameters }
                        Test-TargetResource @absentParameters | Should Be $false
                    }

                    It "Should pass when record exists, target, priority, weight, and TTL match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith { return $presentParameters }
                        Test-TargetResource @presentParameters | Should Be $true
                    }

                    It "Should pass when record does not exist and Ensure is Absent" {
                        Mock -CommandName Get-TargetResource -MockWith { return $absentParameters }
                        Test-TargetResource @absentParameters | Should Be $true
                    }
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe 'MSFT_xDnsRecordSrv\Set-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                $presentParameters = $dnsRecord.TestParameters
                $mockRecord = $dnsRecord.MockRecord.Clone()
                $mockRecord.RecordData.Priority = 50
                $absentParameters = $presentParameters.Clone()
                $absentParameters['Ensure'] = 'Absent'

                Context "When managing SRV type DNS record" {
                    It "Calls Add-DnsServerResourceRecord in the set method when Ensure is Present and the record does not exist" {
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $null }
                        Mock -CommandName Add-DnsServerResourceRecord
                        Set-TargetResource @presentParameters
                        Assert-MockCalled Add-DnsServerResourceRecord -Scope It
                    }

                    It "Calls Set-DnsServerResourceRecord in the set method when Ensure is Present and the record exists" {
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $dnsRecord.MockRecord }
                        Mock -CommandName Set-DnsServerResourceRecord
                        Set-TargetResource @presentParameters
                        Assert-MockCalled Set-DnsServerResourceRecord -Scope It
                    }

                    It "Does not call Remove-DnsServerResourceRecord in the set method when Ensure is Absent and the record does not exist" {
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $null }
                        Mock -CommandName Remove-DnsServerResourceRecord
                        Set-TargetResource @absentParameters
                        Assert-MockCalled Remove-DnsServerResourceRecord -Scope It -Exactly -Times 0
                    }

                    It "Calls Remove-DnsServerResourceRecord in the set method when Ensure is Absent and the record exists" {
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $dnsRecord.MockRecord }
                        Mock -CommandName Remove-DnsServerResourceRecord
                        Set-TargetResource @absentParameters
                        Assert-MockCalled Remove-DnsServerResourceRecord -Scope It -Exactly -Times 1
                    }
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
