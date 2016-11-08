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
$script:DSCResourceName    = 'MSFT_xDnsServerSetting' # Example MSFT_xFirewall
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

# Begin Testing
try
{
    InModuleScope $script:DSCResourceName {
    #region Pester Test Initialization
        $testParameters = @{
            Name                      = 'Dc1DnsServerSetting'
            AddressAnswerLimit        = 5
            AllowUpdate               = 2
            AutoCacheUpdate           = $true
            AutoConfigFileZones       = 4
            BindSecondaries           = $true
            BootMethod                = 1
            DefaultAgingState         = $true
            DefaultNoRefreshInterval  = 10
            DefaultRefreshInterval    = 10
            DisableAutoReverseZones   = $true
            DisjointNets              = $true
            DsAvailable               = $false
            DsPollingInterval         = 10
            DsTombstoneInterval       = 10
            EDnsCacheTimeout          = 100
            EnableDirectoryPartitions = $false
            EnableDnsSec              = 0
            EnableEDnsProbes          = $false
            EventLogLevel             = 3
            ForwardDelegations        = 1
            Forwarders                = '8.8.8.8'
            ForwardingTimeout         = 4
            IsSlave                   = $true
            ListenAddresses           = '192.168.0.10','192.168.0.11'
            LocalNetPriority          = $false
            LogFileMaxSize            = 400000000
            LogFilePath               = 'C:\Windows\System32\DNS_log\DNS.log'
            LogIPFilterList           = '192.168.0.10','192.168.0.11'
            LogLevel                  = 256
            LooseWildcarding          = $true
            MaxCacheTTL               = 86200
            MaxNegativeCacheTTL       = 901
            NameCheckFlag             = 1
            NoRecursion               = $false
            RecursionRetry            = $false
            RecursionTimeout          = 16
            RoundRobin                = $false
            RpcProtocol               = 1
            ScavengingInterval        = 100
            SecureResponses           = $false
            SendPort                  = 100
            StrictFileParsing         = $true
            UpdateOptions             = 700
            WriteAuthorityNS          = $true
            XfrConnectTimeout         = 15
        }

        $mockGetCimInstance = @{
            Caption                   = $null
            Description               = $null 
            InstallDate               = $null
            Name                      = $null
            Status                    = 'OK'
            CreationClassName         = $null
            Started                   = $true
            StartMode                 = 'Automatic'
            SystemCreationClassName   = $null
            SystemName                = $null 
            AddressAnswerLimit        = 0
            AllowUpdate               = 1
            AutoCacheUpdate           = $false
            AutoConfigFileZones       = 1
            BindSecondaries           = $false
            BootMethod                = 3
            DefaultAgingState         = $false
            DefaultNoRefreshInterval  = 168
            DefaultRefreshInterval    = 168
            DisableAutoReverseZones   = $false
            DisjointNets              = $false
            DsAvailable               = $true
            DsPollingInterval         = 180
            DsTombstoneInterval       = 1209600
            EDnsCacheTimeout          = 900
            EnableDirectoryPartitions = $true
            EnableDnsSec              = 1
            EnableEDnsProbes          = $true
            EventLogLevel             = 4
            ForwardDelegations        = 0
            Forwarders                = {168.63.129.16}
            ForwardingTimeout         = 3
            IsSlave                   = $false
            ListenAddresses           = $null
            LocalNetPriority          = $true
            LogFileMaxSize            =  500000000
            LogFilePath               = 'C:\Windows\System32\DNS\DNS.log'
            LogIPFilterList           = '10.1.1.1','10.0.0.1'
            LogLevel                  = 0
            LooseWildcarding          = $false
            MaxCacheTTL               = 86400
            MaxNegativeCacheTTL       = 900
            NameCheckFlag             = 2
            NoRecursion               = $true
            RecursionRetry            = 3
            RecursionTimeout          = 8
            RoundRobin                = $true
            RpcProtocol               = 5
            ScavengingInterval        = 168
            SecureResponses           = $true
            SendPort                  = 0
            ServerAddresses           = 'fe80::7da3:a014:6581:2cdc','10.0.0.4'
            StrictFileParsing         =  $false
            UpdateOptions             = 783
            Version                   = 629146374
            WriteAuthorityNS          = $false
            XfrConnectTimeout         = 30
            PSComputerName            = $null
        }

        $array1 = 1,2,3
        $array2 = 3,2,1
        $array3 = 1,2,3,4
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
            Name                = 'DnsServerSetting'
        }
    #endregion Pester Test Initialization

    #region Example state 1
    Describe "The system is not in the desired state" {

        Context 'Get-TargetResource' {
            It "Get method returns 'something'" {
                Mock Get-CimInstance -MockWith  {$mockGetCimInstance}
                $getResult = Get-TargetResource -Name 'DnsServerSetting'

                foreach ($key in $getResult.Keys)
                {
                    if ($null -ne $getResult[$key] -and $key -ne 'Name')
                    {
                        $getResult[$key] | Should be $mockGetCimInstance[$key]
                    }
                }
            }

            It 'Get throws when CimClass is not found' {
               $mockThrow = @{Exception = @{Message = 'Invalid Namespace'}}
               Mock Get-CimInstance -MockWith {throw $mockThrow}

               {Get-TargetResource -Name 'DnsServerSettings'} | should throw
            }
        }

        Context 'Test-TargetResource' {
            Mock Get-CimInstance -MockWith {$mockGetCimInstance}
            It "Test method returns false" {
                $falseParameters = @{Name = 'DnsServerSetting'}

                foreach ($key in $testParameters.Keys)
                {
                    if ($key -ne 'Name')
                    {
                        $falseTestParameters = $falseParameters.Clone()
                        $falseTestParameters.Add($key,$testParameters[$key])
                        Test-TargetResource @falseTestParameters | Should be $false
                    }
                }
            }

            It "Test throws when CimClass is not found" {
               $mockThrow = @{Exception = @{Message = 'Invalid Namespace'}}
               Mock Get-CimInstance -MockWith {throw $mockThrow}

               {Get-TargetResource -Name 'DnsServerSettings'} | should throw
            }
        }

        Context 'Set-TargetResource' {
            It "Set method calls Set-CimInstance" {
                $mockCimClass = Import-Clixml -Path $PSScriptRoot\..\..\Misc\MockObjects\DnsServerClass.xml
                Mock Get-CimInstance -MockWith {$mockCimClass}
                Mock Set-CimInstance {}
            
                Set-TargetResource @testParameters

                Assert-MockCalled Set-CimInstance -Exactly 1
            }
        }
    }
    #endregion Example state 1

    #region Example state 2
    Describe "The system is in the desired state" {

        Context 'Test-TargetResource' {
            Mock Get-CimInstance -MockWith {$mockGetCimInstance}
            It "Test method returns true" {
                $trueParameters = @{Name = 'DnsServerSetting'}

                foreach ($key in $testParameters.Keys)
                {
                    if ($key -ne 'Name')
                    {
                        $trueTestParameters = $trueParameters.Clone()
                        $trueTestParameters.Add($key,$mockGetCimInstance[$key])
                        Test-TargetResource @trueTestParameters | Should be $true
                    }
                }
            }
        }
    }
    #endregion Example state 2

    #region Non-Exported Function Unit Tests

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

        Context 'Remove-CommonParameters' {
            It 'Should not contain any common parameters' {
                $removeResults = Remove-CommonParameter $mockParameters

                foreach ($key in $removeResults.Keys)
                {
                    $commonParameters -notcontains $key | should be $true
                }
            }
        }
    }
    #endregion Non-Exported Function Unit Tests
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
