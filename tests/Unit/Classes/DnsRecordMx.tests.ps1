<#
    This pester file is an example of how organize a pester test.
    There tests are based to dummy scenario.
    Replace all properties, and mock commands by yours.
#>

$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try
            {
                Test-ModuleManifest $_.FullName -ErrorAction Stop
            }
            catch
            {
                $false
            }) }
).BaseName

Import-Module $ProjectName

Get-Module -Name 'DnsServer' -All | Remove-Module -Force
Import-Module -Name "$($PSScriptRoot)\..\Stubs\DnsServer.psm1"

InModuleScope $ProjectName {
    Describe DnsRecordMx -Tag 'DnsRecord', 'DnsRecordMx' {
        Context 'Constructors' {
            It 'Should not throw an exception when instantiated' {
                { [DnsRecordMx]::new() } | Should -Not -Throw
            }

            It 'Has a default or empty constructor' {
                $instance = [DnsRecordMx]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Type creation' {
            It 'Should be type named DnsRecordMx' {
                $instance = [DnsRecordMx]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordMx'
            }
        }
    }

    Describe "Testing DnsRecordMx Get Method" -Tag 'Get', 'DnsRecord', 'DnsRecordMx' {
        BeforeEach {
            $script:instanceDesiredState = [DnsRecordMx] @{
                ZoneName     = 'contoso.com'
                EmailDomain  = 'contoso.com'
                MailExchange = 'mailserver1.contoso.com'
            }
        }

        Context "When the configuration is absent" {
            BeforeAll {
                Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                    Write-Verbose "Mock Get-DnsServerResourceRecord Called" -Verbose
                }
            }

            It 'Should return the state as absent' {
                $currentState = $script:instanceDesiredState.Get()

                Assert-MockCalled Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
                $currentState.Ensure | Should -Be 'Absent'
            }

            It 'Should return the same values as present in Key properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.ZoneName | Should -Be $script:instanceDesiredState.ZoneName
                $getMethodResourceResult.EmailDomain | Should -Be $script:instanceDesiredState.EmailDomain
                $getMethodResourceResult.MailExchange | Should -Be $script:instanceDesiredState.MailExchange
            }

            It 'Should return $false or $null respectively for the rest of the non-key properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.Priority | Should -Be 0
                $getMethodResourceResult.TimeToLive | Should -BeNullOrEmpty
                $getMethodResourceResult.DnsServer | Should -Be 'localhost'
            }
        }

        Context "When the configuration is present" {
            BeforeAll {
                $mockInstancesPath = Resolve-Path -Path $PSScriptRoot

                Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                    Write-Verbose "Mock Get-DnsServerResourceRecord Called" -Verbose

                    return Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\MxRecordInstance.xml"
                }
            }

            It 'Should return the state as present' {
                $currentState = $script:instanceDesiredState.Get()

                Assert-MockCalled Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
                $currentState.Ensure | Should -Be 'Present'
            }

            It 'Should return the same values as present in Key properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.EmailDomain | Should -Be $script:instanceDesiredState.EmailDomain
                $getMethodResourceResult.MailExchange | Should -Be $script:instanceDesiredState.MailExchange
            }
        }

    }

    Describe "Testing DnsRecordMx Test Method" -Tag 'Test', 'DnsRecord', 'DnsRecordMx' {
        BeforeAll {
        }

        Context 'When the system is in the desired state' {
            Context 'When the configuration are absent' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordMx] @{
                        ZoneName     = 'contoso.com'
                        EmailDomain  = 'contoso.com'
                        MailExchange = 'mailserver1.contoso.com'
                        Priority     = 20
                        Ensure       = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordMx] @{
                           ZoneName     = 'contoso.com'
                           EmailDomain  = 'contoso.com'
                           MailExchange = 'mailserver1.contoso.com'
                           Priority     = 20
                           Ensure       = [Ensure]::Absent
                        }

                        return $mockInstanceCurrentState
                    }
                }

                It 'Should return $true' {
                    $script:instanceDesiredState.Test() | Should -BeTrue
                }
            }

            Context 'When the configuration are present' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordMx] @{
                        ZoneName     = 'contoso.com'
                        EmailDomain  = 'contoso.com'
                        MailExchange = 'mailserver1.contoso.com'
                        Priority     = 20
                    }

                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordMx] @{
                           ZoneName     = 'contoso.com'
                           EmailDomain  = 'contoso.com'
                           MailExchange = 'mailserver1.contoso.com'
                           Priority     = 20
                           Ensure       = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }
                }

                It 'Should return $true' {
                    $script:instanceDesiredState.Test() | Should -BeTrue
                }
            }
        }

        Context 'When the system is not in the desired state' {
            Context 'When the configuration should be absent' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordMx] @{
                        ZoneName     = 'contoso.com'
                        EmailDomain  = 'contoso.com'
                        MailExchange = 'mailserver1.contoso.com'
                        Priority     = 20
                        Ensure       = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordMx] @{
                           ZoneName     = 'contoso.com'
                           EmailDomain  = 'contoso.com'
                           MailExchange = 'mailserver1.contoso.com'
                           Priority     = 20
                           Ensure       = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }
                }
                It 'Should return $false' {
                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }

            Context 'When the configuration should be present' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordMx] @{
                        ZoneName     = 'contoso.com'
                        EmailDomain  = 'contoso.com'
                        MailExchange = 'mailserver1.contoso.com'
                        Priority     = 20
                        TimeToLive   = '1:00:00'
                        Ensure       = [Ensure]::Present
                    }
                }

                It 'Should return $false when the object is not found' {
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordMx] @{
                           ZoneName     = 'contoso.com'
                           EmailDomain  = 'contoso.com'
                           MailExchange = 'mailserver1.contoso.com'
                           Priority     = 20
                           Ensure       = [Ensure]::Absent
                        }

                        return $mockInstanceCurrentState
                    }
                    $script:instanceDesiredState.Test() | Should -BeFalse
                }

                $testCasesToFail = @(
                    @{
                        ZoneName     = 'contoso.com'
                        EmailDomain  = 'contoso.com'
                        MailExchange = 'mailserver1.contoso.com'
                        Priority     = 200 # Undesired
                        DnsServer    = 'localhost'
                        TimeToLive   = '01:00:00'
                        Ensure       = [Ensure]::Present
                    },                    @{
                        ZoneName     = 'contoso.com'
                        EmailDomain  = 'contoso.com'
                        MailExchange = 'mailserver1.contoso.com'
                        Priority     = 20
                        DnsServer    = 'localhost'
                        TimeToLive   = '02:00:00' # Undesired
                        Ensure       = 'Present'
                    }
                )

                It 'Should return $false when non-key values are not in the desired state.' -TestCases $testCasesToFail {
                    param
                    (
                        [System.String] $ZoneName,
                        [System.String] $EmailDomain,
                        [System.String] $MailExchange,
                        [System.UInt16] $Priority,
                        [System.String] $TimeToLive
                    )
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordMx] @{
                           ZoneName     = $ZoneName
                           EmailDomain  = $EmailDomain
                           MailExchange = $MailExchange
                           Priority     = $Priority
                           Ensure       = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }

                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }
        }
    }

    Describe "Testing DnsRecordMx Set Method" -Tag 'Set', 'DnsRecord', 'DnsRecordMx' {
        BeforeAll {
            # Mock the Add-DnsServerResourceRecord cmdlet to return nothing
            Mock -CommandName Add-DnsServerResourceRecord -MockWith {
                Write-Verbose "Mock Add-DnsServerResourceRecord Called" -Verbose
            } -Verifiable

            # Mock the Remove-DnsServerResourceRecord cmdlet to return nothing
            Mock -CommandName Remove-DnsServerResourceRecord -MockWith {
                Write-Verbose "Mock Remove-DnsServerResourceRecord Called" -Verbose
            } -Verifiable

            Mock -CommandName Set-DnsServerResourceRecord -MockWith {
                Write-Verbose "Mock Set-DnsServerResourceRecord Called" -Verbose
            } -Verifiable
        }

        Context 'When the system is not in the desired state' {
            BeforeAll {
                $mockInstancesPath = Resolve-Path -Path $PSScriptRoot

                Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                    Write-Verbose "Mock Get-DnsServerResourceRecord Called" -Verbose

                    $mockRecord = Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\MxRecordInstance.xml"

                    # Set a wrong value
                    $mockRecord.TimeToLive = [System.TimeSpan] '2:00:00'

                    return $mockRecord
                }
            }

            Context 'When the configuration should be absent' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordMx] @{
                        ZoneName     = 'contoso.com'
                        EmailDomain  = 'contoso.com'
                        MailExchange = 'mailserver1.contoso.com'
                        Priority     = 0
                        Ensure       = [Ensure]::Absent
                    }
                }

                BeforeEach {
                    $script:instanceDesiredState.Ensure = [Ensure]::Absent
                }

                It 'Should call the correct mocks' {
                    { $script:instanceDesiredState.Set() } | Should -Not -Throw
                    Assert-MockCalled -CommandName Get-DnsServerResourceRecord -Exactly -Times 1 -Scope 'It'
                    Assert-MockCalled -CommandName Remove-DnsServerResourceRecord -Exactly -Times 1 -Scope 'It'
                }
            }

            Context 'When the configuration should be present' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordMx] @{
                        ZoneName     = 'contoso.com'
                        EmailDomain  = 'contoso.com'
                        MailExchange = 'mailserver1.contoso.com'
                        Priority     = 20
                        TimeToLive   = '1:00:00'
                        Ensure       = [Ensure]::Present
                    }
                }

                BeforeEach {
                    $script:instanceDesiredState.Ensure = 'Present'
                }

                It 'Should call the correct mocks when record exists' {
                    { $script:instanceDesiredState.Set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Set-DnsServerResourceRecord -Exactly -Times 1 -Scope 'It'
                }

                It 'Should call the correct mocks when record does not exist' {
                    Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                        Write-Verbose "Mock Get-DnsServerResourceRecord Called" -Verbose

                        return
                    }

                    { $script:instanceDesiredState.Set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Add-DnsServerResourceRecord -Exactly -Times 1 -Scope 'It'
                }
            }

            Assert-VerifiableMock
        }
    }
}
