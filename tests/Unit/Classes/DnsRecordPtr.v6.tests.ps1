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

    Describe "Testing the expandIPv6String method for completeness (See Issue #255)" -Tag 'expandIPv6String', 'DnsRecord', 'DnsRecordPtr' {
        $testObj = [DnsRecordPtr]::new()

        Context "Expands the following addresses correctly" {
            $testCases = @"
3ea8:1140:571c:e8d8:2e83:cb3a:0000:9431
c69e:276d:0e86:c274:c7f0:0000:8dc3:e662
db8c:e4ec:32f7:41a2:0000:842e:d212:b4c2
0a98:d329:7ed1:0000:a09e:8b35:19ea:5bd9
53ed:054f:0000:8a4c:ed3b:218b:f2f2:a685
e7b3:0000:4acf:f23c:d427:780a:f34c:833b
164a:8626:55f8:c422:dd25:0000:0000:0a5b
f0a0:fa5c:a0bf:5732:0000:0000:9b2e:2307
afd4:640b:c7c3:0000:0000:c8b3:ae79:b2c4
9b2e:7ede:0000:0000:6c70:0c44:26ff:39aa
a5f2:0000:0000:ce7f:f152:e5bb:99de:7f7e
5511:56ea:0b7c:fc9c:0000:0000:0000:664f
6dc2:919a:ab83:0000:0000:0000:57e2:36c7
13fa:2084:0000:0000:0000:8a14:bda1:377d
122f:0000:0000:0000:f3e8:9a84:f1c5:674a
ff02:6db3:354d:0000:0000:0000:0000:bc0c
0018:0832:0000:0000:0000:0000:d4e7:71f4
706e:0000:0000:0000:0000:98b5:ffe5:a652
2950:e8ba:0000:0000:0000:0000:0000:f9ec
e549:0000:0000:0000:0000:0000:9cca:40ad
a788:0000:0000:0000:0000:0000:0000:c8db
d730:a994:ff75:da7f:0000:8027:0000:0020
2bb1:d12d:7fa2:5601:e9fa:22db:7412:51bd
234d:0254:ac61:26df:56c5:25a1:eaf8:87cb
0168:3293:f754:0000:bd31:f91a:0000:000e
2b5b:b929:0243:529d:671b:597d:88be:28e9
c74c:ca12:da15:bd3e:4037:ead2:6059:f14f
4f85:bc16:e333:06b7:d948:60c1:5f61:66e3
d861:9c60:c280:9f4e:705d:0b71:574d:7bdb
493e:81ac:19f3:0dc5:042b:0c86:0a5b:b1cc
7782:d54f:fc68:ceca:9d89:3879:a603:0e43
7358:25cb:9973:d542:6658:9a9e:84d0:6b41
"@ -split "`r*`n" | ForEach-Object {
                @{
                    FullAddress = $_
                    CompactAddress = [System.Net.IpAddress]::Parse($_).IPAddressToString
                }
            }

            It 'Expands <CompactAddress> -> <FullAddress>' -TestCases $testCases {
                param (
                    [System.String] $CompactAddress,
                    [System.String] $FullAddress
                )
                $testObj.expandIPv6String($CompactAddress) | Should -Be $FullAddress
            }
        }
    }

    Describe "Testing DnsRecordPtr Get Method (IPv6 inputs)" -Tag 'Get', 'DnsRecord', 'DnsRecordPtr' {
        BeforeEach {
            $script:instanceDesiredState = [DnsRecordPtr] @{
                ZoneName  = '0.0.d.f.ip6.arpa'
                IpAddress = 'fd00::515c:0:0:d59'
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

                    return Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\PtrV6RecordInstance.xml"
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

    Describe "Testing DnsRecordPtr Test Method (IPv6 inputs)" -Tag 'Test', 'DnsRecord', 'DnsRecordPtr' {
        BeforeAll {
        }

        Context 'When the system is in the desired state' {
            Context 'When the configuration are absent' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.0.d.f.ip6.arpa'
                        IpAddress = 'fd00::515c:0:0:d59'
                        Name      = 'quarks.contoso.com'
                        Ensure    = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                           ZoneName  = '0.0.d.f.ip6.arpa'
                           IpAddress = 'fd00::515c:0:0:d59'
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
                        ZoneName  = '0.0.d.f.ip6.arpa'
                        IpAddress = 'fd00::515c:0:0:d59'
                        Name      = 'quarks.contoso.com'
                    }

                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                           ZoneName  = '0.0.d.f.ip6.arpa'
                           IpAddress = 'fd00::515c:0:0:d59'
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
                        ZoneName  = '0.0.d.f.ip6.arpa'
                        IpAddress = 'fd00::515c:0:0:d59'
                        Name      = 'quarks.contoso.com'
                        Ensure    = [Ensure]::Absent
                    }

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                           ZoneName  = '0.0.d.f.ip6.arpa'
                           IpAddress = 'fd00::515c:0:0:d59'
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
                        ZoneName  = '0.0.d.f.ip6.arpa'
                        IpAddress = 'fd00::515c:0:0:d59'
                        Name      = 'quarks.contoso.com'
                        TimeToLive = '1:00:00'
                        Ensure    = [Ensure]::Present
                    }
                }

                It 'Should return $false when the object is not found' {
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                        $mockInstanceCurrentState = [DnsRecordPtr] @{
                           ZoneName  = '0.0.d.f.ip6.arpa'
                           IpAddress = 'fd00::515c:0:0:d59'
                           Name      = 'quarks.contoso.com'
                           Ensure    = [Ensure]::Absent
                        }

                        return $mockInstanceCurrentState
                    }
                    $script:instanceDesiredState.Test() | Should -BeFalse
                }

                $testCasesToFail = @(
                    @{
                        ZoneName  = '0.0.d.f.ip6.arpa'
                        IpAddress = 'fd00::515c:0:0:d59'
                        Name      = 'quarks.contoso.com'
                        DnsServer = 'localhost'
                        TimeToLive = '02:00:00' # Undesired
                        Ensure    = 'Present'
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

    Describe "Testing DnsRecordPtr Set Method (IPv6 inputs)" -Tag 'Set', 'DnsRecord', 'DnsRecordPtr' {
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

                    $mockRecord = Import-Clixml -Path "$($mockInstancesPath)\..\MockObjects\PtrV6RecordInstance.xml"

                    # Set a wrong value
                    $mockRecord.TimeToLive = [System.TimeSpan] '2:00:00'

                    return $mockRecord
                }
            }

            Context 'When the configuration should be absent' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordPtr] @{
                        ZoneName  = '0.0.d.f.ip6.arpa'
                        IpAddress = 'fd00::515c:0:0:d59'
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
                        ZoneName  = '0.0.d.f.ip6.arpa'
                        IpAddress = 'fd00::515c:0:0:d59'
                        Name      = 'quarks.contoso.com'
                        TimeToLive = '1:00:00'
                        Ensure    = [Ensure]::Present
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
