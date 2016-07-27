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
$script:DSCModuleName      = 'xDnsServer'
$script:DSCResourceName    = 'MSFT_xDnsServerZoneAging'
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

    # TODO: Optionally create any variables here for use by your tests
    # See https://github.com/PowerShell/xNetworking/blob/dev/Tests/Unit/MSFT_xDhcpClient.Tests.ps1
    # Mocks that should be applied to all cmdlets being tested may
    # also be created here if required.

    #endregion Pester Test Initialization

    #region Example state 1
    Describe "The system is not in the desired state" {
        #TODO: Mock cmdlets here that represent the system not being in the desired state
                
        $testParameters = @{
            ZoneName          = 'contoso.com'
            AgingEnabled      = $true
            RefreshInterval   = '4.00:00:00'
            NoRefreshInterval = '7.00:00:00'
            ScavengeServers   = '10.0.0.1','10.0.0.2'
        }

        $mockResults = @{
            ZoneName          = 'contoso.com'
            AgingEnabled      = $false
            RefreshInterval   = '4.00:00:10'
            NoRefreshInterval = '4.00:00:10'
            ScavengeServers   = '10.1.0.1','10.1.0.2'
        }

        Mock Get-DnsServerZoneAging {$mockResults}
        Mock Set-DnsServerZoneAging {}
        
        It "Get method returns 'something'" {

            $getResult = Get-TargetResource $testParameters.ZoneName

            foreach ($key in $getResult.Keys)
            {
                if ($key -ne 'ZoneName')
                {
                    $getResult[$key] | Should be $mockResults[$key]
                }
            }
        }

        It "Test method returns false" {

            $falseParameters = @{ZoneName = 'contoso.com'}
            foreach ($key in $testParameters.Keys)
            {
                if ($key -ne 'ZoneName')
                {
                    $falseTestParameters = $falseParameters.Clone()
                    $falseTestParameters.Add($key,$testParameters[$key])
                    Test-TargetResource @falseTestParameters | Should be $false
                }
            }
        }

        It "Set method calls Set-DnsServerZoneAging" {
            Set-TargetResource @testParameters

            #TODO: Assert that the appropriate cmdlets were called
            Assert-MockCalled Set-DnsServerZoneAging -Exactly 1 
        }
    }
    #endregion Example state 1

    #region Example state 2
    Describe "The system is in the desired state" {

        $testParameters = @{
            ZoneName          = 'contoso.com'
            AgingEnabled      = $true
            RefreshInterval   = '4.00:00:00'
            NoRefreshInterval = '7.00:00:00'
            ScavengeServers   = '10.0.0.1','10.0.0.2'
        }

        $trueParameters = @{ZoneName = 'contoso.com'}

        mock Get-DnsServerZoneAging {$testParameters}

        It "Test method returns true" {
            foreach ($key in $testParameters.Keys)
            {
                if ($key -ne 'ZoneName')
                {
                    $trueTestParameters = $trueParameters.Clone()
                    $trueTestParameters.Add($key,$testParameters[$key])
                    Test-TargetResource @trueTestParameters | Should be $true
                }
            }
        }
    }
    #endregion Example state 2

    #region Non-Exported Function Unit Tests

    # TODO: Pester Tests for any non-exported Helper Cmdlets
    # If the resource does not contain any non-exported helper cmdlets then
    # this block may be safetly deleted.
    InModuleScope $script:DSCResourceName {
        
        $array1 = 1,2,3
        $array2 = 3,2,1
        $array3 = 1,2,3,4

        Describe 'Private functions' {

            Context 'Compare-Array' {
            
                It 'Should return true when arrays are same' {
                    Compare-Array $array1 $array2 | should be $true
                }

                It 'Should return true when both arrays are NULL' {
                    Compare-Array $null $null | should be $true
                }

                It 'Should return false when arrays are different' {
                    Compare-Array $array1 $array3 | should be $false
                }

                It 'Should return false when only one input is NULL' {
                    Compare-Array $array1 $null | should be $false
                }
            }
        }
    }
    #endregion Non-Exported Function Unit Tests
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
