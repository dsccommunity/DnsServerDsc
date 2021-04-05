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

Describe 'DnsServerRecursion\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module -ModuleName $ProjectName
            Mock -CommandName Get-DnsServerRecursion -ModuleName $ProjectName -MockWith {
                return New-CimInstance -ClassName 'DnsServerRecursion' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    Enable            = $true
                    AdditionalTimeout = 4
                    RetryInterval     = 3
                    Timeout           = 8
                }
            }
        }

        BeforeEach {
            $mockDnsServerRecursionInstance = InModuleScope $ProjectName {
                [DnsServerRecursion]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockDnsServerRecursionInstance | Should -Not -BeNullOrEmpty
            $mockDnsServerRecursionInstance.GetType().Name | Should -Be 'DnsServerRecursion'
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

            $mockDnsServerRecursionInstance.DnsServer = $HostName

            $getResult = $mockDnsServerRecursionInstance.Get()

            $getResult.DnsServer | Should -Be $HostName
            $getResult.Enable | Should -BeTrue
            $getResult.AdditionalTimeout | Should -Be 4
            $getResult.RetryInterval | Should -Be 3
            $getResult.Timeout | Should -Be 8

            Assert-MockCalled -CommandName Get-DnsServerRecursion -ModuleName $ProjectName -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerRecursion\Test()' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerRecursionInstance = InModuleScope $ProjectName {
                [DnsServerRecursion]::new()
            }
        }

        It 'Should throw the correct error when property <PropertyName> has invalid value' -TestCases @(
            @{
                PropertyName = 'AdditionalTimeout'
            }
            @{
                PropertyName = 'RetryInterval'
            }
            @{
                PropertyName = 'Timeout'
            }
        ) {
            param
            (
                $PropertyName
            )

            $mockInvalidValue = 16

            $mockDnsServerRecursionInstance.$PropertyName = $mockInvalidTime

            $mockExpectedErrorMessage = InModuleScope $ProjectName {
                $script:localizedData.PropertyIsNotInValidRange
            }

            { $mockDnsServerRecursionInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f $PropertyName, $mockInvalidTime)
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockDnsServerRecursionInstance = InModuleScope $ProjectName {
                [DnsServerRecursion]::new()
            }

            $mockDnsServerRecursionInstance.Enable = $true
            $mockDnsServerRecursionInstance.AdditionalTimeout = 4
            $mockDnsServerRecursionInstance.RetryInterval = 3
            $mockDnsServerRecursionInstance.Timeout = 8

            # Override Get() method
            $mockDnsServerRecursionInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerRecursion] @{
                            DnsServer         = 'localhost'
                            Enable            = $true
                            AdditionalTimeout = 4
                            RetryInterval     = 3
                            Timeout           = 8
                        }
                    }
                }
        }

        It 'Should return the $true' {
            $getResult = $mockDnsServerRecursionInstance.Test()

            $getResult | Should -BeTrue
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $testCases = @(
                @{
                    PropertyName  = 'Enable'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'AdditionalTimeout'
                    PropertyValue = 5
                }
                @{
                    PropertyName  = 'RetryInterval'
                    PropertyValue = 4
                }
                @{
                    PropertyName  = 'Timeout'
                    PropertyValue = 9
                }
            )
        }

        BeforeEach {
            $mockDnsServerRecursionInstance = InModuleScope $ProjectName {
                [DnsServerRecursion]::new()
            }

            # Override Get() method
            $mockDnsServerRecursionInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerRecursion] @{
                            DnsServer         = 'localhost'
                            Enable            = $true
                            AdditionalTimeout = 4
                            RetryInterval     = 3
                            Timeout           = 8
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

            $mockDnsServerRecursionInstance.$PropertyName = $PropertyValue

            $getResult = $mockDnsServerRecursionInstance.Test()

            $getResult | Should -BeFalse
        }
    }
}

Describe 'DnsServerRecursion\Set()' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerRecursionInstance = InModuleScope $ProjectName {
                [DnsServerRecursion]::new()
            }
        }

        It 'Should throw the correct error when property <PropertyName> has invalid value' -TestCases @(
            @{
                PropertyName = 'AdditionalTimeout'
            }
            @{
                PropertyName = 'RetryInterval'
            }
            @{
                PropertyName = 'Timeout'
            }
        ) {
            param
            (
                $PropertyName
            )

            $mockInvalidValue = 16

            $mockDnsServerRecursionInstance.$PropertyName = $mockInvalidTime

            $mockExpectedErrorMessage = InModuleScope $ProjectName {
                $script:localizedData.PropertyIsNotInValidRange
            }

            { $mockDnsServerRecursionInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f $PropertyName, $mockInvalidTime)
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerRecursion -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'Enable'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'AdditionalTimeout'
                    PropertyValue = 4
                }
                @{
                    PropertyName  = 'RetryInterval'
                    PropertyValue = 3
                }
                @{
                    PropertyName  = 'Timeout'
                    PropertyValue = 8
                }
            )
        }

        BeforeEach {
            $mockDnsServerRecursionInstance = InModuleScope $ProjectName {
                [DnsServerRecursion]::new()
            }

            $mockDnsServerRecursionInstance.DnsServer = 'localhost'

            # Override Get() method
            $mockDnsServerRecursionInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerRecursion] @{
                            DnsServer         = 'localhost'
                            Enable            = $true
                            AdditionalTimeout = 4
                            RetryInterval     = 3
                            Timeout           = 8
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

            $mockDnsServerRecursionInstance.$PropertyName = $PropertyValue

            { $mockDnsServerRecursionInstance.Set() } | Should -Not -Throw

            Assert-MockCalled -CommandName Set-DnsServerRecursion -ModuleName $ProjectName -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerRecursion -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'Enable'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'AdditionalTimeout'
                    PropertyValue = 5
                }
                @{
                    PropertyName  = 'RetryInterval'
                    PropertyValue = 4
                }
                @{
                    PropertyName  = 'Timeout'
                    PropertyValue = 9
                }
            )
        }

        BeforeEach {
            $mockDnsServerRecursionInstance = InModuleScope $ProjectName {
                [DnsServerRecursion]::new()
            }

            # Override Get() method
            $mockDnsServerRecursionInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerRecursion] @{
                            DnsServer         = 'localhost'
                            Enable            = $true
                            AdditionalTimeout = 4
                            RetryInterval     = 3
                            Timeout           = 8
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

                $mockDnsServerRecursionInstance.DnsServer = 'localhost'
                $mockDnsServerRecursionInstance.$PropertyName = $PropertyValue

                { $mockDnsServerRecursionInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerRecursion -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }

        Context 'When parameter DnsServer is set to ''dns.company.local''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                param
                (
                    $PropertyName,
                    $PropertyValue
                )

                $mockDnsServerRecursionInstance.DnsServer = 'dns.company.local'
                $mockDnsServerRecursionInstance.$PropertyName = $PropertyValue

                { $mockDnsServerRecursionInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerRecursion -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }
    }
}
