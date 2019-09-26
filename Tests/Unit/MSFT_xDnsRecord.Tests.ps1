$script:DSCModuleName = 'xDnsServer'
$script:DSCResourceName = 'MSFT_xDnsRecord'

#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $script:DSCResourceName {
        #region Pester Test Initialization
        $recordAData = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecordCnNme -ClientOnly -Property @{
            IPv4Address = 'test.contoso.com'
        }
        $recordPtrData = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecordPTR -ClientOnly -Property @{
            PtrDomainName = '192.168.0.1'
        }
        $recordCNameData = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecordA -ClientOnly -Property @{
            HostNameAlias = '192.168.0.1'
        }

        $dnsRecordsToTest = @(
            @{
                TestParameters = @{
                    Name       = 'test'
                    Zone       = 'contoso.com'
                    Target     = '192.168.0.1'
                    Type       = 'ARecord'
                    TimeToLive = '01:00:00'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                }
                MockRecord     = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecord -ClientOnly -Property @{
                    HostName   = 'test'
                    RecordType = 'A'
                    DnsServer  = 'localhost'
                    TimeToLive = '01:00:00'
                    RecordData = $recordAData
                }
            }
            @{
                TestParameters = @{
                    Name       = '123'
                    Target     = 'TestA.contoso.com'
                    Zone       = '0.168.192.in-addr.arpa'
                    Type       = 'PTR'
                    TimeToLive = '01:00:00'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                }
                MockRecord     = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecord -ClientOnly -Property @{
                    HostName   = 'test'
                    RecordType = 'PTR'
                    DnsServer  = 'localhost'
                    TimeToLive = '01:00:00'
                    RecordData = $recordPtrData
                }
            }
            @{
                TestParameters = @{
                    Name       = 'test'
                    Zone       = 'contoso.com'
                    Target     = 'test2'
                    Type       = 'Cname'
                    TimeToLive = '01:00:00'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                }
                MockRecord     = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecord -ClientOnly -Property @{
                    HostName   = 'test'
                    RecordType = 'Cname'
                    DnsServer  = 'localhost'
                    TimeToLive = '01:00:00'
                    RecordData = $recordCNameData
                }
            }
        )
        #endregion

        #Import Stub for DNS Commands
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force

        #region Function Get-TargetResource
        Describe "MSFT_xDnsRecord\Get-TargetResource" {
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
        Describe "MSFT_xDnsRecord\Test-TargetResource" {
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

                    It "Should fail when the TTL does not match the record that exists" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name       = $presentParameters.Name
                                Zone       = $presentParameters.Zone
                                Target     = $presentParameters.Target
                                TimeToLive = '02:00:00'
                                DnsServer  = $presentParameters.DnsServer
                                Ensure     = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @PresentParameters | Should Be $false
                    }

                    It "Should pass when record exists, target matches and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith { return $presentParameters }
                        Test-TargetResource @presentParameters | Should Be $true
                    }

                    It "Should pass when round-robin record exists, target matches and Ensure is Present (Issue #23)" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name       = $presentParameters.Name
                                Zone       = $presentParameters.Zone
                                Target     = @($presentParameters.Target, "192.168.0.2")
                                TimeToLive = $presentParameters.TimeToLive
                                DnsServer  = $presentParameters.DnsServer
                                Ensure     = $presentParameters.Ensure
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
        Describe "MSFT_xDnsRecord\Set-TargetResource" {
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

                    It "Should Call Set-DnsServerResourceRecord when the TTL does not match" {
                        Mock -CommandName Set-DnsServerResourceRecord
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $dnsRecord.MockRecord }
                        Set-TargetResource @presentParameters
                        Assert-MockCalled Get-DnsServerResourceRecord -Scope It
                        Assert-MockCalled Set-DnsServerResourceRecord -Scope It
                    }
                }
            }
        }
        #endregion
    } #end InModuleScope
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
