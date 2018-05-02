@{
# Version number of this module.
moduleVersion = '1.10.0.0'

# ID used to uniquely identify this module
GUID = '5f70e6a1-f1b2-4ba0-8276-8967d43a7ec2'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2014 Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module with DSC Resources for DNS Server area'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PowerShell/xDnsServer/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShell/xDnsServer'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '* Changes to xDnsServerADZone
  * Fixed bug introduced by [49](https://github.com/PowerShell/xDnsServer/pull/49). Previously, CimSessions were always used
  regardless of connecting to a remote machine or the local machine.  Now CimSessions are only utilized when a computername or
  computername and credential are used. ([issue 53](https://github.com/PowerShell/xDnsServer/issues/53)).
  [Michael Fyffe (@TraGicCode)](https://github.com/TraGicCode)
* Fixed all PSSA rule warnings. [Michael Fyffe (@TraGicCode)](https://github.com/TraGicCode)
* Fix DsAvailable key missing ([66](https://github.com/PowerShell/xDnsServer/issues/66)).
  [Claudio Spizzi (@claudiospizzi)](https://github.com/claudiospizzi)

'

    } # End of PSData hashtable

} # End of PrivateData hashtable
}






