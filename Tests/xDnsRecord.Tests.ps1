[CmdletBinding()]
param()

if (!$PSScriptRoot) # $PSScriptRoot is not defined in 2.0
{
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}

$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

$RepoRoot = (Resolve-Path $PSScriptRoot\..).Path

$ModuleName = "MSFT_xDnsRecord"
Import-Module (Join-Path $RepoRoot "DSCResources\$ModuleName\$ModuleName.psm1")
Import-Module DnsServer

Describe "xDnsRecord Type A-record" {
    InModuleScope $ModuleName {
        $testParams = @{
            Name = "test"
            Zone = "contoso.com"
            Target = "192.168.0.1"
            Type = "A-record"
        }

        Context "Validate test method" {
            It "Fails when no DNS record exists" {
                Mock Get-TargetResource { return @{} }
                Test-TargetResource @testParams | Should Be $false
            }
            It "Passes when record exists and target matches" {
                Mock Get-TargetResource { 
                    return @{
                        Name = $testParams.Name
                        Zone = $testParams.Zone
                        Target = $testParams.Target
                        Type = $testParams.Type
                    }
                } 
                Test-TargetResource @testParams | Should Be $true
            }
            It "Fails when the record exists and target does not match" {
                Mock Get-TargetResource { 
                    return @{
                        Name = $testParams.Name
                        Zone = $testParams.Zone
                        Target = "192.168.0.10"
                        Type = $testParams.Type
                    }
                }
                Test-TargetResource @testParams | Should Be $false
            }
        }
        Context "Validate set method" {
            It "Calls Add-DnsServerResourceRecordA in the set method" {
                Mock Add-DnsServerResourceRecordA { return $null } -Verifiable
                Set-TargetResource @testParams 
                Assert-VerifiableMocks
            }
        }
    }
}

Describe "xDnsRecord Type C-name" {
    InModuleScope $ModuleName {
        $testParams = @{
            Name = "test"
            Zone = "contoso.com"
            Target = "test.contoso.com"
            Type = "C-name"
        }

        Context "Validate test method" {
            It "Fails when no DNS record exists" {
                Mock Get-TargetResource { return @{} }
                Test-TargetResource @testParams | Should Be $false
            }
            It "Passes when record exists and target matches" {
                Mock Get-TargetResource { 
                    return @{
                        Name = $testParams.Name
                        Zone = $testParams.Zone
                        Target = $testParams.Target
                        Type = $testParams.Type
                    }
                } 
                Test-TargetResource @testParams | Should Be $true
            }
            It "Fails when the record exists and target does not match" {
                Mock Get-TargetResource { 
                    return @{
                        Name = $testParams.Name
                        Zone = $testParams.Zone
                        Target = "test2.contoso.com"
                        Type = $testParams.Type
                    }
                }
                Test-TargetResource @testParams | Should Be $false
            }
        }
        Context "Validate set method" {
            It "Calls Add-DnsServerResourceRecordCName in the set method" {
                Mock Add-DnsServerResourceRecordCName { return $null } -Verifiable
                Set-TargetResource @testParams 
                Assert-VerifiableMocks
            }
        }
    }
}
