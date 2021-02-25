<#
    This pester file is an example of how organize a pester test.
    There tests are based to dummy scenario.
    Replace all properties, and mock commands by yours.
#>

$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
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

    Describe DnsRecordSrvScoped -Tag 'DnsRecord', 'DnsRecordSrvScoped' {

        Context 'Constructors' {
            It 'Should not throw an exception when instanciate it' {
                { [DnsRecordSrvScoped]::new() } | Should -Not -Throw
            }

            It 'Has a default or empty constructor' {
                $instance = [DnsRecordSrvScoped]::new()
                $instance | Should -Not -BeNullOrEmpty
                $instance.GetType().Name | Should -Be 'DnsRecordSrvScoped'
            }
        }

        Context 'Type creation' {
            It 'Should be type named DnsRecordSrvScoped' {
                $instance = [DnsRecordSrvScoped]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordSrvScoped'
            }
        }
    }

    Describe "Testing Get Method" -Tag 'Get', 'DnsRecord', 'DnsRecordSrvScoped' {
        BeforeEach {
            $script:instanceDesiredState = [DnsRecordSrvScoped] @{
                ZoneName     = 'contoso.com'
                ZoneScope    = 'external'
                SymbolicName = 'xmpp'
                Protocol     = 'TCP'
                Port         = 5222
                Target       = 'chat.contoso.com'
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

            It 'Should return the same values as present in properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.ZoneName | Should -Be $script:instanceDesiredState.ZoneName
                $getMethodResourceResult.SymbolicName | Should -Be $script:instanceDesiredState.SymbolicName
                $getMethodResourceResult.Protocol | Should -Be $script:instanceDesiredState.Protocol
                $getMethodResourceResult.Port | Should -Be $script:instanceDesiredState.Port
                $getMethodResourceResult.Target | Should -Be $script:instanceDesiredState.Target
            }

            It 'Should return $false or $null respectively for the rest of the properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.Weight | Should -Be 0
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

                    return Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\SrvRecordInstance.xml"
                }
            }

            It 'Should return the state as present' {
                $currentState = $script:instanceDesiredState.Get()

                Assert-MockCalled Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
                $currentState.Ensure | Should -Be 'Present'
            }

            It 'Should return the same values as present in properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
                $getMethodResourceResult.PropertyMandatory | Should -Be $script:instanceDesiredState.PropertyMandatory
            }
        }

    }

    Describe "Testing Test Method" -Tag 'Test', 'DnsRecord', 'DnsRecordSrvScoped' {
        BeforeAll {
        }

        Context 'When the system is in the desired state' {
            Context 'When the configuration are absent' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordSrvScoped] @{
                        ZoneName     = 'contoso.com'
                        ZoneScope    = 'external'
                        SymbolicName = 'xmpp'
                        Protocol     = 'TCP'
                        Port         = 5222
                        Target       = 'chat.contoso.com'
                        Ensure       = [Ensure]::Absent
                    }


                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                        $mockInstanceCurrentState = [DnsRecordSrvScoped] @{
                            ZoneName     = 'contoso.com'
                            ZoneScope    = 'external'
                            SymbolicName = 'xmpp'
                            Protocol     = 'TCP'
                            Port         = 5222
                            Target       = 'chat.contoso.com'
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
                    $script:instanceDesiredState = [DnsRecordSrvScoped] @{
                        ZoneName     = 'contoso.com'
                        ZoneScope    = 'external'
                        SymbolicName = 'xmpp'
                        Protocol     = 'TCP'
                        Port         = 5222
                        Target       = 'chat.contoso.com'
                    }

                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                        $mockInstanceCurrentState = [DnsRecordSrvScoped] @{
                            ZoneName     = 'contoso.com'
                            ZoneScope    = 'external'
                            SymbolicName = 'xmpp'
                            Protocol     = 'TCP'
                            Port         = 5222
                            Target       = 'chat.contoso.com'
                            Ensure       = 'Present'
                        }

                        return $mockInstanceCurrentState
                    }
                }

                It 'Should return $true' {
                    $script:instanceDesiredState.Test() | Should -Be $true
                }
            }
        }

        Context 'When the system is not in the desired state' {
            Context 'When the configuration should be absent' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordSrvScoped] @{
                        ZoneName     = 'contoso.com'
                        ZoneScope    = 'external'
                        SymbolicName = 'xmpp'
                        Protocol     = 'TCP'
                        Port         = 5222
                        Target       = 'chat.contoso.com'
                        Ensure       = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                        $mockInstanceCurrentState = [DnsRecordSrvScoped] @{
                            ZoneName     = 'contoso.com'
                            ZoneScope    = 'external'
                            SymbolicName = 'xmpp'
                            Protocol     = 'TCP'
                            Port         = 5222
                            Target       = 'chat.contoso.com'
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
                    $script:instanceDesiredState = [DnsRecordSrvScoped] @{
                        ZoneName     = 'contoso.com'
                        ZoneScope    = 'external'
                        SymbolicName = 'xmpp'
                        Protocol     = 'TCP'
                        Port         = 5222
                        Target       = 'chat.contoso.com'
                        Priority     = 20
                        Weight       = 30
                        TimeToLive   = "1:00:00"
                        Ensure       = [Ensure]::Present
                    }
                }

                It 'Should return $false when the object is not found' {
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                        $mockInstanceCurrentState = [DnsRecordSrvScoped] @{
                            ZoneName     = 'contoso.com'
                            ZoneScope    = 'external'
                            SymbolicName = 'xmpp'
                            Protocol     = 'TCP'
                            Port         = 5222
                            Target       = 'chat.contoso.com'
                            Ensure       = [Ensure]::Absent
                        }

                        return $mockInstanceCurrentState
                    }
                    $script:instanceDesiredState.Test() | Should -BeFalse
                }


                $testCasesToFail = @(
                    @{
                        SymbolicName = 'xmpp'
                        ZoneName     = 'contoso.com'
                        ZoneScope    = 'external'
                        Ensure       = 'Present'
                        Target       = 'chat.contoso.com'
                        DnsServer    = 'localhost'
                        Port         = 5222
                        Protocol     = 'TCP'
                        Priority     = 30 # Incorrect
                        Weight       = 30
                        TimeToLive   = '01:00:00'
                    }
                    @{
                        SymbolicName = 'xmpp'
                        ZoneName     = 'contoso.com'
                        ZoneScope    = 'external'
                        Ensure       = 'Present'
                        Target       = 'chat.contoso.com'
                        DnsServer    = 'localhost'
                        Port         = 5222
                        Protocol     = 'TCP'
                        Priority     = 20
                        Weight       = 40 # Incorrect
                        TimeToLive   = '01:00:00'
                    },
                    @{
                        SymbolicName = 'xmpp'
                        ZoneName     = 'contoso.com'
                        Ensure       = 'Present'
                        Target       = 'chat.contoso.com'
                        DnsServer    = 'localhost'
                        Port         = 5222
                        Protocol     = 'TCP'
                        Priority     = 20
                        Weight       = 30
                        TimeToLive   = '02:00:00' # Incorrect
                    }
                )

                It 'Should return $false when Priority is <Priority>, Weight is <Weight>, and TimeToLive is <TimeToLive>' -TestCases $testCasesToFail {
                    param
                    (
                        [System.String] $ZoneName,

                        [System.String] $ZoneScope,

                        [System.String] $SymbolicName,

                        [System.String] $Protocol,

                        [System.UInt16] $Port,

                        [System.String] $Target,

                        [System.UInt16] $Priority,

                        [System.UInt16] $Weight,

                        [System.String] $TimeToLive
                    )
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                        $mockInstanceCurrentState = [DnsRecordSrvScoped] @{
                            ZoneName     = $ZoneName
                            ZoneScope     = $ZoneScope
                            SymbolicName = $SymbolicName
                            Protocol     = $Protocol
                            Port         = $Port
                            Target       = $Target
                            Priority     = $Priority
                            Weight       = $Weight
                            TimeToLive   = $TimeToLive
                            Ensure       = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }

                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }
        }
    }

    Describe "Testing Set Method" -Tag 'Set', 'DnsRecord', 'DnsRecordSrvScoped' {
        BeforeAll {
            # Mock the Add-DnsServerResourceRecord cmdlet to return nothing
            Mock -CommandName Add-DnsServerResourceRecord -MockWith {
                Write-Verbose "Mock Add-DnsServerResourceRecord Called" -Verbose
            } -Verifiable

            # Mock the Remove-DnsServerResourceRecord cmdlet to return nothing
            Mock -CommandName Remove-DnsServerResourceRecord -MockWith {
                Write-Verbose "Mock Remove-DnsServerResourceRecord Called" -Verbose
            } -Verifiable
        }

        Context 'When the system is not in the desired state' {
            BeforeAll {
                $mockInstancesPath = Resolve-Path -Path $PSScriptRoot

                Mock -CommandName Get-DnsServerResourceRecord -MockWith {
                    Write-Verbose "Mock Get-DnsServerResourceRecord Called" -Verbose

                    $mockRecord = Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\SrvRecordInstance.xml"

                    # Set a wrong value
                    $mockRecord.RecordData.Priority = 300

                    return $mockRecord
                }
            }

            Context 'When the configuration should be absent' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordSrvScoped] @{
                        ZoneName     = 'contoso.com'
                        ZoneScope    = 'external'
                        SymbolicName = 'xmpp'
                        Protocol     = 'TCP'
                        Port         = 5222
                        Target       = 'chat.contoso.com'
                        Priority     = 0
                        Weight       = 0
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
                    $script:instanceDesiredState = [DnsRecordSrvScoped] @{
                        ZoneName     = 'contoso.com'
                        ZoneScope    = 'external'
                        SymbolicName = 'xmpp'
                        Protocol     = 'TCP'
                        Port         = 5222
                        Target       = 'chat.contoso.com'
                        Priority     = 20
                        Weight       = 30
                        TimeToLive   = "1:00:00"
                        Ensure       = [Ensure]::Present
                    }
                }

                BeforeEach {
                    $script:instanceDesiredState.Ensure = 'Present'
                }

                It 'Should call the correct mocks' {
                    { $script:instanceDesiredState.Set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Remove-DnsServerResourceRecord -Exactly -Times 1 -Scope 'It'
                    Assert-MockCalled -CommandName Add-DnsServerResourceRecord -Exactly -Times 1 -Scope 'It'
                }
            }

            Assert-VerifiableMock
        }
    }
}
