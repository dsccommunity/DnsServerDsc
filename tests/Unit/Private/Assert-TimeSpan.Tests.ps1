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
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
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

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Assert-TimeSpan' -Tag 'Private' {
    Context 'When asserting a valid time' {
        Context 'When passing value with named parameter' {
            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { Assert-TimeSpan -PropertyName 'MyProperty' -Value '1.00:00:00' } | Should -Not -Throw
                }
            }
        }

        Context 'When passing value in pipeline' {
            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    { '1.00:00:00' | Assert-TimeSpan -PropertyName 'MyProperty' } | Should -Not -Throw
                }
            }
        }
    }

    Context 'When asserting a invalid string' {
        It 'Should throw the correct error message' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'MyProperty', 'a.00:00:00'

                { 'a.00:00:00' | Assert-TimeSpan -PropertyName 'MyProperty' } | Should -Throw -ExpectedMessage ('*' + $mockErrorMessage)
            }
        }
    }

    Context 'When time is above maximum allowed value' {
        It 'Should throw the correct error message' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockErrorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f 'MyProperty', '1.00:00:00', '00:30:00'

                { '1.00:00:00' | Assert-TimeSpan -PropertyName 'MyProperty' -Maximum '0.00:30:00' } | Should -Throw -ExpectedMessage ('*' + $mockErrorMessage)
            }
        }
    }

    Context 'When time is below minimum allowed value' {
        It 'Should throw the correct error message' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $mockErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'MyProperty', '1.00:00:00', '2.00:00:00'

                { '1.00:00:00' | Assert-TimeSpan -PropertyName 'MyProperty' -Minimum '2.00:00:00' } | Should -Throw -ExpectedMessage ('*' + $mockErrorMessage)
            }
        }
    }
}
