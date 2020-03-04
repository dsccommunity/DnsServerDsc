
$script:dscModuleName   = 'xDnsServer'
$script:dscResourceName = 'MSFT_xDnsServerDiagnostics'

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
    #region Integration Tests
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configFile

    Describe "$($script:dscResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile and apply the MOF without throwing' {
            {
                & "$($script:dscResourceName)_Config" -OutputPath $script:testEnvironment.WorkingFolder
                Start-DscConfiguration -Path $script:testEnvironment.WorkingFolder `
                -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            Import-Module "$PSScriptRoot\..\..\DSCResources\MSFT_xDnsServerSetting\MSFT_xDnsServerDiagnostics.psm1" -Force

            Test-TargetResource @testParameters | Should be $true
        }
    }
    #endregion

}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
