$script:dscModuleName   = 'xDnsServer'
$script:dscResourceFriendlyName = 'xDnsServerDiagnostics'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

try
{
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }

        $configurationName = "$($script:dscResourceName)_SetDiagnostics_Config"

        Context ('When using configuration {0}' -f $configurationName) {
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

                $resourceCurrentState.DnsServer                            | Should -Be $ConfigurationData.AllNodes.DnsServer
                $resourceCurrentState.Answers                              | Should -Be $ConfigurationData.AllNodes.Answers
                $resourceCurrentState.EnableLogFileRollover                | Should -Be $ConfigurationData.AllNodes.EnableLogFileRollover
                $resourceCurrentState.EnableLoggingForLocalLookupEvent     | Should -Be $ConfigurationData.AllNodes.EnableLoggingForLocalLookupEvent
                $resourceCurrentState.EnableLoggingForPluginDllEvent       | Should -Be $ConfigurationData.AllNodes.EnableLoggingForPluginDllEvent
                $resourceCurrentState.EnableLoggingForRecursiveLookupEvent | Should -Be $ConfigurationData.AllNodes.EnableLoggingForRecursiveLookupEvent
                $resourceCurrentState.EnableLoggingForRemoteServerEvent    | Should -Be $ConfigurationData.AllNodes.EnableLoggingForRemoteServerEvent
                $resourceCurrentState.EnableLoggingForServerStartStopEvent | Should -Be $ConfigurationData.AllNodes.EnableLoggingForServerStartStopEvent
                $resourceCurrentState.EnableLoggingForTombstoneEvent       | Should -Be $ConfigurationData.AllNodes.EnableLoggingForTombstoneEvent
                $resourceCurrentState.EnableLoggingForZoneDataWriteEvent   | Should -Be $ConfigurationData.AllNodes.EnableLoggingForZoneDataWriteEvent
                $resourceCurrentState.EnableLoggingForZoneLoadingEvent     | Should -Be $ConfigurationData.AllNodes.EnableLoggingForZoneLoadingEvent
                $resourceCurrentState.EnableLoggingToFile                  | Should -Be $ConfigurationData.AllNodes.EnableLoggingToFile
                $resourceCurrentState.EventLogLevel                        | Should -Be $ConfigurationData.AllNodes.EventLogLevel
                $resourceCurrentState.FilterIPAddressList                  | Should -Be $ConfigurationData.AllNodes.FilterIPAddressList
                $resourceCurrentState.FullPackets                          | Should -Be $ConfigurationData.AllNodes.FullPackets
                $resourceCurrentState.LogFilePath                          | Should -Be $ConfigurationData.AllNodes.LogFilePath
                $resourceCurrentState.MaxMBFileSize                        | Should -Be $ConfigurationData.AllNodes.MaxMBFileSize
                $resourceCurrentState.Notifications                        | Should -Be $ConfigurationData.AllNodes.Notifications
                $resourceCurrentState.Queries                              | Should -Be $ConfigurationData.AllNodes.Queries
                $resourceCurrentState.QuestionTransactions                 | Should -Be $ConfigurationData.AllNodes.QuestionTransactions
                $resourceCurrentState.ReceivePackets                       | Should -Be $ConfigurationData.AllNodes.ReceivePackets
                $resourceCurrentState.SaveLogsToPersistentStorage          | Should -Be $ConfigurationData.AllNodes.SaveLogsToPersistentStorage
                $resourceCurrentState.SendPackets                          | Should -Be $ConfigurationData.AllNodes.SendPackets
                $resourceCurrentState.TcpPackets                           | Should -Be $ConfigurationData.AllNodes.TcpPackets
                $resourceCurrentState.UdpPackets                           | Should -Be $ConfigurationData.AllNodes.UdpPackets
                $resourceCurrentState.UnmatchedResponse                    | Should -Be $ConfigurationData.AllNodes.UnmatchedResponse
                $resourceCurrentState.Update                               | Should -Be $ConfigurationData.AllNodes.Update
                $resourceCurrentState.UseSystemEventLog                    | Should -Be $ConfigurationData.AllNodes.UseSystemEventLog
                $resourceCurrentState.WriteThrough                         | Should -Be $ConfigurationData.AllNodes.WriteThrough
            }

            It 'Should return ''True'' when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Wait-ForIdleLcm -Clear
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
