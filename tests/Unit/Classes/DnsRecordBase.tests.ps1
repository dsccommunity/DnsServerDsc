<#
    This pester file is an example of how organize a pester test.
    There tests are based to dummy scenario.
    Replace all properties, and mock commands by yours.
#>

Using module xDnsServer

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

InModuleScope $ProjectName {
    Describe DnsRecordBase {
        Context 'Constructors' {
            It 'Should not throw an exception when instantiated' {
                { [DnsRecordBase]::new() } | Should -Not -Throw
            }

            It 'Has a default or empty constructor' {
                $instance = [DnsRecordBase]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Type creation' {
            It 'Should be type named DnsRecordBase' {
                $instance = [DnsRecordBase]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordBase'
            }
        }
    }

    Describe 'Testing DnsRecordBase Get Method' -Tag 'Get', 'DnsRecord', 'DnsRecordBase' {
        Context 'Testing abstract functionality' {
            BeforeAll {
                $script:instanceDesiredState = [DnsRecordBase]::new()
                $script:instanceDesiredState.ZoneName = 'contoso.com'
                $script:instanceDesiredState.TimeToLive = '1:00:00'
                $script:instanceDesiredState.DnsServer = 'localhost'
                $script:instanceDesiredState.Ensure = 'Present'
            }

            It 'Should throw when Get() is called' {
                { $script:instanceDesiredState.Get() } | Should -Throw
            }
        }

        Context 'Testing subclassed (implemented) functionality' {
            BeforeAll {
                class MockRecordDoesNotExist : DnsRecordBase
                {
                    [System.String] GetResourceRecord() {
                        return (Invoke-Command {})
                    }
                }

                $script:instanceDesiredState = [MockRecordDoesNotExist]::new()
                $script:instanceDesiredState.ZoneName = 'contoso.com'
                $script:instanceDesiredState.TimeToLive = '1:00:00'
                $script:instanceDesiredState.DnsServer = 'localhost'
                $script:instanceDesiredState.Ensure = 'Present'
            }

            It 'Should return the state as absent' {
                $script:instanceDesiredState.Get().Ensure | Should -Be 'Absent'
            }

            It 'Should return the same values as present in properties' {
                $getMethodResourceResult = $script:instanceDesiredState.Get()

                $getMethodResourceResult.ZoneName | Should -Be $script:instanceDesiredState.ZoneName
                $getMethodResourceResult.TimeToLive | Should -Be $script:instanceDesiredState.TimeToLive
                $getMethodResourceResult.DnsServer | Should -Be $script:instanceDesiredState.DnsServer
            }
        }

    }

    Describe 'Testing DnsRecordBase Set Method' -Tag 'Set', 'DnsRecord', 'DnsRecordBase' {
        Context 'Testing abstract functionality' {
            BeforeAll {
                $script:instanceDesiredState = [DnsRecordBase] @{
                    ZoneName = 'contoso.com'
                    TimeToLive = '1:00:00'
                    DnsServer = 'localhost'
                    Ensure = 'Present'
                }
            }

            It 'Should throw when Set() is called' {
                { $script:instanceDesiredState.Set() } | Should -Throw
            }
        }

        Context 'Testing subclassed (implemented) functionality' {
            BeforeAll {
                class MockRecordDoesNotExist : DnsRecordBase
                {
                    [System.String] GetResourceRecord() {
                        Write-Verbose 'Mock subclassed GetResourceRecord()'
                        return  (Invoke-Command {})
                    }

                    [void] AddResourceRecord() {
                        Write-Verbose 'Mock subclassed AddResourceRecord()'
                    }
                }

                $script:instanceDesiredState = [MockRecordDoesNotExist] @{
                    ZoneName = 'contoso.com'
                    TimeToLive = '1:00:00'
                    DnsServer = 'localhost'
                    Ensure = 'Present'
                }
            }

            It 'Should execute without error' {
                { $script:instanceDesiredState.Set() } | Should -Not -Throw
            }
        }
    }

    Describe 'Testing DnsRecordBase Test Method' -Tag 'Test', 'DnsRecord', 'DnsRecordBase' {
        Context 'Testing abstract functionality' {
            BeforeAll {
                $script:instanceDesiredState = [DnsRecordBase] @{
                    ZoneName = 'contoso.com'
                    TimeToLive = '1:00:00'
                    DnsServer = 'localhost'
                    Ensure = 'Present'
                }
            }

            It 'Should throw when Test() is called' {
                { $script:instanceDesiredState.Test() } | Should -Throw
            }
        }

        Context 'Testing subclassed (implemented) functionality' {
            BeforeAll {
                class MockRecordExists : DnsRecordBase
                {
                    [System.String] GetResourceRecord() {
                        Write-Verbose 'Mock subclassed GetResourceRecord()'
                        return "Not Null Value"
                    }

                    [MockRecordExists] NewDscResourceObjectFromRecord($record) {
                        Write-Verbose 'Mock subclassed NewDscResourceObjectFromRecord()'
                        return [MockRecordExists] @{
                            ZoneName = 'contoso.com'
                            TimeToLive = '1:00:00'
                            DnsServer = 'localhost'
                            Ensure = 'Present'
                        }
                    }
                }
            }

            Context 'When the system is not in the desired state' {
                Context 'When enforcing all non-mandatory parameters' {
                    BeforeAll {
                        $script:instanceDesiredStateExists = [MockRecordExists] @{
                            ZoneName = 'contoso.com'
                            TimeToLive = '1:00:00'
                            DnsServer = 'localhost'
                            Ensure = 'Present'
                        }
                    }

                    It 'Should return $true' {
                        $script:instanceDesiredStateExists.Test() | Should -BeTrue
                    }
                }

                Context 'When no non-mandatory parameters are enforced' {
                    BeforeAll {
                        $script:instanceDesiredStateExists = [MockRecordExists] @{
                            ZoneName = 'contoso.com'
                        }
                    }

                    It 'Should return $true' {
                        $script:instanceDesiredStateExists.Test() | Should -BeTrue
                    }
                }
            }

            Context 'When the system is not in the desired state' {
                Context 'When a DNS record should be present' {
                    BeforeAll {
                        class MockRecordDoesNotExist : DnsRecordBase
                        {
                            [System.String] GetResourceRecord() {
                                Write-Verbose 'Mock subclassed GetResourceRecord()'
                                return  (Invoke-Command {})
                            }
                        }

                        $script:instanceDesiredStateDNE = [MockRecordDoesNotExist] @{
                            ZoneName = 'contoso.com'
                            TimeToLive = '1:00:00'
                            DnsServer = 'localhost'
                            Ensure = 'Present'
                        }
                    }

                    It 'Should return $false' {
                        $script:instanceDesiredStateDNE.Test() | Should -BeFalse
                    }
                }

                Context 'When a non-mandatory property is not in desired state' {
                    BeforeAll {
                        $script:instanceDesiredStateExists = [MockRecordExists] @{
                            ZoneName = 'contoso.com'
                            TimeToLive = '2:00:00'
                        }
                    }

                    It 'Should return $false' {
                        $script:instanceDesiredStateExists.Test() | Should -BeFalse
                    }
                }
            }
        }
    }
}
