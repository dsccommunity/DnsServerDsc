$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop }catch{$false}) }
    ).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {

    Describe 'Helper function ConvertTo-HashtableFromObject' -Tag 'Private' {
        BeforeAll {
            $script:mockItemName = 'contoso.com'
            $script:mockItem     = [pscustomobject]@{
                Name                       = $script:mockItemName
                ZoneName          = 'contoso.com'
                SymbolicName      = 'xmpp'
            }
        }

        BeforeEach{
            $script:instanceDesiredState = [DnsRecordSrv]::new()
            $script:instanceDesiredState.ZoneName = $script:mockItemName
            $script:instanceDesiredState.Ensure = [Ensure]::Present
        }

        Context 'When instance of class is convert to hashtable' {
            BeforeEach {

            }
            It 'Should not Throw' {
                {$script:convertHashtable = $script:instanceDesiredState | ConvertTo-HashtableFromObject} | Should -Not -Throw
            }

            It 'Should be a Hashtable' {
                $script:convertHashtable | Should -BeOfType [hashtable]
            }

            It 'Should have the same count of properties' {
                $script:convertHashtable.keys.count | Should -Be $script:instanceDesiredState.psobject.Properties.Name.count
            }
            It 'Should be the same value of key' {
                $script:instanceDesiredState.psobject.Properties.Name | ForEach-Object {
                    $script:convertHashtable.ContainsKey($_) | Should -BeTrue
                    $script:convertHashtable.$_ | Should -Be $instanceDesiredState.$_
                }
            }
        }
    }
}
