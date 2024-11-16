<#
    .SYNOPSIS
        Unit test for DSC_DnsServerADZone DSC resource.
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
# Suppressing this rule because tests are mocking passwords in clear text.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'DnsServerDsc'
    $script:dscResourceName = 'DSC_DnsServerADZone'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force

    Remove-Module -Name DnsServer -Force
}

Describe 'DSC_DnsServerADZone\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        $testZoneName = 'example.com'
        $testDynamicUpdate = 'Secure'
        $testReplicationScope = 'Domain'
        $testComputerName = 'dnsserver.local'
        $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force)
        $testDirectoryPartitionName = "DomainDnsZones.$testZoneName"

        $fakeDnsADZone = [PSCustomObject] @{
            DistinguishedName      = $null
            ZoneName               = $testZoneName
            ZoneType               = 'Primary'
            DynamicUpdate          = $testDynamicUpdate
            ReplicationScope       = $testReplicationScope
            DirectoryPartitionName = $testDirectoryPartitionName
            ZoneFile               = $null
        }

        Mock -CommandName 'Assert-Module'
    }
    Context 'When DNS zone exists' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsADZone }
        }
        It 'Should return a "System.Collections.Hashtable" object type with schema properties' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }

                $targetResource = Get-TargetResource @params
                $targetResource -is [System.Collections.Hashtable] | Should -BeTrue

                $schemaFields = @('Name', 'DynamicUpdate', 'ReplicationScope', 'DirectoryPartitionName', 'Ensure')
                ($null -eq ($targetResource.Keys.GetEnumerator() | Where-Object -FilterScript { $schemaFields -notcontains $_ })) | Should -BeTrue
            }
        }
    }

    Context 'When "Ensure" = "Present"' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsADZone }
        }
        It 'Should return "Present"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }

                $targetResource = Get-TargetResource @params
                $targetResource.Ensure | Should -Be 'Present'
            }
        }
    }

    Context 'When DNS zone does not exist and "Ensure" = "Present"' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone
        }
        It 'Should return "Absent"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }

                $targetResource = Get-TargetResource @params
                $targetResource.Ensure | Should -Be 'Absent'
            }
        }
    }

    Context 'When DNS zone exists and "Ensure" = "Absent"' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsADZone }
        }
        It 'Should return "Present"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Absent'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }

                $targetResource = Get-TargetResource @params
                $targetResource.Ensure | Should -Be 'Present'
            }
        }
    }

    Context 'When DNS zone does not exist and "Ensure" = "Absent"' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone
        }
        It 'Should return "Absent"' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Absent'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }

                $targetResource = Get-TargetResource @params
                $targetResource.Ensure | Should -Be 'Absent'
            }
        }
    }

    Context 'When a computer name is not passed' {
        BeforeAll {
            Mock -CommandName New-CimSession
            Mock -CommandName Remove-CimSession
            Mock -CommandName Get-DnsServerZone
        }
        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }
                Get-TargetResource @params
            }

            Should -Invoke -CommandName New-CimSession -Scope It -Times 0 -Exactly
            Should -Invoke -CommandName Remove-CimSession -Scope It -Times 0 -Exactly
            Should -Invoke -CommandName Get-DnsServerZone -Scope It -Times 1 -Exactly
        }

        Context 'When credential is passed' {
            It 'Should throw an exception indicating a computername must also be passed' {
                InModuleScope -Parameters @{
                    testCredential = $testCredential
                } -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockErrorMessage = $script:LocalizedData.CredentialRequiresComputerNameMessage
                    $params = @{
                        Name             = 'example.com'
                        ReplicationScope = 'Domain'
                        Credential       = $testCredential
                        Verbose          = $false
                    }

                    { Get-TargetResource @params } | Should -Throw -ExpectedMessage ($mockErrorMessage)
                }
            }
        }
    }

    Context 'When a computer name is passed' {
        BeforeAll {
            Mock -CommandName New-CimSession -MockWith { New-MockObject -Type Microsoft.Management.Infrastructure.CimSession }
            Mock -CommandName Remove-CimSession
            Mock -CommandName Get-DnsServerZone
        }

        It 'Should call expected mocks' {
            InModuleScope -Parameters @{
                testComputerName = $testComputerName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    ComputerName     = $testComputerName
                    Verbose          = $false
                }
                Get-TargetResource @params
            }

            Should -Invoke -CommandName New-CimSession -ParameterFilter { $computername -eq $testComputerName } -Scope It -Times 1 -Exactly
            Should -Invoke -CommandName Remove-CimSession -Scope It -Times 1 -Exactly
        }
    }

    Context 'When credentials are passed' {
        BeforeAll {
            Mock -CommandName Get-DnsServerZone
            Mock -CommandName New-CimSession -MockWith { New-MockObject -Type Microsoft.Management.Infrastructure.CimSession }
            Mock -CommandName Remove-CimSession
        }

        It 'Should call call expected mocks' {
            InModuleScope -Parameters @{
                testComputerName = $testComputerName
                testCredential   = $testCredential
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    ComputerName     = $testComputerName
                    Credential       = $testCredential
                    Verbose          = $false
                }

                { Get-TargetResource @params } | Should -Not -Throw
            }

            Should -Invoke -CommandName New-CimSession -ParameterFilter {
                $ComputerName -eq $testComputerName `
                    -and $credential -eq $testCredential
            } -Scope It -Times 1 -Exactly
            # Regression test for issue https://github.com/PowerShell/DnsServerDsc/issues/79.
            Should -Invoke -CommandName Get-DnsServerZone -ParameterFilter {
                $Name -eq $testZoneName
            }

            Should -Invoke -CommandName Remove-CimSession -Scope It -Times 1 -Exactly
        }
    }
}

Describe 'DSC_DnsServerADZone\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        $testZoneName = 'example.com'
        $testDynamicUpdate = 'Secure'
        $testReplicationScope = 'Domain'
        $testDirectoryPartitionName = "DomainDnsZones.$testZoneName"

        $fakePresentTargetResource = @{
            Name                   = $testZoneName
            DynamicUpdate          = $testDynamicUpdate
            ReplicationScope       = $testReplicationScope
            DirectoryPartitionName = $testDirectoryPartitionName
            Ensure                 = 'Present'
        }
    }
    Context 'When zone is present' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
        }

        It 'Should return a "System.Boolean" object type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }

                $targetResource = Test-TargetResource @params
                $targetResource -is [System.Boolean] | Should -BeTrue
            }
        }
    }

    Context 'When zone is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }
                Test-TargetResource @params | Should -BeTrue
            }
        }
    }

    Context 'When DNS zone does not exist and "Ensure" = "Absent"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Absent'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }
                Test-TargetResource @params | Should -BeTrue
            }
        }
    }

    Context 'When DNS zone "DynamicUpdate" is correct' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Domain'
                    DynamicUpdate    = 'Secure'
                    Verbose          = $false
                }
                Test-TargetResource @params | Should -BeTrue
            }
        }
    }

    Context 'When DNS zone "DirectoryPartitionName" is correct' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
        }

        It 'Should return $true' {
            InModuleScope -Parameters @{
                testDirectoryPartitionName = $testDirectoryPartitionName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name                   = 'example.com'
                    Ensure                 = 'Present'
                    ReplicationScope       = 'Domain'
                    DirectoryPartitionName = $testDirectoryPartitionName
                    Verbose                = $false
                }
                Test-TargetResource @params | Should -BeTrue
            }
        }
    }

    Context 'When DNS zone exists and "Ensure" = "Absent"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Absent'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }
                Test-TargetResource @params | Should -BeFalse
            }
        }
    }

    Context 'When DNS zone does not exist and "Ensure" = "Present"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }
                Test-TargetResource @params | Should -BeFalse
            }
        }
    }

    Context 'When "DynamicUpdate" is incorrect' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Domain'
                    DynamicUpdate    = 'NonSecureAndSecure'
                    Verbose          = $false
                }
                Test-TargetResource @params | Should -BeFalse
            }
        }
    }

    Context 'When "ReplicationScope" is incorrect' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Forest'
                    Verbose          = $false
                }
                Test-TargetResource @params | Should -BeFalse
            }
        }
    }

    Context 'When "DirectoryPartitionName" is incorrect' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
        }

        It 'Should return $false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name                   = 'example.com'
                    Ensure                 = 'Present'
                    ReplicationScope       = 'Domain'
                    DirectoryPartitionName = 'IncorrectDirectoryPartitionName'
                    Verbose                = $false
                }
                Test-TargetResource @params | Should -BeFalse
            }
        }
    }
}

Describe 'DSC_DnsServerADZone\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        $testZoneName = 'example.com'
        $testDynamicUpdate = 'Secure'
        $testReplicationScope = 'Domain'
        $testComputerName = 'dnsserver.local'
        $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force)
        $testDirectoryPartitionName = "DomainDnsZones.$testZoneName"

        $fakePresentTargetResource = @{
            Name                   = $testZoneName
            DynamicUpdate          = $testDynamicUpdate
            ReplicationScope       = $testReplicationScope
            DirectoryPartitionName = $testDirectoryPartitionName
            Ensure                 = 'Present'
        }
        $fakeAbsentTargetResource = @{ Ensure = 'Absent' }

        Mock -CommandName Assert-Module
    }

    Context 'When DNS zone does not exist and "Ensure" = "Present"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakeAbsentTargetResource }
            Mock -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName }
        }

        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Domain'
                    DynamicUpdate    = 'Secure'
                    Verbose          = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName } -Scope It -Times 1 -Exactly
        }
    }

    Context 'When DNS zone does not exist and "Ensure" = "Present" and "ReplicationScope is Custom"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakeAbsentTargetResource }
            Mock -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName }
        }

        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name                   = 'example.com'
                    Ensure                 = 'Present'
                    ReplicationScope       = 'Custom'
                    DirectoryPartitionName = 'DomainDnsZones.example.com'
                    Verbose                = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName } -Scope It -Times 1 -Exactly
        }
    }

    Context 'When DNS zone does exist and "Ensure" = "Absent"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
            Mock -CommandName Remove-DnsServerZone
        }

        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Absent'
                    ReplicationScope = 'Domain'
                    DynamicUpdate    = 'Secure'
                    Verbose          = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName Remove-DnsServerZone -Scope It -Times 1 -Exactly
        }
    }

    Context 'When DNS zone "DynamicUpdate" is incorrect' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
            Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonSecureAndSecure' }
        }

        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Domain'
                    DynamicUpdate    = 'NonSecureAndSecure'
                    Verbose          = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonSecureAndSecure' } -Scope It -Times 1 -Exactly
        }
    }

    Context 'When DNS zone "ReplicationScope" is incorrect' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
            Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ReplicationScope -eq 'Forest' }
        }

        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Forest'
                    Verbose          = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ReplicationScope -eq 'Forest' } -Scope It -Times 1 -Exactly
        }
    }

    Context 'When DNS zone "DirectoryPartitionName" is incorrect' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
            Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DirectoryPartitionName -eq 'IncorrectDirectoryPartitionName' }
        }

        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name                   = 'example.com'
                    Ensure                 = 'Present'
                    ReplicationScope       = 'Custom'
                    DirectoryPartitionName = 'IncorrectDirectoryPartitionName'
                    Verbose                = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DirectoryPartitionName -eq 'IncorrectDirectoryPartitionName' } -Scope It
        }
    }

    Context 'When DirectoryPartitionName is specified and ReplicationScope is not "Custom"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakeAbsentTargetResource }
            Mock -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName }
        }

        It 'Should throw the correct exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockErrorMessage = $script:LocalizedData.DirectoryPartitionReplicationScopeError
                $params = @{
                    Name                   = 'example.com'
                    Ensure                 = 'Present'
                    ReplicationScope       = 'Domain'
                    DirectoryPartitionName = 'DirectoryPartitionName'
                    Verbose                = $false
                }

                { Set-TargetResource @params } | Should -Throw -ExpectedMessage ($mockErrorMessage + '*')
            }
        }
    }

    Context 'When DirectoryPartitionName is changed and ReplicationScope is not "Custom"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
            Mock -CommandName Set-DnsServerPrimaryZone
        }

        It 'Should throw the correct exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockErrorMessage = $script:LocalizedData.DirectoryPartitionReplicationScopeError
                $params = @{
                    Name                   = 'example.com'
                    Ensure                 = 'Present'
                    ReplicationScope       = 'Domain'
                    DirectoryPartitionName = 'IncorrectDirectoryPartitionName'
                    Verbose                = $false
                }

                { Set-TargetResource @params } | Should -Throw -ExpectedMessage ($mockErrorMessage + '*')
            }
        }
    }

    Context 'When DirectoryPartitionName is changed and ReplicationScope is "Custom"' {
        BeforeAll {
            $fakePresentTargetResourceCustom = $fakePresentTargetResource.Clone()
            $fakePresentTargetResourceCustom.ReplicationScope = 'Custom'

            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResourceCustom }
            Mock -CommandName Set-DnsServerPrimaryZone
        }

        It 'Should not throw' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name                   = 'example.com'
                    Ensure                 = 'Present'
                    ReplicationScope       = 'Custom'
                    DirectoryPartitionName = 'IncorrectDirectoryPartitionName'
                    Verbose                = $false
                }

                { Set-TargetResource @params } | Should -Not -Throw
            }
        }

        It 'Should call the expected mocks' {
            Should -Invoke -CommandName Set-DnsServerPrimaryZone `
                -ParameterFilter { $DirectoryPartitionName -eq 'IncorrectDirectoryPartitionName' } `
                -Scope Context
        }
    }

    Context 'When "Ensure" = "Present" and DNS zone does not exist and DirectoryPartitionName is set and ReplicationScope is not "Custom"' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith { return $fakeAbsentTargetResource }
            Mock -CommandName Set-DnsServerPrimaryZone
        }

        It 'Should throw the correct exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockErrorMessage = $script:LocalizedData.DirectoryPartitionReplicationScopeError
                $params = @{
                    Name                   = 'example.com'
                    Ensure                 = 'Present'
                    ReplicationScope       = 'Domain'
                    DirectoryPartitionName = 'IncorrectDirectoryPartitionName'
                    Verbose                = $false
                }

                { Set-TargetResource @params } | Should -Throw -ExpectedMessage ($mockErrorMessage + '*')
            }
        }
    }

    Context 'When a computer name is not passed' {
        BeforeAll {
            Mock -CommandName New-CimSession
            Mock -CommandName Remove-CimSession
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
            Mock -CommandName Set-DnsServerPrimaryZone
        }

        It 'Should call expected mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    Ensure           = 'Present'
                    ReplicationScope = 'Domain'
                    Verbose          = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName New-CimSession -Scope It -Times 0 -Exactly
            Should -Invoke -CommandName Remove-CimSession -Scope It -Times 0 -Exactly
            Should -Invoke -CommandName Set-DnsServerPrimaryZone -Scope It -Times 1 -Exactly
            Should -Invoke -CommandName Get-TargetResource -Scope It -Times 1 -Exactly
        }
    }

    Context 'When a computer name is passed' {
        BeforeAll {
            Mock -CommandName New-CimSession -MockWith { New-MockObject -Type Microsoft.Management.Infrastructure.CimSession }
            Mock -CommandName Remove-CimSession
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
            Mock -CommandName Set-DnsServerPrimaryZone
        }

        It 'Should call expected mocks' {
            InModuleScope -Parameters @{
                testComputerName = $testComputerName
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    ComputerName     = $testComputerName
                    Verbose          = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName New-CimSession -ParameterFilter { $computername -eq $testComputerName } -Scope It -Times 1 -Exactly
            Should -Invoke -CommandName Remove-CimSession -Scope It -Times 1 -Exactly
        }
    }

    Context 'When credentials are passed' {
        BeforeAll {
            Mock -CommandName New-CimSession -MockWith { New-MockObject -Type Microsoft.Management.Infrastructure.CimSession }
            Mock -CommandName Remove-CimSession
            Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource }
            Mock -CommandName Set-DnsServerPrimaryZone
        }

        It 'Should call expected mocks' {
            InModuleScope -Parameters @{
                testComputerName = $testComputerName
                testCredential   = $testCredential
            } -ScriptBlock {
                Set-StrictMode -Version 1.0

                $params = @{
                    Name             = 'example.com'
                    ReplicationScope = 'Domain'
                    ComputerName     = $testComputerName
                    Credential       = $testCredential
                    Verbose          = $false
                }
                Set-TargetResource @params
            }

            Should -Invoke -CommandName New-CimSession -ParameterFilter {
                $computername -eq $testComputerName -and $credential -eq $testCredential
            } -Scope It -Times 1 -Exactly
            Should -Invoke -CommandName Remove-CimSession -Scope It -Times 1 -Exactly
        }
    }
}
