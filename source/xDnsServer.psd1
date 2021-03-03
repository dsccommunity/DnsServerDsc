@{
    # Version number of this module.
    moduleVersion     = '0.0.1'

    # ID used to uniquely identify this module
    GUID              = '5f70e6a1-f1b2-4ba0-8276-8967d43a7ec2'

    # Author of this module
    Author            = 'DSC Community'

    # Company or vendor of this module
    CompanyName       = 'DSC Community'

    # Copyright statement for this module
    Copyright         = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'This module contains DSC resources for the management and configuration of Windows Server DNS Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Script module or binary module file associated with this manifest.
    RootModule = 'xDnsServer.psm1'

    # Functions to export from this module
    FunctionsToExport = @()

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    DscResourcesToExport = @(
        'DnsRecordSrv'
        'DnsRecordSrvScoped'
        'xDnsRecord'
        'xDnsRecordMx'
        'xDnsServerADZone'
        'xDnsServerClientSubnet'
        'xDnsServerConditionalForwarder'
        'xDnsServerDiagnostics'
        'xDnsServerForwarder'
        'xDnsServerPrimaryZone'
        'xDnsServerRootHint'
        'xDnsServerSecondaryZone'
        'xDnsServerSetting'
        'xDnsServerZoneAging'
        'xDnsServerZoneScope'
        'xDnsServerZoneTransfer'
    )

    <#
      Private data to pass to the module specified in RootModule/ModuleToProcess.
      This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    #>
    PrivateData       = @{
        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/xDnsServer/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/xDnsServer'

            # A URL to an icon representing this module.
            IconUri = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = ''
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
