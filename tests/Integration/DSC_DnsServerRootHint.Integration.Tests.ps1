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
    $script:dscResourceFriendlyName = 'DnsServerRootHint'
    $script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

    # Ensure that the tests can be performed on this computer
    $script:skipIntegrationTests = $false
}

BeforeAll {
    $script:dscModuleName = 'DnsServerDsc'
    $script:dscResourceFriendlyName = 'DnsServerRootHint'
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
        "$($script:dscResourceName)_RemoveAllRootHints_Config"
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
            $resourceCurrentState.NameServer       | Should -BeNullOrEmpty
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    Context ('When using configuration <_>') -ForEach @(
        "$($script:dscResourceName)_SetRootHints_Config"
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

            $nameServerHashtable = @{}

            foreach ($nameServer in $resourceCurrentState.NameServer)
            {
                $nameServerHashtable.Add($nameServer.Key, $nameServer.Value)
            }

            $nameServerHashtable.Count | Should -Be $ConfigurationData.AllNodes.NameServer.Count

            $resourceCurrentState.IsSingleInstance | Should -Be 'Yes'

            $nameServerHashtable['H.ROOT-SERVERS.NET.'] | Should -Be '198.97.190.53'
            $nameServerHashtable['E.ROOT-SERVERS.NET.'] | Should -Be '192.203.230.10'
            $nameServerHashtable['M.ROOT-SERVERS.NET.'] | Should -Be '202.12.27.33'
            $nameServerHashtable['A.ROOT-SERVERS.NET.'] | Should -Be '198.41.0.4'
            $nameServerHashtable['D.ROOT-SERVERS.NET.'] | Should -Be '199.7.91.13'
            $nameServerHashtable['F.ROOT-SERVERS.NET.'] | Should -Be '192.5.5.241'
            $nameServerHashtable['B.ROOT-SERVERS.NET.'] | Should -Be '192.228.79.201'
            $nameServerHashtable['G.ROOT-SERVERS.NET.'] | Should -Be '192.112.36.4'
            $nameServerHashtable['C.ROOT-SERVERS.NET.'] | Should -Be '192.33.4.12'
            $nameServerHashtable['K.ROOT-SERVERS.NET.'] | Should -Be '193.0.14.129'
            $nameServerHashtable['I.ROOT-SERVERS.NET.'] | Should -Be '192.36.148.17'
            $nameServerHashtable['J.ROOT-SERVERS.NET.'] | Should -Be '192.58.128.30'
            $nameServerHashtable['L.ROOT-SERVERS.NET.'] | Should -Be '199.7.83.42'
        }

        It 'Should return ''True'' when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }
}
