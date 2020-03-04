#region HEADER
$script:projectPath = "$PSScriptRoot\..\.." | Convert-Path
$script:projectName = (Get-ChildItem -Path "$script:projectPath\*\*.psd1" | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest -Path $_.FullName -ErrorAction Stop } catch { $false })
    }).BaseName

$script:parentModule = Get-Module -Name $script:projectName -ListAvailable | Select-Object -First 1
$script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'
Remove-Module -Name $script:parentModule -Force -ErrorAction 'SilentlyContinue'

$script:subModuleName = (Split-Path -Path $PSCommandPath -Leaf) -replace '\.Tests.ps1'
$script:subModuleFile = Join-Path -Path $script:subModulesFolder -ChildPath "$($script:subModuleName)"

Import-Module $script:subModuleFile -Force -ErrorAction 'Stop'
#endregion HEADER

InModuleScope $script:subModuleName {
    Describe 'DnsServerDsc.Common\Assert-Module' {
        BeforeAll {
            $testModuleName = 'TestModule'
        }

        Context 'When module is not installed' {
            BeforeAll {
                Mock -CommandName Get-Module
            }

            It 'Should throw the correct error' {
                { Assert-Module -Name $testModuleName } | `
                        Should -Throw ($script:localizedData.RoleNotFound -f $testModuleName)
            }
        }

        Context 'When module is available' {
            BeforeAll {
                Mock -CommandName Import-Module
                Mock -CommandName Get-Module -MockWith {
                    return @{
                        Name = $testModuleName
                    }
                }
            }

            It 'Should not throw an error' {
                { Assert-Module -Name $testModuleName } | Should -Not -Throw
            }
        }
    }

    Describe 'DnsServerDsc.Common\Remove-CommonParameter' {
        $removeCommonParameter = @{
            Parameter1          = 'value1'
            Parameter2          = 'value2'
            Verbose             = $true
            Debug               = $true
            ErrorAction         = 'Stop'
            WarningAction       = 'Stop'
            InformationAction   = 'Stop'
            ErrorVariable       = 'errorVariable'
            WarningVariable     = 'warningVariable'
            OutVariable         = 'outVariable'
            OutBuffer           = 'outBuffer'
            PipelineVariable    = 'pipelineVariable'
            InformationVariable = 'informationVariable'
            WhatIf              = $true
            Confirm             = $true
            UseTransaction      = $true
        }

        Context 'Hashtable contains all common parameters' {
            It 'Should not throw exception' {
                { $script:result = Remove-CommonParameter -Hashtable $removeCommonParameter -Verbose } | Should -Not -Throw
            }

            It 'Should have retained parameters in the hashtable' {
                $script:result.Contains('Parameter1') | Should -Be $true
                $script:result.Contains('Parameter2') | Should -Be $true
            }

            It 'Should have removed the common parameters from the hashtable' {
                $script:result.Contains('Verbose') | Should -Be $false
                $script:result.Contains('Debug') | Should -Be $false
                $script:result.Contains('ErrorAction') | Should -Be $false
                $script:result.Contains('WarningAction') | Should -Be $false
                $script:result.Contains('InformationAction') | Should -Be $false
                $script:result.Contains('ErrorVariable') | Should -Be $false
                $script:result.Contains('WarningVariable') | Should -Be $false
                $script:result.Contains('OutVariable') | Should -Be $false
                $script:result.Contains('OutBuffer') | Should -Be $false
                $script:result.Contains('PipelineVariable') | Should -Be $false
                $script:result.Contains('InformationVariable') | Should -Be $false
                $script:result.Contains('WhatIf') | Should -Be $false
                $script:result.Contains('Confirm') | Should -Be $false
                $script:result.Contains('UseTransaction') | Should -Be $false
            }
        }
    }

    Describe 'DnsServerDsc.Common\ConvertTo-CimInstance' {
        $hashtable = @{
            k1 = 'v1'
            k2 = 100
            k3 = 1, 2, 3
        }

        Context 'The array contains the expected record count' {
            It 'Should not throw exception' {
                { $script:result = [CimInstance[]]($hashtable | ConvertTo-CimInstance) } | Should -Not -Throw
            }

            It "Record count should be $($hashTable.Count)" {
                $script:result.Count | Should -Be $hashtable.Count
            }

            It 'Result should be of type CimInstance[]' {
                $script:result.GetType().Name | Should -Be 'CimInstance[]'
            }

            It 'Value "k1" in the CimInstance array should be "v1"' {
                ($script:result | Where-Object Key -eq k1).Value | Should -Be 'v1'
            }

            It 'Value "k2" in the CimInstance array should be "100"' {
                ($script:result | Where-Object Key -eq k2).Value | Should -Be 100
            }

            It 'Value "k3" in the CimInstance array should be "1,2,3"' {
                ($script:result | Where-Object Key -eq k3).Value | Should -Be '1,2,3'
            }
        }
    }

    Describe 'DnsServerDsc.Common\ConvertTo-HashTable' {
        [CimInstance[]]$cimInstances = ConvertTo-CimInstance -Hashtable @{
            k1 = 'v1'
            k2 = 100
            k3 = 1, 2, 3
        }

        Context 'The array contains the expected record count' {
            It 'Should not throw exception' {
                { $script:result = $cimInstances | ConvertTo-HashTable } | Should -Not -Throw
            }

            It "Record count should be $($cimInstances.Count)" {
                $script:result.Count | Should -Be $cimInstances.Count
            }

            It 'Result should be of type [System.Collections.Hashtable]' {
                $script:result | Should -BeOfType [System.Collections.Hashtable]
            }

            It 'Value "k1" in the hashtable should be "v1"' {
                $script:result.k1 | Should -Be 'v1'
            }

            It 'Value "k2" in the hashtable should be "100"' {
                $script:result.k2 | Should -Be 100
            }

            It 'Value "k3" in the hashtable should be "1,2,3"' {
                $script:result.k3 | Should -Be '1,2,3'
            }
        }
    }
}
