<#
    Must have this for the test to work where it creates a class that inherits from
    the ResourceBase class.
#>
using module DnsServerDsc

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

Describe 'ResourceBase\GetCurrentState()' -Tag 'GetCurrentState' {
    Context 'When the required methods are not overridden' {
        BeforeAll {
            $mockResourceBaseInstance = InModuleScope $ProjectName {
                [ResourceBase]::new()
            }
        }

        Context 'When there is no override for the method GetCurrentState' {
            It 'Should throw the correct error' {
                { $mockResourceBaseInstance.GetCurrentState(@{}) } | Should -Throw $mockResourceBaseInstance.GetCurrentStateMethodNotImplemented
            }
        }
    }
}

Describe 'ResourceBase\Modify()' -Tag 'Modify' {
    Context 'When the required methods are not overridden' {
        BeforeAll {
            $mockResourceBaseInstance = InModuleScope $ProjectName {
                [ResourceBase]::new()
            }
        }


        Context 'When there is no override for the method Modify' {
            It 'Should throw the correct error' {
                { $mockResourceBaseInstance.Modify(@{}) } | Should -Throw $mockResourceBaseInstance.ModifyMethodNotImplemented
            }
        }
    }
}

Describe 'ResourceBase\AssertProperties()' -Tag 'AssertProperties' {
    BeforeAll {
        $mockResourceBaseInstance = InModuleScope $ProjectName {
            [ResourceBase]::new()
        }
    }


    It 'Should not throw' {
        { $mockResourceBaseInstance.AssertProperties() } | Should -Not -Throw
    }
}

Describe 'ResourceBase\Get()' -Tag 'Get' {
    Context 'When the required methods are not overridden' {
        BeforeAll {
            $mockResourceBaseInstance = InModuleScope $ProjectName {
                [ResourceBase]::new()
            }
        }

        Context 'When there is no override for the method GetCurrentState' {
            It 'Should throw the correct error' {
                { $mockResourceBaseInstance.GetCurrentState(@{}) } | Should -Throw $mockResourceBaseInstance.GetCurrentStateMethodNotImplemented
            }
        }

        Context 'When there is no override for the method Modify' {
            It 'Should throw the correct error' {
                { $mockResourceBaseInstance.Modify(@{}) } | Should -Throw $mockResourceBaseInstance.ModifyMethodNotImplemented
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module -ModuleName $ProjectName
            Mock -CommandName Get-ClassName -MockWith {
                # Only return localized strings for this class name.
                @('ResourceBase')
            } -ModuleName $ProjectName

            $mockResourceBaseInstance = InModuleScope $ProjectName {
                class MyMockResource : ResourceBase
                {
                    [DscProperty(Key)]
                    [System.String]
                    $DnsServer

                    [DscProperty()]
                    [System.String]
                    $MyResourceProperty

                    [Microsoft.Management.Infrastructure.CimInstance] GetCurrentState([System.Collections.Hashtable] $properties)
                    {
                        return New-CimInstance -ClassName 'AnyClassName' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                            MyResourceProperty = 'MyValue1'
                        }
                    }
                }

                [MyMockResource]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockResourceBaseInstance | Should -Not -BeNullOrEmpty
            $mockResourceBaseInstance.GetType().BaseType.Name | Should -Be 'ResourceBase'
        }

        Context 'When DnsServer is set to ''localhost''' {
            BeforeAll {
                $mockResourceBaseInstance.DnsServer = 'localhost'
            }

            It 'Should return the correct values for the properties' {
                $getResult = $mockResourceBaseInstance.Get()

                $getResult.DnsServer | Should -Be 'localhost'
                $getResult.MyResourceProperty | Should -Be 'MyValue1'
            }
        }

        Context 'When DnsServer is set to ''dns.company.local''' {
            BeforeAll {
                $mockResourceBaseInstance.DnsServer = 'dns.company.local'
            }

            It 'Should return the correct values for the properties' {
                $getResult = $mockResourceBaseInstance.Get()

                $getResult.DnsServer | Should -Be 'dns.company.local'
                $getResult.MyResourceProperty | Should -Be 'MyValue1'
            }
        }
    }
}

Describe 'ResourceBase\Test()' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
        Mock -CommandName Get-ClassName -MockWith {
            # Only return localized strings for this class name.
            @('ResourceBase')
        } -ModuleName $ProjectName
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockResourceBaseInstance = InModuleScope $ProjectName {
                class MyMockResource : ResourceBase
                {
                    [DscProperty(Key)]
                    [System.String]
                    $DnsServer

                    [DscProperty()]
                    [System.String]
                    $MyResourceProperty

                    [System.Collections.Hashtable[]] Compare()
                    {
                        return $null
                    }
                }

                [MyMockResource]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockResourceBaseInstance | Should -Not -BeNullOrEmpty
            $mockResourceBaseInstance.GetType().BaseType.Name | Should -Be 'ResourceBase'
        }

        It 'Should return $true' {
            $mockResourceBaseInstance.Test() | Should -BeTrue
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $mockResourceBaseInstance = InModuleScope $ProjectName {
                class MyMockResource : ResourceBase
                {
                    [DscProperty(Key)]
                    [System.String]
                    $DnsServer

                    [DscProperty()]
                    [System.String]
                    $MyResourceProperty

                    [System.Collections.Hashtable[]] Compare()
                    {
                        # Could just return any non-null object, but mocking a real result.
                        return @{
                            Property      = 'MyResourceProperty'
                            ExpectedValue = '1'
                            ActualValue   = '2'
                        }
                    }
                }

                [MyMockResource]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockResourceBaseInstance | Should -Not -BeNullOrEmpty
            $mockResourceBaseInstance.GetType().BaseType.Name | Should -Be 'ResourceBase'
        }

        It 'Should return $true' {
            $mockResourceBaseInstance.Test() | Should -BeFalse
        }
    }
}

Describe 'ResourceBase\Compare()' -Tag 'Compare' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
        Mock -CommandName Get-ClassName -MockWith {
            # Only return localized strings for this class name.
            @('ResourceBase')
        } -ModuleName $ProjectName
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockResourceBaseInstance = InModuleScope $ProjectName {
                class MyMockResource : ResourceBase
                {
                    [DscProperty(Key)]
                    [System.String]
                    $DnsServer

                    [DscProperty()]
                    [System.String]
                    $MyResourceProperty

                    [DscProperty(NotConfigurable)]
                    [System.String]
                    $MyResourceReadProperty

                    [ResourceBase] Get()
                    {
                        # Creates a new instance of the mock instance MyMockResource.
                        $currentStateInstance = [System.Activator]::CreateInstance($this.GetType())

                        $currentStateInstance.MyResourceProperty = 'MyValue1'
                        $currentStateInstance.MyResourceReadProperty = 'MyReadValue1'

                        return $currentStateInstance
                    }
                }

                [MyMockResource]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockResourceBaseInstance | Should -Not -BeNullOrEmpty
            $mockResourceBaseInstance.GetType().BaseType.Name | Should -Be 'ResourceBase'
        }

        Context 'When no properties are enforced' {
            It 'Should not return any property to enforce' {
                $mockResourceBaseInstance.Compare() | Should -BeNullOrEmpty
            }
        }

        Context 'When one property are enforced but in desired state' {
            BeforeAll {
                $mockResourceBaseInstance.MyResourceProperty = 'MyValue1'
            }

            It 'Should not return any property to enforce' {
                $mockResourceBaseInstance.Compare() | Should -BeNullOrEmpty -Because 'nothing means all properties are in desired state'
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $mockResourceBaseInstance = InModuleScope $ProjectName {
                class MyMockResource : ResourceBase
                {
                    [DscProperty(Key)]
                    [System.String]
                    $DnsServer

                    [DscProperty()]
                    [System.String]
                    $MyResourceProperty1

                    [DscProperty()]
                    [System.String]
                    $MyResourceProperty2

                    [DscProperty(NotConfigurable)]
                    [System.String]
                    $MyResourceReadProperty

                    [ResourceBase] Get()
                    {
                        # Creates a new instance of the mock instance MyMockResource.
                        $currentStateInstance = [System.Activator]::CreateInstance($this.GetType())

                        $currentStateInstance.MyResourceProperty1 = 'MyValue1'
                        $currentStateInstance.MyResourceProperty2 = 'MyValue2'
                        $currentStateInstance.MyResourceReadProperty = 'MyReadValue1'

                        return $currentStateInstance
                    }
                }

                [MyMockResource]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockResourceBaseInstance | Should -Not -BeNullOrEmpty
            $mockResourceBaseInstance.GetType().BaseType.Name | Should -Be 'ResourceBase'
        }

        Context 'When only enforcing one property' {
            BeforeAll {
                # Set desired value for the property that should be enforced.
                $mockResourceBaseInstance.MyResourceProperty1 = 'MyNewValue1'
            }

            It 'Should return the correct property that is not in desired state' {
                $compareResult = $mockResourceBaseInstance.Compare()
                $compareResult | Should -HaveCount 1

                $compareResult[0].Property | Should -Be 'MyResourceProperty1'
                $compareResult[0].ExpectedValue | Should -Be 'MyNewValue1'
                $compareResult[0].ActualValue | Should -Be 'MyValue1'
            }
        }

        Context 'When only enforcing two properties' {
            BeforeAll {
                # Set desired value for the properties that should be enforced.
                $mockResourceBaseInstance.MyResourceProperty1 = 'MyNewValue1'
                $mockResourceBaseInstance.MyResourceProperty2 = 'MyNewValue2'
            }

            It 'Should return the correct property that is not in desired state' {
                <#
                    The properties that are returned are not [ordered] so they can
                    come in any order from run to run. The test handle that.
                #>
                $compareResult = $mockResourceBaseInstance.Compare()
                $compareResult | Should -HaveCount 2

                $compareResult.Property | Should -Contain 'MyResourceProperty1'
                $compareResult.Property | Should -Contain 'MyResourceProperty2'

                $compareProperty = $compareResult.Where( { $_.Property -eq 'MyResourceProperty1' })
                $compareProperty.ExpectedValue | Should -Be 'MyNewValue1'
                $compareProperty.ActualValue | Should -Be 'MyValue1'

                $compareProperty = $compareResult.Where( { $_.Property -eq 'MyResourceProperty2' })
                $compareProperty.ExpectedValue | Should -Be 'MyNewValue2'
                $compareProperty.ActualValue | Should -Be 'MyValue2'
            }
        }
    }
}

Describe 'ResourceBase\GetDesiredStateForSplatting()' -Tag 'GetDesiredStateForSplatting' {
    BeforeAll {
        $mockResourceBaseInstance = InModuleScope $ProjectName {
            [ResourceBase]::new()
        }

        $mockProperties = @(
            @{
                Property      = 'MyResourceProperty1'
                ExpectedValue = 'MyNewValue1'
                ActualValue   = 'MyValue1'
            },
            @{
                Property      = 'MyResourceProperty2'
                ExpectedValue = 'MyNewValue2'
                ActualValue   = 'MyValue2'
            }
        )
    }

    It 'Should return the correct values in a hashtable' {
        $getDesiredStateForSplattingResult = $mockResourceBaseInstance.GetDesiredStateForSplatting($mockProperties)

        $getDesiredStateForSplattingResult | Should -BeOfType [System.Collections.Hashtable]

        $getDesiredStateForSplattingResult.Keys | Should -HaveCount 2
        $getDesiredStateForSplattingResult.Keys | Should -Contain 'MyResourceProperty1'
        $getDesiredStateForSplattingResult.Keys | Should -Contain 'MyResourceProperty2'

        $getDesiredStateForSplattingResult.MyResourceProperty1 | Should -Be 'MyNewValue1'
        $getDesiredStateForSplattingResult.MyResourceProperty2 | Should -Be 'MyNewValue2'
    }
}


Describe 'ResourceBase\Set()' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
        Mock -CommandName Get-ClassName -MockWith {
            # Only return localized strings for this class name.
            @('ResourceBase')
        } -ModuleName $ProjectName
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockResourceBaseInstance = InModuleScope $ProjectName {
                class MyMockResource : ResourceBase
                {
                    [DscProperty(Key)]
                    [System.String]
                    $DnsServer

                    [DscProperty()]
                    [System.String]
                    $MyResourceProperty1

                    [DscProperty()]
                    [System.String]
                    $MyResourceProperty2

                    # Hidden property to determine whether the method Modify() was called.
                    hidden [System.Collections.Hashtable] $mockModifyProperties = @{}

                    [System.Collections.Hashtable[]] Compare()
                    {
                        return $null
                    }

                    [void] Modify([System.Collections.Hashtable] $properties)
                    {
                        $this.mockModifyProperties = $properties
                    }
                }

                [MyMockResource]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockResourceBaseInstance | Should -Not -BeNullOrEmpty
            $mockResourceBaseInstance.GetType().BaseType.Name | Should -Be 'ResourceBase'
        }

        It 'Should not set any property' {
            $mockResourceBaseInstance.Set()

            $mockResourceBaseInstance.mockModifyProperties | Should -BeNullOrEmpty
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When setting one property' {
            BeforeAll {
                $mockResourceBaseInstance = InModuleScope $ProjectName {
                    class MyMockResource : ResourceBase
                    {
                        [DscProperty(Key)]
                        [System.String]
                        $DnsServer

                        [DscProperty()]
                        [System.String]
                        $MyResourceProperty1

                        [DscProperty()]
                        [System.String]
                        $MyResourceProperty2

                        # Hidden property to determine whether the method Modify() was called.
                        hidden [System.Collections.Hashtable] $mockModifyProperties = @{}

                        [System.Collections.Hashtable[]] Compare()
                        {
                            return @(
                                @{
                                    Property      = 'MyResourceProperty1'
                                    ExpectedValue = 'MyNewValue1'
                                    ActualValue   = 'MyValue1'
                                }
                            )
                        }

                        [void] Modify([System.Collections.Hashtable] $properties)
                        {
                            $this.mockModifyProperties = $properties
                        }
                    }

                    [MyMockResource]::new()
                }
            }

            It 'Should have correctly instantiated the resource class' {
                $mockResourceBaseInstance | Should -Not -BeNullOrEmpty
                $mockResourceBaseInstance.GetType().BaseType.Name | Should -Be 'ResourceBase'
            }

            Context 'When DnsServer is set to ''localhost''' {
                BeforeAll {
                    $mockResourceBaseInstance.DnsServer = 'localhost'
                }

                It 'Should set the correct property' {
                    $mockResourceBaseInstance.Set()

                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -HaveCount 1
                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -Contain 'MyResourceProperty1'

                    $mockResourceBaseInstance.mockModifyProperties.MyResourceProperty1 | Should -Contain 'MyNewValue1'
                }
            }

            Context 'When DnsServer is set to ''dns.company.local''' {
                BeforeAll {
                    $mockResourceBaseInstance.DnsServer = 'dns.company.local'
                }

                It 'Should set the correct property' {
                    $mockResourceBaseInstance.Set()

                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -HaveCount 2
                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -Contain 'ComputerName'
                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -Contain 'MyResourceProperty1'

                    $mockResourceBaseInstance.mockModifyProperties.ComputerName | Should -Contain 'dns.company.local'
                    $mockResourceBaseInstance.mockModifyProperties.MyResourceProperty1 | Should -Contain 'MyNewValue1'
                }
            }
        }

        Context 'When setting one property' {
            BeforeAll {
                $mockResourceBaseInstance = InModuleScope $ProjectName {
                    class MyMockResource : ResourceBase
                    {
                        [DscProperty(Key)]
                        [System.String]
                        $DnsServer

                        [DscProperty()]
                        [System.String]
                        $MyResourceProperty1

                        [DscProperty()]
                        [System.String]
                        $MyResourceProperty2

                        # Hidden property to determine whether the method Modify() was called.
                        hidden [System.Collections.Hashtable] $mockModifyProperties = @{}

                        [System.Collections.Hashtable[]] Compare()
                        {
                            return @(
                                @{
                                    Property      = 'MyResourceProperty1'
                                    ExpectedValue = 'MyNewValue1'
                                    ActualValue   = 'MyValue1'
                                },
                                @{
                                    Property      = 'MyResourceProperty2'
                                    ExpectedValue = 'MyNewValue2'
                                    ActualValue   = 'MyValue2'
                                }
                            )
                        }

                        [void] Modify([System.Collections.Hashtable] $properties)
                        {
                            $this.mockModifyProperties = $properties
                        }
                    }

                    [MyMockResource]::new()
                }
            }

            It 'Should have correctly instantiated the resource class' {
                $mockResourceBaseInstance | Should -Not -BeNullOrEmpty
                $mockResourceBaseInstance.GetType().BaseType.Name | Should -Be 'ResourceBase'
            }

            Context 'When DnsServer is set to ''localhost''' {
                BeforeAll {
                    $mockResourceBaseInstance.DnsServer = 'localhost'
                }

                It 'Should set the correct properties' {
                    $mockResourceBaseInstance.Set()

                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -HaveCount 2
                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -Contain 'MyResourceProperty1'
                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -Contain 'MyResourceProperty2'

                    $mockResourceBaseInstance.mockModifyProperties.MyResourceProperty1 | Should -Contain 'MyNewValue1'
                    $mockResourceBaseInstance.mockModifyProperties.MyResourceProperty2 | Should -Contain 'MyNewValue2'
                }
            }

            Context 'When DnsServer is set to ''dns.company.local''' {
                BeforeAll {
                    $mockResourceBaseInstance.DnsServer = 'dns.company.local'
                }

                It 'Should set the correct properties' {
                    $mockResourceBaseInstance.Set()

                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -HaveCount 3
                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -Contain 'ComputerName'
                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -Contain 'MyResourceProperty1'
                    $mockResourceBaseInstance.mockModifyProperties.Keys | Should -Contain 'MyResourceProperty2'

                    $mockResourceBaseInstance.mockModifyProperties.ComputerName | Should -Contain 'dns.company.local'
                    $mockResourceBaseInstance.mockModifyProperties.MyResourceProperty1 | Should -Contain 'MyNewValue1'
                    $mockResourceBaseInstance.mockModifyProperties.MyResourceProperty2 | Should -Contain 'MyNewValue2'
                }
            }
        }
    }
}
