[CmdletBinding()]
param()

if (!$PSScriptRoot) # $PSScriptRoot is not defined in 2.0
{
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}

$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

$RepoRoot = (Resolve-Path $PSScriptRoot\..).Path

$ModuleName = "MSFT_xDnsARecord"
Import-Module (Join-Path $RepoRoot "DSCResources\$ModuleName\$ModuleName.psm1")
Import-Module DnsServer

Describe "xDnsARecord" {
    InModuleScope $ModuleName {
        $testPresentParams = @{
            Name = "test"
            Zone = "contoso.com"
            Target = "192.168.0.1"
            Ensure = "Present"
        }
        $testAbsentParams = @{
            Name = $testPresentParams.Name
            Zone = $testPresentParams.Zone
            Target = $testPresentParams.Target
            Ensure = "Absent"
        }
        $fakeDnsServerResourceRecord = @{
            HostName = $testPresentParams.Name;
            RecordType = 'A'
            TimeToLive = '01:00:00'
            RecordData = @{
                IPv4Address = @{
                    IPAddressToString = $testPresentParams.Target
                }
            }
        }

        Context "Validate get method" {
            It "Returns Ensure is Present when DNS record exists" {
                Mock Get-DnsServerResourceRecord { return $fakeDnsServerResourceRecord }
                (Get-TargetResource @testPresentParams).Ensure | Should Be 'Present'
            }
            It "Returns Ensure is Absent when DNS record does not exist" {
                Mock Get-DnsServerResourceRecord { return $null }
                (Get-TargetResource @testPresentParams).Ensure | Should Be 'Absent'
            } 
        }
        Context "Validate test method" {
            It "Fails when no DNS record exists and Ensure is Present" {
                Mock Get-TargetResource { return $testAbsentParams }
                Test-TargetResource @testPresentParams | Should Be $false
            }
            It "Fails when a record exists, target does not match and Ensure is Present" {
                Mock Get-TargetResource { 
                    return @{
                        Name = $testPresentParams.Name
                        Zone = $testPresentParams.Zone
                        Target = "192.168.0.10"
                        Ensure = $testPresentParams.Ensure
                    }
                }
                Test-TargetResource @testPresentParams | Should Be $false
            }
            It "Fails when a record exists and Ensure is Absent" {
                Mock Get-TargetResource { return $testPresentParams }
                Test-TargetResource @testAbsentParams | Should Be $false
            }
            It "Passes when record exists, target matches and Ensure is Present" {
                Mock Get-TargetResource {  return $testPresentParams } 
                Test-TargetResource @testPresentParams | Should Be $true
            }
            It "Passes when record does not exist and Ensure is Absent" {
                Mock Get-TargetResource { return $testAbsentParams } 
                Test-TargetResource @testAbsentParams | Should Be $true
            }
        }
        Context "Validate set method" {
            It "Calls Add-DnsServerResourceRecordA in the set method when Ensure is Present" {
                Mock Add-DnsServerResourceRecordA { return $null }
                Set-TargetResource @testPresentParams 
                Assert-MockCalled Add-DnsServerResourceRecordA -Scope It
            }
            It "Calls Remove-DnsServerResourceRecord in the set method when Ensure is Absent" {
                Mock Remove-DnsServerResourceRecord { return $null }
                Set-TargetResource @testAbsentParams 
                Assert-MockCalled Remove-DnsServerResourceRecord -Scope It
            }
        }
    }
}
