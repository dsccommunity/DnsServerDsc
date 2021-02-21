<#
    This pester file is an example of how organize a pester test.
    There tests are based to dummy scenario.
    Replace all properties, and mock commands by yours.
#>

$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop }catch{$false}) }
    ).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe DnsRecordSrv -Tag 'DnsRecordSrv' {

        Context 'Constructors' {
            It 'Should not throw an exception when instanciate it' {
                { [DnsRecordSrv]::new() } | Should -Not -Throw
            }

            It 'Has a default or empty constructor' {
                $instance = [DnsRecordSrv]::new()
                $instance | Should -Not -BeNullOrEmpty
                $instance.GetType().Name | Should -Be 'DnsRecordSrv'
            }
        }

        Context 'Type creation' {
            It 'Should be type named DnsRecordSrv' {
                $instance = [DnsRecordSrv]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordSrv'
            }
        }
    }

    Describe "Testing Get Method" -Tag 'Get', 'DnsRecordSrv' {
        BeforeEach {
            $script:instanceDesiredState = [DnsRecordSrv] @{
                ZoneName = 'contoso.com'
                SymbolicName = 'xmpp'
                Protocol = 'TCP'
                Port = 5222
                Target = 'chat.contoso.com'
            }
        }

        Context "When the configuration is absent" {
            BeforeAll {
                Mock -ModuleName DnsServer -CommandName Get-DnsServerResourceRecord -MockWith {
                    return $null
                }
            }

            It 'Should return the state as absent' {
                $currentState = $script:instanceDesiredState.Get()

                Assert-MockCalled -ModuleName DnsServer Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
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
                Mock  -ModuleName DnsServer -CommandName Get-DnsServerResourceRecord -MockWith {
                    return Import-Clixml -Path "$($PSScriptRoot)\MockObjects\SrvRecordInstance.xml"
                }
            }

            It 'Should return the state as present' {
                $currentState = $script:instanceDesiredState.Get()

                Assert-MockCalled -ModuleName DnsServer Get-DnsServerResourceRecord -Exactly -Times 1 -Scope It
                $currentState.Ensure | Should -Be 'Present'
            }

            It 'Should return the same values as present in properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.Name | Should -Be $script:instanceDesiredState.Name
                $getMethodResourceResult.PropertyMandatory | Should -Be $script:instanceDesiredState.PropertyMandatory
            }
        }

    }

    Describe "Testing Test Method" -Tag 'Test' {
        BeforeAll {
            # change mocking
            $script:mockItemName = 'dummyName'
            $script:mockItem     = [pscustomobject]@{
                Name                       = $script:mockItemName
                PropertyMandatory          = $true
                PropertyBoolReadWrite      = $false
                PropertyBoolReadOnly       = $PropertyBoolReadOnly
                PropertyStringReadOnly     = $PropertyStringReadOnly
            }
        }

        Context 'When the system is in the desired state' {
            Context 'When the configuration are absent' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordSrv]::New()
                    $script:instanceDesiredState.Name = $script:mockItemName
                    $script:instanceDesiredState.Ensure = [Ensure]::Absent

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                            $mockInstanceCurrentState = [DnsRecordSrv]::New()
                            $mockInstanceCurrentState.Name = $script:mockItemName
                            $mockInstanceCurrentState.Ensure = [Ensure]::Absent

                            return $mockInstanceCurrentState
                        }
                }

                It 'Should return $true' {
                    $script:instanceDesiredState.Test() | Should -BeTrue
                }
            }

            Context 'When the configuration are present' {
                BeforeEach {
                    $script:instanceDesiredState = [DnsRecordSrv]::New()
                    $script:instanceDesiredState.Name = $script:mockItemName
                    $script:instanceDesiredState.Ensure = [Ensure]::Present
                    $script:instanceDesiredState.PropertyMandatory = $true
                    $script:instanceDesiredState.PropertyBoolReadWrite = $true

                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                            $mockInstanceCurrentState = [DnsRecordSrv]::New()
                            $mockInstanceCurrentState.Name = $script:mockItemName
                            $mockInstanceCurrentState.Ensure = [Ensure]::Present
                            $mockInstanceCurrentState.PropertyMandatory = $true
                            $mockInstanceCurrentState.PropertyBoolReadWrite = $true
                            $mockInstanceCurrentState.PropertyBoolReadOnly = $true
                            $mockInstanceCurrentState.PropertyStringReadOnly = 'This is a readonly string'

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
                    $script:instanceDesiredState = [DnsRecordSrv]::New()
                    $script:instanceDesiredState.Name = $script:mockItemName
                    $script:instanceDesiredState.Ensure = [Ensure]::Absent

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                            $mockInstanceCurrentState = [DnsRecordSrv]::New()
                            $mockInstanceCurrentState.Name = $script:mockItemName
                            $mockInstanceCurrentState.Ensure = [Ensure]::Present
                            $mockInstanceCurrentState.Reasons += [Reason]@{
                                Code = '{0}:{0}:Ensure' -f $this.GetType()
                                Phrase = ''
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
                    $script:instanceDesiredState = [DnsRecordSrv]::New()
                    $script:instanceDesiredState.Name = $script:mockItemName
                    $script:instanceDesiredState.Ensure = [Ensure]::Present

                }

                $testCase = @(
                    @{
                        Name      = 'dummyName'
                        PropertyMandatory  = $true
                        PropertyBoolReadWrite    = $false
                        PropertyBoolReadOnly    = $false
                        PropertyStringReadOnly = $null
                    },
                    @{
                        Name      = 'dummyName'
                        PropertyMandatory  = $false
                        PropertyBoolReadWrite    = $true
                        PropertyBoolReadOnly    = $false
                        PropertyStringReadOnly = $null
                    }
                )

                It 'Should return $false' {
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                            $mockInstanceCurrentState = [DnsRecordSrv]::New()
                            $mockInstanceCurrentState.Name = $script:mockItemName
                            $mockInstanceCurrentState.Ensure = [Ensure]::Absent
                            $mockInstanceCurrentState.Reasons += [Reason]@{
                                Code = '{0}:{0}:Ensure' -f $this.GetType()
                                Phrase = ''
                            }

                            return $mockInstanceCurrentState
                        }
                    $script:instanceDesiredState.Test() | Should -BeFalse
                }

                It 'Should return $false when PropertyMandatory is <PropertyMandatory>, and PropertyBoolReadWrite is <PropertyBoolReadWrite>' -TestCases $testCase {
                    param
                    (
                        [System.String]
                        $Name,

                        [System.Boolean]
                        $PropertyMandatory,

                        [System.Boolean]
                        $PropertyBoolReadWrite,

                        [System.Boolean]
                        $PropertyBoolReadOnly,

                        [System.String]
                        $PropertyStringReadOnly
                    )
                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                            $mockInstanceCurrentState = [DnsRecordSrv]::New()
                            $mockInstanceCurrentState.Name = $Name
                            $mockInstanceCurrentState.Ensure = [Ensure]::Present
                            $mockInstanceCurrentState.PropertyMandatory = $PropertyMandatory
                            $mockInstanceCurrentState.PropertyBoolReadWrite = $PropertyBoolReadWrite
                            $mockInstanceCurrentState.PropertyBoolReadOnly = $PropertyBoolReadOnly
                            $mockInstanceCurrentState.PropertyStringReadOnly = $PropertyStringReadOnly

                            if ($this.PropertyMandatory -ne $PropertyMandatory)
                            {
                                $mockInstanceCurrentState.Reasons += [Reason]@{
                                    Code = '{0}:{0}:PropertyMandatory' -f $this.GetType()
                                    Phrase = ''
                                }
                            }
                            if ($this.PropertyBoolReadWrite -ne $PropertyBoolReadWrite)
                            {
                                $mockInstanceCurrentState.Reasons += [Reason]@{
                                    Code = '{0}:{0}:PropertyBoolReadWrite' -f $this.GetType()
                                    Phrase = ''
                                }
                            }

                            return $mockInstanceCurrentState
                        }

                    $script:instanceDesiredState.Name = $Name
                    $script:instanceDesiredState.PropertyMandatory = $false
                    $script:instanceDesiredState.PropertyBoolReadWrite = $false

                    $script:instanceDesiredState.Test() | Should -BeFalse
                }
            }
        }
    }

    Describe "Testing Set Method" -Tag 'Set' {
        BeforeAll {
            $script:mockItemName = 'dummyName'
            $script:mockItem     = [pscustomobject]@{
                Name                       = $script:mockItemName
                PropertyMandatory          = $false
                PropertyBoolReadWrite      = $false
                PropertyBoolReadOnly       = $PropertyBoolReadOnly
                PropertyStringReadOnly     = $PropertyStringReadOnly
            }
        }

        Context 'When the system is not in the desired state' {
            BeforeAll {
                Mock -CommandName Set-HelpFunctionProperty
            }

            AfterEach {
                <#
                    Make sure to remove the test test so that it does
                    not exist for other tests.

                    You can uncomment this command and replace by what do
                    you need.

                if ($script:mockItem)
                {
                    Remove-###
                }
                #>
            }

            Context 'When the configuration should be absent' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordSrv]::New()
                    $script:instanceDesiredState.Name = $script:mockItemName

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                            $mockInstanceCurrentState = [DnsRecordSrv]::New()
                            $mockInstanceCurrentState.Name = $script:mockItemName
                            $mockInstanceCurrentState.Ensure = [Ensure]::Present
                            $mockInstanceCurrentState.Reasons += [Reason]@{
                                Code = '{0}:{0}:Ensure' -f $this.GetType()
                                Phrase = ''
                            }

                            return $mockInstanceCurrentState
                        }
                    <#
                        Replace the mock command by yours.
                        And replace the name of properties
                    Mock -CommandName Remove-### -ParameterFilter {
                        $Name -eq $script:mockInstanceCurrentState.Name
                    } -Verifiable
                    #>
                }

                BeforeEach {
                    $script:instanceDesiredState.Ensure = [Ensure]::Absent
                }

                It 'Should call the correct mocks' {
                    { $script:instanceDesiredState.Set() } | Should -Not -Throw

                    <#
                        Replace by your command
                    Assert-MockCalled -CommandName Remove-### -Exactly -Times 1 -Scope 'It'
                    #>
                }
            }

            Context 'When the configuration should be present' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordSrv]::New()
                    $script:instanceDesiredState.Name = $script:mockItemName

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                            $mockInstanceCurrentState = [DnsRecordSrv]::New()
                            $mockInstanceCurrentState.Name = $script:mockItemName
                            $mockInstanceCurrentState.Ensure = [Ensure]::Absent
                            $mockInstanceCurrentState.Reasons += [Reason]@{
                                Code = '{0}:{0}:Ensure' -f $this.GetType()
                                Phrase = ''
                            }

                            return $mockInstanceCurrentState
                        }
                    # Replace by dummyObject
                    $script:mockItem     = [pscustomobject]@{
                        Name                       = $script:mockItemName
                        PropertyMandatory          = $false
                        PropertyBoolReadWrite      = $false
                    }


                    Mock -CommandName Get-DummyObject
                    Mock -CommandName New-Object -ParameterFilter {
                        $Property.Name -eq $script:instanceDesiredState.Name
                    } -MockWith {
                        return $script:mockItem
                    } -Verifiable
                }

                BeforeEach {
                    $script:instanceDesiredState.Ensure = 'Present'
                }

                It 'Should call the correct mocks' {
                    { $script:instanceDesiredState.Set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName Get-DummyObject -Exactly -Times 0 -Scope 'It'
                    Assert-MockCalled -CommandName New-Object -ParameterFilter {
                        $Property.Name -eq $script:instanceDesiredState.Name
                    } -Exactly -Times 1 -Scope 'It'


                    Assert-MockCalled -CommandName Set-HelpFunctionProperty  -ParameterFilter {
                        $Property -eq 'PropertyMandatory'
                    } -Exactly -Times 1 -Scope 'It'

                    Assert-MockCalled -CommandName Set-HelpFunctionProperty  -ParameterFilter {
                        $Property -eq 'PropertyBoolReadWrite'
                    } -Exactly -Times 1 -Scope 'It'

                }
            }

            Context 'When the configuration is present but has the wrong properties' {
                BeforeAll {
                    $script:instanceDesiredState = [DnsRecordSrv]::New()
                    $script:instanceDesiredState.Name = $script:mockItemName

                    $script:mockItem     = [pscustomobject]@{
                        Name                       = $script:mockItemName
                        PropertyMandatory          = $false
                        PropertyBoolReadWrite      = $false
                    }

                    Mock -CommandName New-Object
                    Mock -CommandName Get-DummyObject -ParameterFilter {
                        $Property.Name -eq $script:instance.Name
                    } -MockWith {
                        return $script:mockItem
                    } -Verifiable
                }

                BeforeEach {
                    $script:instanceDesiredState.Ensure = 'Present'
                }

                $testCase = @(
                    @{
                        PropertyMandatory  = $true
                        PropertyBoolReadWrite    = $false
                        PropertyBoolReadOnly    = $false
                        PropertyStringReadOnly = $null
                    },
                    @{
                        PropertyMandatory  = $false
                        PropertyBoolReadWrite    = $true
                        PropertyBoolReadOnly    = $false
                        PropertyStringReadOnly = $null
                    },
                    @{
                        PropertyMandatory  = $false
                        PropertyBoolReadWrite    = $false
                        PropertyBoolReadOnly    = $true
                        PropertyStringReadOnly = 'Test'
                    }
                )

                It 'Should call the correct mocks when PropertyMandatory is <PropertyMandatory>, and PropertyBoolReadWrite is <PropertyBoolReadWrite>' -TestCases $testCase {
                    param
                    (
                        [System.Boolean]
                        $PropertyMandatory,

                        [System.Boolean]
                        $PropertyBoolReadWrite,

                        [System.Boolean]
                        $PropertyBoolReadOnly,

                        [System.String]
                        $PropertyStringReadOnly
                    )

                    #Override Get() method
                    $script:instanceDesiredState | Add-Member -Force -MemberType ScriptMethod -Name Get `
                        -Value {
                            $mockInstanceCurrentState = [DnsRecordSrv]::New()
                            $mockInstanceCurrentState.Name = $script:mockItemName
                            $mockInstanceCurrentState.Ensure = [Ensure]::Present
                            $mockInstanceCurrentState.PropertyMandatory = $PropertyMandatory
                            $mockInstanceCurrentState.PropertyBoolReadWrite = $PropertyBoolReadWrite
                            $mockInstanceCurrentState.PropertyBoolReadOnly = $PropertyBoolReadOnly
                            $mockInstanceCurrentState.PropertyStringReadOnly = $PropertyStringReadOnly

                            return $mockInstanceCurrentState
                        }

                    $script:instanceDesiredState.PropertyMandatory = $false
                    $script:instanceDesiredState.PropertyBoolReadWrite = $false

                    { $script:instanceDesiredState.Set() } | Should -Not -Throw

                    Assert-MockCalled -CommandName New-Object -Exactly -Times 0 -Scope 'It'
                    Assert-MockCalled -CommandName Get-DummyObject -Exactly -Times 1 -Scope 'It'


                    if ($PropertyMandatory)
                    {
                        Assert-MockCalled -CommandName Set-HelpFunctionProperty -ParameterFilter {
                            $Property -eq 'PropertyMandatory'
                        } -Exactly -Times 1 -Scope 'It'
                    }

                    if ($PropertyBoolReadWrite)
                    {
                        Assert-MockCalled -CommandName Set-HelpFunctionProperty -ParameterFilter {
                            $Property -eq 'PropertyBoolReadWrite'
                        } -Exactly -Times 1 -Scope 'It'
                    }
                }
            }

            Assert-VerifiableMock
        }
    }
}
