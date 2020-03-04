$script:dscModuleName = 'xDnsServer'
$script:dscResourceName = 'MSFT_xDnsRecord'

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
                    Name      = 'test'
                    Zone      = 'contoso.com'
                    Target    = '192.168.0.1'
                    Type      = 'ARecord'
                    DnsServer = 'localhost'
                    Ensure    = 'Present'
                }
                MockRecord     = @{
                    HostName   = 'test'
                    RecordType = 'A'
                    DnsServer  = 'localhost'
                    TimeToLive = '01:00:00'
                    RecordData = @{
                        IPv4Address = @{
                            IPAddressToString = '192.168.0.1'
                        }
                    }
                }
            }
            @{
                TestParameters = @{
                    Name      = '123'
                    Target    = 'TestA.contoso.com'
                    Zone      = '0.168.192.in-addr.arpa'
                    Type      = 'PTR'
                    DnsServer = 'localhost'
                    Ensure    = 'Present'
                }
                MockRecord     = @{
                    HostName   = 'test'
                    RecordType = 'PTR'
                    DnsServer  = 'localhost'
                    TimeToLive = '01:00:00'
                    RecordData = @{
                        PtrDomainName = '192.168.0.1'
                    }
                }
            }
        )
        #endregion

        #region Function Get-TargetResource
        Describe 'MSFT_xDnsRecord\Get-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                Context "When managing $($dnsRecord.TestParameters.Type) type DNS record" {
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
        Describe 'MSFT_xDnsRecord\Test-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                Context "When managing $($dnsRecord.TestParameters.Type) type DNS record" {
                    $presentParameters = $dnsRecord.TestParameters
                    $absentParameters = $presentParameters.Clone()
                    $absentParameters['Ensure'] = 'Absent'

                    It "Should fail when no DNS record exists and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith { return $absentParameters }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, target does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name      = $presentParameters.Name
                                Zone      = $presentParameters.Zone
                                Target    = "192.168.0.10"
                                DnsServer = $presentParameters.DnsServer
                                Ensure    = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when round-robin record exists, target does not match and Ensure is Present (Issue #23)" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name      = $presentParameters.Name
                                Zone      = $presentParameters.Zone
                                Target    = @("192.168.0.10", "192.168.0.11")
                                DnsServer = $presentParameters.DnsServer
                                Ensure    = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists and Ensure is Absent" {
                        Mock -CommandName Get-TargetResource -MockWith { return $presentParameters }
                        Test-TargetResource @absentParameters | Should Be $false
                    }

                    It "Should fail when round-robin record exists, and Ensure is Absent (Issue #23)" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name      = $presentParameters.Name
                                Zone      = $presentParameters.Zone
                                Target    = @("192.168.0.1", "192.168.0.2")
                                DnsServer = $presentParameters.DnsServer
                                Ensure    = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @absentParameters | Should Be $false
                    }

                    It "Should pass when record exists, target matches and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith { return $presentParameters }
                        Test-TargetResource @presentParameters | Should Be $true
                    }

                    It "Should pass when round-robin record exists, target matches and Ensure is Present (Issue #23)" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name      = $presentParameters.Name
                                Zone      = $presentParameters.Zone
                                Target    = @($presentParameters.Target, "192.168.0.2")
                                DnsServer = $presentParameters.DnsServer
                                Ensure    = $presentParameters.Ensure
                            }
                        }
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
        Describe 'MSFT_xDnsRecord\Set-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                $presentParameters = $dnsRecord.TestParameters
                $absentParameters = $presentParameters.Clone()
                $absentParameters['Ensure'] = 'Absent'

                Context "When managing $($dnsRecord.TestParameters.Type) type DNS record" {
                    It "Calls Add-DnsServerResourceRecord in the set method when Ensure is Present" {
                        Mock -CommandName Add-DnsServerResourceRecord
                        Set-TargetResource @presentParameters
                        Assert-MockCalled Add-DnsServerResourceRecord -Scope It
                    }

                    It "Calls Remove-DnsServerResourceRecord in the set method when Ensure is Absent" {
                        Mock -CommandName Remove-DnsServerResourceRecord
                        Set-TargetResource @absentParameters
                        Assert-MockCalled Remove-DnsServerResourceRecord -Scope It
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
