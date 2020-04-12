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
        $recordAData = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecordA -ClientOnly -Property @{
            IPv4Address = '192.168.0.1'
        }
        $recordPtrData = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecordPTR -ClientOnly -Property @{
            PtrDomainName = '192.168.0.1'
        }
        $recordCNameData = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecordCName -ClientOnly -Property @{
            HostNameAlias = 'test.contoso.com'
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
                    Verbose    = $true
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
                    Name       = 'test'
                    Zone       = 'contoso.com'
                    Target     = '192.168.0.1'
                    Type       = 'ARecord'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                    Verbose    = $true
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
                    Verbose    = $true
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
                    Name       = '123'
                    Target     = 'TestA.contoso.com'
                    Zone       = '0.168.192.in-addr.arpa'
                    Type       = 'PTR'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                    Verbose    = $true
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
                    Verbose    = $true
                }
                MockRecord     = New-CimInstance -Namespace root/Microsoft/Windows/DNS -ClassName DnsServerResourceRecord -ClientOnly -Property @{
                    HostName   = 'test'
                    RecordType = 'Cname'
                    DnsServer  = 'localhost'
                    TimeToLive = '01:00:00'
                    RecordData = $recordCNameData
                }
            }
            @{
                TestParameters = @{
                    Name       = 'test'
                    Zone       = 'contoso.com'
                    Target     = 'test2'
                    Type       = 'Cname'
                    DnsServer  = 'localhost'
                    Ensure     = 'Present'
                    Verbose    = $true
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

        #region Function Get-TargetResource
        Describe 'MSFT_xDnsRecord\Get-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                Context "When managing $($dnsRecord.TestParameters.Type) type DNS record" {
                    $presentParameters = $dnsRecord.TestParameters

                    It 'Should return Ensure is Present when DNS record exists' {
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $dnsRecord.MockRecord }
                        (Get-TargetResource @presentParameters).Ensure | Should Be 'Present'
                    }

                    It 'Should returns Ensure is Absent when DNS record does not exist' {
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
                if ($dnsRecord.TestParameters.TimeToLive)
                {
                    $ttlDefined = 'with a TTL defined'
                }
                else {
                    $ttlDefined = 'with no TTL defined'
                }

                Context "When managing $($dnsRecord.TestParameters.Type) type DNS record $ttlDefined" {
                    $presentParameters = $dnsRecord.TestParameters
                    $absentParameters = $presentParameters.Clone()
                    $absentParameters['Ensure'] = 'Absent'

                    It 'Should fail when no DNS record exists and Ensure is Present' {
                        Mock -CommandName Get-TargetResource -MockWith { return $absentParameters }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It 'Should fail when a record exists, target does not match and Ensure is Present' {
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

                    It 'Should fail when round-robin record exists, target does not match and Ensure is Present (Issue #23)' {
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

                    It 'Should fail when a record exists and Ensure is Absent' {
                        Mock -CommandName Get-TargetResource -MockWith { return $presentParameters }
                        Test-TargetResource @absentParameters | Should Be $false
                    }

                    It 'Should fail when round-robin record exists, and Ensure is Absent (Issue #23)' {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name      = $presentParameters.Name
                                Zone      = $presentParameters.Zone
                                Target    = @('192.168.0.1', '192.168.0.2')
                                DnsServer = $presentParameters.DnsServer
                                Ensure    = $presentParameters.Ensure
                            }
                        }
                        Test-TargetResource @absentParameters | Should Be $false
                    }

                    if ($PresentParameters.TimeToLive)
                    {
                        It 'Should fail when the TTL does not match the record that exists' {
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
                    }

                    It 'Should pass when record exists, target matches and Ensure is Present' {
                        Mock -CommandName Get-TargetResource -MockWith { return $presentParameters }
                        Test-TargetResource @presentParameters | Should Be $true
                    }

                    It 'Should pass when round-robin record exists, target matches and Ensure is Present (Issue #23)' {
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

                    It 'Should pass when record does not exist and Ensure is Absent' {
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
                    It 'Calls Add-DnsServerResourceRecord in the set method when Ensure is Present' {
                        Mock -CommandName Add-DnsServerResourceRecord
                        Set-TargetResource @presentParameters
                        Assert-MockCalled Add-DnsServerResourceRecord -Scope It
                    }

                    It 'Calls Remove-DnsServerResourceRecord in the set method when Ensure is Absent' {
                        Mock -CommandName Remove-DnsServerResourceRecord
                        Set-TargetResource @absentParameters
                        Assert-MockCalled Remove-DnsServerResourceRecord -Scope It
                    }

                    It 'Should Call Set-DnsServerResourceRecord when the TTL does not match' {
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
    Invoke-TestCleanup
}
