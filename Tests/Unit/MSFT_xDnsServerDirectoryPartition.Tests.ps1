<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename <ResourceName>.tests.ps1 (e.g. MSFT_xFirewall.tests.ps1)
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>


# TODO: Customize these parameters...
$script:DSCModuleName      = 'xDnsServer' # Example xNetworking
$script:DSCResourceName    = 'MSFT_xDnsServerDirectoryPartition' # Example MSFT_xFirewall
# /TODO

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit 
#endregion HEADER

# TODO: Other Optional Init Code Goes Here...

# Begin Testing
try
{
    #region Pester Test Initialization

    #endregion Pester Test Initialization

    #region Example state 1
    Describe "The system is not in the desired state" {
        $mockResults = @{
            DirectoryPartitionName = "contoso.com"            
        }

        Mock Get-DnsServerDirectoryPartition -MockWith {} -ParameterFilter {$Name -eq 'noDirectory.com'}
        Mock Get-DnsServerDirectoryPartition -MockWith {$mockResults} -ParameterFilter {$Name -eq 'contoso.com'}
        Mock Add-DnsServerDirectoryPartition -MockWith {}
        Mock Remove-DnsServerDirectoryPartition -MockWith {}
        #TODO: Create a set of parameters to test your get/test/set methods in this state
        $testParameters = @{
            Name   = 'contoso.com'
            Ensure = 'Present'
        }      
     
        #TODO: Update the assertions below to align with the expected results of this state
        It "Get method returns 'Ensure -eq Absent' when partition is Absent" {
            $getResult = Get-TargetResource -Name 'noDirectory.com' -Ensure Absent

            $getResult.Ensure | Should be 'Absent'
        }

        It "Get method returns 'Ensure is Present' when partition is Present" {
            $getResult = Get-TargetResource -Name 'contoso.com' -Ensure Present

            $getResult.Ensure | Should be 'Present'
        }

        It "Test method returns false when directory is present and Ensure is Absent" {
            Test-TargetResource -Name 'contoso.com' -Ensure Absent | Should be $false
        }

        It "Test method returns false when directory is Absent and Ensure is Present" {
            Test-TargetResource -Name 'noDirectory.com' -Ensure Present | Should be $false
        }

        It "Set method calls Add-DnsServerDirectoryPartition when Ensure is Present" {
            Set-TargetResource -Name 'contoso.com' -Ensure Present

            Assert-MockCalled Add-DnsServerDirectoryPartition
        }

        It 'Set method calls Remove-DnsServerDirectoryPartition when Ensure is Absent' {
            Set-TargetResource -Name 'contoso.com' -Ensure Absent

            Assert-MockCalled Remove-DnsServerDirectoryPartition
        }
    }
    #endregion Example state 1

    #region Example state 2
    Describe "The system is in the desired state" {
        $mockResults = @{
            DirectoryPartitionName = "contoso.com"            
        }
        
        Mock Get-DnsServerDirectoryPartition -MockWith {} -ParameterFilter {$Name -eq 'noDirectory.com'}
        Mock Get-DnsServerDirectoryPartition -MockWith {$mockResults} -ParameterFilter {$Name -eq 'contoso.com'}

        It "Test method returns true" {
            Test-TargetResource -Name 'contoso.com' -Ensure Present | Should be $true
        }

        It "Test method returns true" {
            Test-TargetResource -Name 'noDirectory.com' -Ensure Absent | Should be $true
        }
    }
    #endregion Example state 2

}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
