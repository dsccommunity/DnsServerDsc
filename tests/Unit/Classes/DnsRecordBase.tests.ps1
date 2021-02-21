<#
    This pester file is an example of how organize a pester test.
    There tests are based to dummy scenario.
    Replace all properties, and mock commands by yours.
#>

Using module xDnsServer

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

InModuleScope $ProjectName {
    Describe DnsRecordBase {

        Context 'Constructors' {
            It 'Should not throw an exception when instantiate it' {
                { [DnsRecordBase]::new() } | Should -Not -Throw
            }

            It 'Has a default or empty constructor' {
                $instance = [DnsRecordBase]::new()
                $instance | Should -Not -BeNullOrEmpty
                $instance.GetType().Name | Should -Be 'DnsRecordBase'
            }
        }

        Context 'Type creation' {
            It 'Should be type named DnsRecordBase' {
                $instance = [DnsRecordBase]::new()
                $instance.GetType().Name | Should -Be 'DnsRecordBase'
            }
        }
    }

    Describe 'Testing DnsRecordBase Get Method' -Tag 'Get' {

        Context 'Testing abstract functionality' {
            BeforeAll {
                $script:instanceDesiredState = [DnsRecordBase]::new()
                $script:instanceDesiredState.ZoneName = 'contoso.com'
                $script:instanceDesiredState.TimeToLive = '1:00:00'
                $script:instanceDesiredState.DnsServer = 'localhost'
                $script:instanceDesiredState.Ensure = 'Present'
            }

            It 'Should throw when Get() is called' {
                { $script:instanceDesiredState.Get() } | Should -throw
            }
        }

        Context 'Testing subclassed (implemented) functionality' {
            BeforeAll {
                class MockRecordDoesNotExist : DnsRecordBase
                {
                    [string] GetResourceRecord() {
                        $record = '' | where-object {$false}
                        return $record
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
}
