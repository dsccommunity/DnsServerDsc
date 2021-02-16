$script:dscModuleName = 'xDnsServer'
$script:dscResourceName = 'MSFT_xDnsRecordMx'

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
                RequiredParameters = @{
                    Name      = "@"
                    Zone      = 'contoso.com'
                    Target    = 'mail.contoso.com'
                    Priority  = 10
                    Verbose   = $true
                }
                FullParameters = @{
                    Name      = "@"
                    Zone      = 'contoso.com'
                    Target    = 'mail.contoso.com'
                    Priority  = 10
                    TTL       = '02:00:00'
                    DnsServer = 'localhost'
                    Ensure    = 'Present'
                    Verbose   = $true
                }
                MockRecord    = Import-Clixml -Path "$($PSScriptRoot)\MockObjects\MxRecordInstance.xml"
            }
        )
        #endregion

        #region Function Get-TargetResource
        Describe 'MSFT_xDnsRecordMx\Get-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                Context "When managing MX type DNS record" {
                    $presentParameters = $dnsRecord.RequiredParameters

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
        Describe 'MSFT_xDnsRecordMx\Test-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                Context "When managing MX type DNS record" {
                    $presentParameters = $dnsRecord.RequiredParameters
                    $absentParameters = $presentParameters.Clone()
                    $absentParameters['Ensure'] = 'Absent'
                    $fullParameters = $dnsRecord.FullParameters

                    It "Should fail when no DNS record exists and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith { return $absentParameters }
                        Test-TargetResource @presentParameters | Should Be $false
                    }

                    It "Should fail when a record exists, TTL does not match and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name      = $presentParameters.Name
                                Zone      = $presentParameters.Zone
                                Target    = $presentParameters.Target
                                DnsServer = $presentParameters.DnsServer
                                Priority  = $presentParameters.Priority
                                TTL       = "00:05:00"
                                Ensure    = $fullParameters.Ensure
                            }
                        }
                        Test-TargetResource @fullParameters | Should Be $false
                    }

                    It "Should pass when a record exists, TTL is not defined, and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Name      = $presentParameters.Name
                                Zone      = $presentParameters.Zone
                                Target    = $presentParameters.Target
                                DnsServer = $presentParameters.DnsServer
                                Priority  = $presentParameters.Priority
                                TTL       = $fullParameters.TTL
                                Ensure    = $fullParameters.Ensure
                            }
                        }
                        Test-TargetResource @presentParameters | Should Be $true
                    }

                    It "Should fail when a record exists and Ensure is Absent" {
                        Mock -CommandName Get-TargetResource -MockWith { return $fullParameters }
                        Test-TargetResource @absentParameters | Should Be $false
                    }

                    It "Should pass when record exists, TTL matches, and Ensure is Present" {
                        Mock -CommandName Get-TargetResource -MockWith { return $fullParameters }
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
        Describe 'MSFT_xDnsRecordMx\Set-TargetResource' {
            foreach ($dnsRecord in $dnsRecordsToTest)
            {
                $presentParameters = $dnsRecord.RequiredParameters
                $mockRecord = $dnsRecord.MockRecord.Clone()
                $mockRecord.RecordData.Preference = 50
                $absentParameters = $presentParameters.Clone()
                $absentParameters['Ensure'] = 'Absent'

                Context "When managing MX type DNS record" {
                    It "Calls Add-DnsServerResourceRecord in the set method when Ensure is Present" {
                        Mock -CommandName Add-DnsServerResourceRecord
                        Set-TargetResource @presentParameters
                        Assert-MockCalled Add-DnsServerResourceRecord -Scope It
                    }

                    It 'Calls Set-DnsServerResourceRecord in the set method when Ensure is Present and the record exists' {
                        Mock -CommandName Get-DnsServerResourceRecord -MockWith { return $dnsRecord.MockRecord }
                        Mock -CommandName Set-DnsServerResourceRecord
                        Set-TargetResource @presentParameters
                        Assert-MockCalled Set-DnsServerResourceRecord -Scope It
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
