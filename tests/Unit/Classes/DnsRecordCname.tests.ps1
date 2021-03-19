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
    Describe DnsRecordCname -Tag 'DnsRecord', 'DnsRecordCname' {
        Context 'Constructors' {
            It 'Should not throw an exception when instantiated' {
                { [DnsRecordCname]::new() } | Should -Not -Throw
            }

            It 'Has a default or empty constructor' {
                $instance = [DnsRecordCname]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Type creation' {
            It 'Should be type named DnsRecordCname' {
                $instance = [DnsRecordCname]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordCname'
            }
        }
    }

    Describe "Testing DnsRecordCname Get Method" -Tag 'Get', 'DnsRecord', 'DnsRecordCname' {
        BeforeEach {
            $script:instanceDesiredState = [DnsRecordCname] @{
                ZoneName      = 'contoso.com'
                Name          = 'bar'
                HostNameAlias = 'quarks.contoso.com'
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
                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
                $getMethodResourceResult.HostNameAlias | Should -Be $script:instanceDesiredState.HostNameAlias
            }

            It 'Should return $false or $null respectively for the rest of the non-key properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()


                $getMethodResourceResult.TimeToLive | Should -BeNullOrEmpty
                $getMethodResourceResult.DnsServer | Should -Be 'localhost'
            }
        }

        Context "When the configuration is present" {
            BeforeAll {
                $mockInstancesPath = Resolve-Path -Path $PSScriptRoot

                Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                    Write-Verbose "Mock Get-DnsServerResourceRecord Called" -Verbose

                    return Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\CnameRecordInstance.xml"
                }
            }

            It 'Should return the state as present' {
                $currentState = $script:instanceDesiredState.Get()

                Assert-MockCalled Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
                $currentState.Ensure | Should -Be 'Present'
            }

            It 'Should return the same values as present in Key properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
                $getMethodResourceResult.HostNameAlias | Should -Be $script:instanceDesiredState.HostNameAlias
            }
        }

    }

    Describe "Testing DnsRecordCname Test Method" -Tag 'Test', 'DnsRecord', 'DnsRecordCname' {
        BeforeAll {
        }

        Context 'When the system is in the desired state' {
            Context 'When the configuration are absent' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordCname] @{
                        ZoneName      = 'contoso.com'
                        Name          = 'bar'
                        HostNameAlias = 'quarks.contoso.com'
                        Ensure        = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordCname] @{
                           ZoneName      = 'contoso.com'
                           Name          = 'bar'
                           HostNameAlias = 'quarks.contoso.com'
                           Ensure        = [Ensure]::Absent
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
                    $script:instanceDesiredState = [DnsRecordCname] @{
                        ZoneName      = 'contoso.com'
                        Name          = 'bar'
                        HostNameAlias = 'quarks.contoso.com'
                    }

                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordCname] @{
                           ZoneName      = 'contoso.com'
                           Name          = 'bar'
                           HostNameAlias = 'quarks.contoso.com'
                           Ensure        = [Ensure]::Present
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
                    $script:instanceDesiredState = [DnsRecordCname] @{
                        ZoneName      = 'contoso.com'
                        Name          = 'bar'
                        HostNameAlias = 'quarks.contoso.com'
                        Ensure        = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordCname] @{
                           ZoneName      = 'contoso.com'
                           Name          = 'bar'
                           HostNameAlias = 'quarks.contoso.com'
                           Ensure        = [Ensure]::Present
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
                    $script:instanceDesiredState = [DnsRecordCname] @{
                        ZoneName      = 'contoso.com'
                        Name          = 'bar'
                        HostNameAlias = 'quarks.contoso.com'
                        TimeToLive    = '1:00:00'
                        Ensure        = [Ensure]::Present
                    }
                }

                It 'Should return $false when the object is not found' {
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordCname] @{
                           ZoneName      = 'contoso.com'
                           Name          = 'bar'
                           HostNameAlias = 'quarks.contoso.com'
                           Ensure        = [Ensure]::Absent
                        }

                        return $mockInstanceCurrentState
                    }
                    $script:instanceDesiredState.Test() | Should -BeFalse
                }

                $testCasesToFail = @(
                    @{
                        ZoneName      = 'contoso.com'
                        Name          = 'bar'
                        HostNameAlias = 'quarks.contoso.com'
                        DnsServer     = 'localhost'
                        TimeToLive    = '02:00:00' # Undesired
                        Ensure        = 'Present'
                    }
                )

                It 'Should return $false when non-key values are not in the desired state.' -TestCases $testCasesToFail {
                    param
                    (
                        [System.String] $ZoneName,
                        [System.String] $Name,
                        [System.String] $HostNameAlias,
                        [System.String] $TimeToLive
                    )
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordCname] @{
                           ZoneName      = $ZoneName
                           Name          = $Name
                           HostNameAlias = $HostNameAlias
                           Ensure        = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }

                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }
        }
    }

    Describe "Testing DnsRecordCname Set Method" -Tag 'Set', 'DnsRecord', 'DnsRecordCname' {
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

                    $mockRecord = Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\CnameRecordInstance.xml"

                    # Set a wrong value
                    $mockRecord.TimeToLive = [System.TimeSpan] '2:00:00'

                    return $mockRecord
                }
            }

            Context 'When the configuration should be absent' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordCname] @{
                        ZoneName      = 'contoso.com'
                        Name          = 'bar'
                        HostNameAlias = 'quarks.contoso.com'
                        Ensure        = [Ensure]::Absent
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
                    $script:instanceDesiredState = [DnsRecordCname] @{
                        ZoneName      = 'contoso.com'
                        Name          = 'bar'
                        HostNameAlias = 'quarks.contoso.com'
                        TimeToLive    = '1:00:00'
                        Ensure        = [Ensure]::Present
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
