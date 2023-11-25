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
    Describe 'DnsServerDsc.Common\ConvertTo-FollowRfc1034' {
        BeforeAll {
            $hostname = 'mail.contoso.com'
            $convertedHostname = 'mail.contoso.com.'
        }

        Context 'The hostname is not converted' {
            It 'Should not throw exception' {
                { $script:result = $hostname | ConvertTo-FollowRfc1034 -Verbose } | Should -Not -Throw
            }

            It 'Should end in a .' {
                $script:result | Should -Be "$hostname."
            }
        }

        Context 'The hostname is already converted' {
            It 'Should return the same as the input string' {
                $convertedHostname | ConvertTo-FollowRfc1034 -Verbose | Should -Be $convertedHostname
            }
        }
    }

    Describe 'Convert-RootHintsToHashtable' {
        BeforeAll {
            $emptyRootHints = @()
            $rootHintWithoutIP = @(
                @{
                    NameServer = @{
                        RecordData = @{
                            NameServer = 'ns1'
                        }
                    }
                    IPAddress = $null
                }
            )
            $rootHintWithIPv4 = @(
                @{
                    NameServer = @{
                        RecordData = @{
                            NameServer = 'ns2'
                        }
                    }
                    IPAddress = @{
                        RecordData = @{
                            IPv6Address = @{
                                IPAddressToString = '192.0.2.1'
                            }
                        }
                    }
                }
            )
            $rootHintWithIPv6 = @(
                @{
                    NameServer = @{
                        RecordData = @{
                            NameServer = 'ns3'
                        }
                    }
                    IPAddress = @{
                        RecordData = @{
                            IPv6Address = @{
                                IPAddressToString = '2001:db8::1'
                            }
                        }
                    }
                }
            )
        }

        It 'Returns an empty hashtable when the input array is empty' {
            $result = Convert-RootHintsToHashtable -RootHints $emptyRootHints
            $result.Count | Should -Be 0
        }

        It 'Correctly skips elements without an IPAddress' {
            $result = Convert-RootHintsToHashtable -RootHints $rootHintWithoutIP
            $result.Count | Should -Be 0
        }

        It 'Correctly handles elements with an IPv4 address' {
            $result = Convert-RootHintsToHashtable -RootHints $rootHintWithIPv4
            $result.Count | Should -Be 1
            $result.ns2 | Should -Be '192.0.2.1'
        }

        It 'Correctly handles elements with an IPv6 address' {
            $result = Convert-RootHintsToHashtable -RootHints $rootHintWithIPv6
            $result.Count | Should -Be 1
            $result.ns3 | Should -Be '2001:db8::1'
        }
    }
}
