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
    $script:dscResourceFriendlyName = 'DnsServerForwarder'
    $script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

    # Ensure that the tests can be performed on this computer
    $script:skipIntegrationTests = $false
}

BeforeAll {
    $script:dscModuleName = 'DnsServerDsc'
    $script:dscResourceFriendlyName = 'DnsServerForwarder'
    $script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Integration'
}

AfterAll {
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Describe "$($script:dscResourceName)_Integration" {
    BeforeAll {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
        . $configFile

        $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_SetForwarderDoNotUseRootHints_Config"
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
                $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
            }

            $resourceCurrentState.IsSingleInstance | Should -Be 'Yes'
            $resourceCurrentState.IPAddresses      | Should -Be $ConfigurationData.AllNodes.ForwarderIpAddress
            $resourceCurrentState.UseRootHint      | Should -BeFalse
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_SetForwarderUseRootHints_Config"
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
                $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
            }

            $resourceCurrentState.IsSingleInstance | Should -Be 'Yes'
            $resourceCurrentState.IPAddresses      | Should -Be $ConfigurationData.AllNodes.ForwarderIpAddress
            $resourceCurrentState.UseRootHint      | Should -BeTrue
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_RemoveForwarders_Config"
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
                $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
            }

            $resourceCurrentState.IsSingleInstance | Should -Be 'Yes'
            $resourceCurrentState.IPAddresses      | Should -BeNullOrEmpty
            $resourceCurrentState.UseRootHint      | Should -BeFalse
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_SetUseRootHint_Config"
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
                $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
            }

            $resourceCurrentState.IsSingleInstance | Should -Be 'Yes'
            $resourceCurrentState.IPAddresses      | Should -BeNullOrEmpty
            $resourceCurrentState.UseRootHint      | Should -BeTrue
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_SetEnableReordering_Config"
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
                $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
            }

            $resourceCurrentState.IsSingleInstance | Should -Be 'Yes'
            $resourceCurrentState.IPAddresses      | Should -BeNullOrEmpty
            $resourceCurrentState.EnableReordering | Should -BeTrue
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_SetDisableReordering_Config"
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
                $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
            }

            $resourceCurrentState.IsSingleInstance | Should -Be 'Yes'
            $resourceCurrentState.IPAddresses      | Should -BeNullOrEmpty
            $resourceCurrentState.EnableReordering | Should -BeFalse
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_SetTimeout_Config"
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
                $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
            }

            $resourceCurrentState.IsSingleInstance | Should -Be 'Yes'
            $resourceCurrentState.IPAddresses      | Should -BeNullOrEmpty
            $resourceCurrentState.Timeout          | Should -Be 10
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }
}
