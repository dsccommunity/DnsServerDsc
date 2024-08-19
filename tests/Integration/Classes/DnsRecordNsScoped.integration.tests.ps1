# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
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
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }

    <#
        Need to define that variables here to be used in the Pester Discover to
        build the ForEach-blocks.
    #>
    $script:dscModuleName = 'DnsServerDsc'
    $script:dscResourceName = 'DnsRecordNsScoped'

    # Ensure that the tests can be performed on this computer
    $script:skipIntegrationTests = $false
}

BeforeAll {
    $script:dscModuleName = 'DnsServerDsc'
    $script:dscResourceName = 'DnsRecordNsScoped'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Class' `
        -TestType 'Integration'
}

AfterAll {
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Describe "$($script:dscResourceName)_Integration" {
    BeforeAll {
        $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
        . $configurationFile

        $resourceId = "[$($script:dscResourceName)]Integration_Test"
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_CreateRecord_Config"
    ) {
        BeforeAll {
            $configurationName = $_
        }

        AfterAll {
            Wait-ForIdleLcm -Clear
        }

        It 'Should compile and apply the MOF without throwing' {
            {
                $configurationParameters = @{
                    OutputPath        = $TestDrive
                    ConfigurationData = $ConfigurationData
                }

                & $configurationName @configurationParameters

                $startDscConfigurationParameters = @{
                    Path         = $TestDrive
                    ComputerName = 'localhost'
                    Wait         = $true
                    Verbose      = $true
                    Force        = $true
                    ErrorAction  = 'Stop'
                }

                Start-DscConfiguration @startDscConfigurationParameters
            } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
            }

            $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

            # Key properties
            $resourceCurrentState.ZoneName | Should -Be $shouldBeData.ZoneName
            $resourceCurrentState.ZoneScope | Should -Be $shouldBeData.ZoneScope
            $resourceCurrentState.DomainName | Should -Be $shouldBeData.DomainName
            $resourceCurrentState.NameServer | Should -Be $shouldBeData.NameServer

            # Optional properties were not specified, so we just need to ensure the value exists
            $resourceCurrentState.TimeToLive | Should -Not -Be $null

            # Defaulted properties
            $resourceCurrentState.DnsServer | Should -Be 'localhost'
            $resourceCurrentState.Ensure | Should -Be 'Present'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_ModifyRecord_Config"
    ) {
        BeforeAll {
            $configurationName = $_
        }

        AfterAll {
            Wait-ForIdleLcm -Clear
        }

        It 'Should compile and apply the MOF without throwing' {
            {
                $configurationParameters = @{
                    OutputPath        = $TestDrive
                    ConfigurationData = $ConfigurationData
                }

                & $configurationName @configurationParameters

                $startDscConfigurationParameters = @{
                    Path         = $TestDrive
                    ComputerName = 'localhost'
                    Wait         = $true
                    Verbose      = $true
                    Force        = $true
                    ErrorAction  = 'Stop'
                }

                Start-DscConfiguration @startDscConfigurationParameters
            } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
            }

            $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

            # Key properties
            $resourceCurrentState.ZoneName | Should -Be $shouldBeData.ZoneName
            $resourceCurrentState.ZoneScope | Should -Be $shouldBeData.ZoneScope
            $resourceCurrentState.DomainName | Should -Be $shouldBeData.DomainName
            $resourceCurrentState.NameServer | Should -Be $shouldBeData.NameServer

            # Optional properties
            $resourceCurrentState.TimeToLive | Should -Be $shouldBeData.TimeToLive

            # Defaulted properties
            $resourceCurrentState.DnsServer | Should -Be $shouldBeData.DnsServer
            $resourceCurrentState.Ensure | Should -Be $shouldBeData.Ensure
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_DeleteRecord_Config"
    ) {
        BeforeAll {
            $configurationName = $_
        }

        AfterAll {
            Wait-ForIdleLcm -Clear
        }

        It 'Should compile and apply the MOF without throwing' {
            {
                $configurationParameters = @{
                    OutputPath        = $TestDrive
                    ConfigurationData = $ConfigurationData
                }

                & $configurationName @configurationParameters

                $startDscConfigurationParameters = @{
                    Path         = $TestDrive
                    ComputerName = 'localhost'
                    Wait         = $true
                    Verbose      = $true
                    Force        = $true
                    ErrorAction  = 'Stop'
                }

                Start-DscConfiguration @startDscConfigurationParameters
            } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
            }

            $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

            # Key properties
            $resourceCurrentState.ZoneName | Should -Be $shouldBeData.ZoneName
            $resourceCurrentState.ZoneScope | Should -Be $shouldBeData.ZoneScope
            $resourceCurrentState.DomainName | Should -Be $shouldBeData.DomainName
            $resourceCurrentState.NameServer | Should -Be $shouldBeData.NameServer

            # Optional properties
            if ($shouldBeData.TimeToLive)
            {
                $resourceCurrentState.TimeToLive | Should -Be $shouldBeData.TimeToLive
            }

            # DnsServer is not specified in this test, so it defaults to 'localhost'
            $resourceCurrentState.DnsServer | Should -Be 'localhost'

            # Ensure will be Absent
            $resourceCurrentState.Ensure | Should -Be 'Absent'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }
}
