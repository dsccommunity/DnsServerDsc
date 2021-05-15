$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (
    Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(
            try
            {
                Test-ModuleManifest $_.FullName -ErrorAction Stop
            }
            catch
            {
                $false
            }
        )
    }
).BaseName

Import-Module $ProjectName

Get-Module -Name 'DnsServer' -All | Remove-Module -Force
Import-Module -Name "$PSScriptRoot\..\Stubs\DnsServer.psm1"

Describe 'DnsServerDsSetting\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module -ModuleName $ProjectName
            Mock -CommandName Get-DnsServerDsSetting -ModuleName $ProjectName -MockWith {
                return New-CimInstance -ClassName 'DnsServerDsSetting' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
                    LazyUpdateInterval = 3
                    MinimumBackgroundLoadThreads = 1
                    PollingInterval = 180
                    RemoteReplicationDelay = 30
                    TombstoneInterval = '14.00:00:00'
                }
            }
        }

        BeforeEach {
            $mockDnsServerDsSettingInstance = InModuleScope $ProjectName {
                [DnsServerDsSetting]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockDnsServerDsSettingInstance | Should -Not -BeNullOrEmpty
            $mockDnsServerDsSettingInstance.GetType().Name | Should -Be 'DnsServerDsSetting'
        }

        It 'Should return the correct values for the properties when DnsServer is set to ''<HostName>''' -TestCases @(
            @{
                HostName = 'localhost'
            }
            @{
                HostName = 'dns.company.local'
            }
        ) {
            param
            (
                $HostName
            )

            $mockDnsServerDsSettingInstance.DnsServer = $HostName

            $getResult = $mockDnsServerDsSettingInstance.Get()

            $getResult.DirectoryPartitionAutoEnlistInterval | Should -Be '1.00:00:00'
            $getResult.LazyUpdateInterval | Should -Be 3
            $getResult.MinimumBackgroundLoadThreads | Should -Be 1
            $getResult.PollingInterval | Should -Be 180
            $getResult.RemoteReplicationDelay | Should -Be 30
            $getResult.TombstoneInterval | Should -Be '14.00:00:00'

            Assert-MockCalled -CommandName Get-DnsServerDsSetting -ModuleName $ProjectName -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerDsSetting\Test()' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerDsSettingInstance = InModuleScope $ProjectName {
                [DnsServerDsSetting]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '235.a:00:00'

                $mockDnsServerDsSettingInstance.CacheTimeout = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.PropertyHasWrongFormat
                }

                { $mockDnsServerDsSettingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'CacheTimeout', $mockInvalidTime)
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '-1.00:00:00'

                $mockDnsServerDsSettingInstance.CacheTimeout = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.TimeSpanBelowMinimumValue
                }

                { $mockDnsServerDsSettingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'CacheTimeout', $mockInvalidTime, '00:00:00')
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockDnsServerDsSettingInstance = InModuleScope $ProjectName {
                [DnsServerDsSetting]::new()
            }

            $mockDnsServerDsSettingInstance.EnableReception = $true
            $mockDnsServerDsSettingInstance.EnableProbes = $true
            $mockDnsServerDsSettingInstance.CacheTimeout = '0.00:15:00'

            # Override Get() method
            $mockDnsServerDsSettingInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerDsSetting] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
                }
        }

        It 'Should return the $true' {
            $getResult = $mockDnsServerDsSettingInstance.Test()

            $getResult | Should -BeTrue
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:30:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerDsSettingInstance = InModuleScope $ProjectName {
                [DnsServerDsSetting]::new()
            }

            # Override Get() method
            $mockDnsServerDsSettingInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerDsSetting] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
                }
        }

        It 'Should return the $false when property <PropertyName> is not in desired state' -TestCases $testCases {
            param
            (
                $PropertyName,
                $PropertyValue
            )

            $mockDnsServerDsSettingInstance.$PropertyName = $PropertyValue

            $getResult = $mockDnsServerDsSettingInstance.Test()

            $getResult | Should -BeFalse
        }
    }
}

Describe 'DnsServerDsSetting\Set()' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerDsSettingInstance = InModuleScope $ProjectName {
                [DnsServerDsSetting]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '235.a:00:00'

                $mockDnsServerDsSettingInstance.CacheTimeout = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.PropertyHasWrongFormat
                }

                { $mockDnsServerDsSettingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'CacheTimeout', $mockInvalidTime)
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '-1.00:00:00'

                $mockDnsServerDsSettingInstance.CacheTimeout = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.TimeSpanBelowMinimumValue
                }

                { $mockDnsServerDsSettingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'CacheTimeout', $mockInvalidTime, '00:00:00')
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerDsSetting -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:15:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerDsSettingInstance = InModuleScope $ProjectName {
                [DnsServerDsSetting]::new()
            }

            $mockDnsServerDsSettingInstance.DnsServer = 'localhost'

            # Override Get() method
            $mockDnsServerDsSettingInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerDsSetting] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
                }
        }

        It 'Should not call any mock to set a value for property ''<PropertyName>''' -TestCases $testCases {
            param
            (
                $PropertyName,
                $PropertyValue
            )

            $mockDnsServerDsSettingInstance.$PropertyName = $PropertyValue

            { $mockDnsServerDsSettingInstance.Set() } | Should -Not -Throw

            Assert-MockCalled -CommandName Set-DnsServerDsSetting -ModuleName $ProjectName -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerDsSetting -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:30:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerDsSettingInstance = InModuleScope $ProjectName {
                [DnsServerDsSetting]::new()
            }

            # Override Get() method
            $mockDnsServerDsSettingInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerDsSetting] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
                }
        }

        Context 'When parameter DnsServer is set to ''localhost''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                param
                (
                    $PropertyName,
                    $PropertyValue
                )

                $mockDnsServerDsSettingInstance.DnsServer = 'localhost'
                $mockDnsServerDsSettingInstance.$PropertyName = $PropertyValue

                { $mockDnsServerDsSettingInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerDsSetting -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }

        Context 'When parameter DnsServer is set to ''dns.company.local''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                param
                (
                    $PropertyName,
                    $PropertyValue
                )

                $mockDnsServerDsSettingInstance.DnsServer = 'dns.company.local'
                $mockDnsServerDsSettingInstance.$PropertyName = $PropertyValue

                { $mockDnsServerDsSettingInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerDsSetting -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }
    }
}
