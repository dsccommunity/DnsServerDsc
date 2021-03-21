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
    Describe DnsRecordPtr -Tag 'DnsRecord', 'DnsRecordPtr' {
        Context 'Constructors' {
            It 'Should not throw an exception when instantiated' {
                { [DnsRecordPtr]::new() } | Should -Not -Throw
            }

            It 'Has a default or empty constructor' {
                $instance = [DnsRecordPtr]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Type creation' {
            It 'Should be type named DnsRecordPtr' {
                $instance = [DnsRecordPtr]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordPtr'
            }
        }
    }

    Describe "Testing DnsRecordPtr Get Method" -Tag 'Get', 'DnsRecord', 'DnsRecordPtr' {
        BeforeEach {
            $script:instanceDesiredState = [DnsRecordPtr] @{
                ZoneName  = '0.168.192.in-addr.arpa'
                IpAddress = '192.168.0.9'
                Name      = 'quarks.contoso.com'
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
                $getMethodResourceResult.IpAddress | Should -Be $script:instanceDesiredState.IpAddress
                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
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

                    return Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\PtrRecordInstance.xml"
                }
            }

            It 'Should return the state as present' {
                $currentState = $script:instanceDesiredState.Get()

                Assert-MockCalled Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
                $currentState.Ensure | Should -Be 'Present'
            }

            It 'Should return the same values as present in Key properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.IpAddress | Should -Be $script:instanceDesiredState.IpAddress
                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
            }
        }

    }

    Describe "Testing DnsRecordPtr Test Method" -Tag 'Test', 'DnsRecord', 'DnsRecordPtr' {
        BeforeAll {
        }

        Context 'When the system is in the desired state' {
            Context 'When the configuration are absent' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.168.192.in-addr.arpa'
                        IpAddress = '192.168.0.9'
                        Name      = 'quarks.contoso.com'
                        Ensure    = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = '0.168.192.in-addr.arpa'
                            IpAddress = '192.168.0.9'
                            Name      = 'quarks.contoso.com'
                            Ensure    = [Ensure]::Absent
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
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.168.192.in-addr.arpa'
                        IpAddress = '192.168.0.9'
                        Name      = 'quarks.contoso.com'
                    }

                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = '0.168.192.in-addr.arpa'
                            IpAddress = '192.168.0.9'
                            Name      = 'quarks.contoso.com'
                            Ensure    = [Ensure]::Present
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
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.168.192.in-addr.arpa'
                        IpAddress = '192.168.0.9'
                        Name      = 'quarks.contoso.com'
                        Ensure    = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = '0.168.192.in-addr.arpa'
                            IpAddress = '192.168.0.9'
                            Name      = 'quarks.contoso.com'
                            Ensure    = [Ensure]::Present
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
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName   = '0.168.192.in-addr.arpa'
                        IpAddress  = '192.168.0.9'
                        Name       = 'quarks.contoso.com'
                        TimeToLive = '1:00:00'
                        Ensure     = [Ensure]::Present
                    }
                }

                It 'Should return $false when the object is not found' {
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = '0.168.192.in-addr.arpa'
                            IpAddress = '192.168.0.9'
                            Name      = 'quarks.contoso.com'
                            Ensure    = [Ensure]::Absent
                        }

                        return $mockInstanceCurrentState
                    }
                    $script:instanceDesiredState.Test() | Should -BeFalse
                }

                $testCasesToFail = @(
                    @{
                        ZoneName   = '0.168.192.in-addr.arpa'
                        IpAddress  = '192.168.0.9'
                        Name       = 'quarks.contoso.com'
                        DnsServer  = 'localhost'
                        TimeToLive = '02:00:00' # Undesired
                        Ensure     = 'Present'
                    }
                )

                It 'Should return $false when non-key values are not in the desired state.' -TestCases $testCasesToFail {
                    param
                    (
                        [System.String] $ZoneName,
                        [System.String] $IpAddress,
                        [System.String] $Name,
                        [System.String] $TimeToLive
                    )
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                            ZoneName  = $ZoneName
                            IpAddress = $IpAddress
                            Name      = $Name
                            Ensure    = [Ensure]::Present
                        }

                        return $mockInstanceCurrentState
                    }

                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }
        }
    }

    Describe "Testing DnsRecordPtr Set Method" -Tag 'Set', 'DnsRecord', 'DnsRecordPtr' {
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

                    $mockRecord = Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\PtrRecordInstance.xml"

                    # Set a wrong value
                    $mockRecord.TimeToLive = [System.TimeSpan] '2:00:00'

                    return $mockRecord
                }
            }

            Context 'When the configuration should be absent' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.168.192.in-addr.arpa'
                        IpAddress = '192.168.0.9'
                        Name      = 'quarks.contoso.com'
                        Ensure    = [Ensure]::Absent
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
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName   = '0.168.192.in-addr.arpa'
                        IpAddress  = '192.168.0.9'
                        Name       = 'quarks.contoso.com'
                        TimeToLive = '1:00:00'
                        Ensure     = [Ensure]::Present
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

    Describe "Test bad inputs (both IPv4 and IPv6)" -Tag 'Test', 'DnsRecord', 'DnsRecordPtr' {
        It "Throws when the IPv4 address is malformatted" {
            $malformattedIPv4State = [DnsRecordPtr] @{
                ZoneName  = '0.168.192.in-addr.arpa'
                IpAddress = '192.168.0.DS9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $malformattedIPv4State.Get() } | Should -Throw -ExpectedMessage ('Cannot convert value "{0}" to type "System.Net.IPAddress". Error: "An invalid IP address was specified."' -f $malformattedIPv4State.IpAddress)
        }

        It "Throws when the IPv6 address is malformatted" {
            $malformattedIPv6State = [DnsRecordPtr] @{
                ZoneName  = '0.0.d.f.ip6.arpa'
                IpAddress = 'fd00::1::9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $malformattedIPv6State.Get() } | Should -Throw -ExpectedMessage ('Cannot convert value "{0}" to type "System.Net.IPAddress". Error: "An invalid IP address was specified."' -f $malformattedIPv6State.IpAddress)
        }

        It "Throws when placed in an incorrect IPv4 reverse lookup zone" {
            $wrongIPv4ZoneState = [DnsRecordPtr] @{
                ZoneName  = '0.168.192.in-addr.arpa'
                IpAddress = '192.168.2.9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $wrongIPv4ZoneState.Get() } | Should -Throw -ExpectedMessage ('"{0}" does not belong to the "{1}" zone' -f $wrongIPv4ZoneState.IpAddress, $wrongIPv4ZoneState.ZoneName)
        }

        It "Throws when placed in an incorrect IPv6 reverse lookup zone" {
            $wrongIPv6ZoneState = [DnsRecordPtr] @{
                ZoneName  = '1.0.0.d.f.ip6.arpa'
                IpAddress = 'fd00::9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $wrongIPv6ZoneState.Get() } | Should -Throw -ExpectedMessage ('"{0}" does not belong to the "{1}" zone' -f $wrongIPv6ZoneState.IpAddress, $wrongIPv6ZoneState.ZoneName)
        }

        It "Throws trying to put an IPv6 address into an IPv4 reverse lookup zone" {
            $zoneVersionMismatchV6InV4State = [DnsRecordPtr] @{
                ZoneName  = '0.168.192.in-addr.arpa'
                IpAddress = 'fd00::d59'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $zoneVersionMismatchV6InV4State.Get() } | Should -Throw -ExpectedMessage ('The zone "{0}" is not an IPv6 reverse lookup zone.' -f $zoneVersionMismatchV6InV4State.ZoneName)
        }

        It "Throws trying to put an IPv4 address into an IPv6 reverse lookup zone" {
            $zoneVersionMismatchV4InV6State = [DnsRecordPtr] @{
                ZoneName  = '1.0.0.d.f.ip6.arpa'
                IpAddress = '192.168.2.9'
                Name      = 'quarks.contoso.com'
                Ensure    = 'Present'
            }

            { $zoneVersionMismatchV4InV6State.Get() } | Should -Throw -ExpectedMessage ('The zone "{0}" is not an IPv4 reverse lookup zone.' -f $zoneVersionMismatchV4InV6State.ZoneName)
        }
    }
}
