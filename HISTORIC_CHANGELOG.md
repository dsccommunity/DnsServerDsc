# Historic change log for xDnsServer

The release notes in the PowerShell Module manifest cannot exceed 10000
characters. Due to a bug in the CI deploy pipeline this is not handled.
This file is to temporary move the older change log history to keep the
change log short.

## [1.16.0.0] - 2019-10-30

- Changes to xDnsServerADZone
  - Raise an exception if `DirectoryPartitionName` is specified and
    `ReplicationScope` is not `Custom`. ([issue #110](https://github.com/dsccommunity/xDnsServer/issues/110)).
  - Enforce the `ReplicationScope` parameter being passed to `Set-DnsServerPrimaryZone`
    if `DirectoryPartitionName` has changed.
- xDnsServer:
  - OptIn to the following Dsc Resource Meta Tests:
    - Common Tests - Relative Path Length
    - Common Tests - Validate Markdown Links
    - Common Tests - Custom Script Analyzer Rules
    - Common Tests - Required Script Analyzer Rules
    - Common Tests - Flagged Script Analyzer Rules

## [1.15.0.0] - 2019-09-18

- Fixed: Ignore UseRootHint in xDnsServerForwarder test function if it was not
  specified in the resource [Claudio Spizzi (@claudiospizzi)](https://github.com/claudiospizzi)

## [1.14.0.0] - 2019-08-07

- Copied enhancements to Test-DscParameterState from NetworkingDsc
- Put the helper module to its own folder
- Copied enhancements to Test-DscParameterState from NetworkingDsc
- Put the helper module to its own folder
- Added xDnsServerRootHint resource
- Added xDnsServerClientSubnet resource
- Added xDnsServerZoneScope resource

## [1.13.0.0] - 2019-06-26

- Added resource xDnsServerConditionalForwarder
- Added xDnsServerDiagnostics resource to this module.

## [1.12.0.0] - 2019-05-15

- Update appveyor.yml to use the default template.
- Added default template files .codecov.yml, .gitattributes, and .gitignore,
  and .vscode folder.
- Added UseRootHint property to xDnsServerForwarder resource.

## [1.11.0.0] - 2018-06-13

- Changes to xDnsServer
  - Updated appveyor.yml to use the default template and add CodeCov support
    ([issue #73](https://github.com/PowerShell/xActiveDirectory/issues/73)).
  - Adding a Branches section to the README.md with Codecov badges for both
    master and dev branch ([issue #73](https://github.com/PowerShell/xActiveDirectory/issues/73)).
  - Updated description of resource module in README.md.
- Added resource xDnsServerZoneAging. [Claudio Spizzi (@claudiospizzi)](https://github.com/claudiospizzi)
- Changes to xDnsServerPrimaryZone
  - Fix bug in Get-TargetResource that caused the Zone Name to be null
    ([issue #63](https://github.com/dsccommunity/xDnsServer/issues/63)).
    [Brandon Padgett (@gerane)](https://github.com/gerane)
- Changes to xDnsRecord
  - Added Ptr record support (partly resolves issue #34).
    [Reggie Gibson (@regedit32)](https://github.com/regedit32)

## [1.10.0.0] - 2018-05-02

- Changes to xDnsServerADZone
  - Fixed bug introduced by [PR #49](https://github.com/dsccommunity/xDnsServer/pull/49).
    Previously, CimSessions were always used regardless of connecting to a
    remote machine or the local machine.  Now CimSessions are only utilized
    when a computername, or computername and credential are used ([issue #53](https://github.com/dsccommunity/xDnsServer/issues/53)).
  [Michael Fyffe (@TraGicCode)](https://github.com/TraGicCode)
- Fixed all PSSA rule warnings. [Michael Fyffe (@TraGicCode)](https://github.com/TraGicCode)
- Fix DsAvailable key missing ([#66](https://github.com/dsccommunity/xDnsServer/issues/66)).
  [Claudio Spizzi (@claudiospizzi)](https://github.com/claudiospizzi)

## [1.9.0.0] - 2017-11-15

- Added resource xDnsServerSetting
- MSFT_xDnsRecord: Added DnsServer property

## [1.8.0.0] - 2017-08-23

- Converted AppVeyor.yml to pull Pester from PSGallery instead of Chocolatey
- Fixed bug in xDnsServerADZone causing Get-TargetResource to fail with an
  extra property.

## [1.7.0.0] - 2016-05-18

- Unit tests updated to use standard unit test templates.
- MSFT_xDnsServerZoneTransfer
  - Added unit tests.
  - Updated to meet Style Guidelines.
- MSFT_xDnsARecord: Removed hard coding of Localhost computer name to
  eliminate PSSA rule violation.

## [1.6.0.0] - 2016-03-30

- Added Resource xDnsServerForwarder.
- Updated README.md with documentation and examples for xDnsServerForwarder
  resource.
- Added Resource xDnsServerADZone that sets an AD integrated DNS zone.
- Updated README.md with documentation and examples for xDnsServerADZone
  resource.
- Fixed bug in xDnsRecord causing Test-TargetResource to fail with multiple
  (round-robin) entries.
- Updated README.md with example DNS round-robin configuration.

## [1.5.0.0] - 2016-02-02

- Added Resource xDnsRecord with support for CNames.
  - This will replace xDnsARecord in a future release.
- Added **xDnsServerPrimaryZone** resource

## [1.4.0.0] - 2015-12-02

- Added support for removing DNS A records

## [1.3.0.0] - 2015-10-22

- Fix to retrieving settings for record data

## [1.2.0.0] - 2015-09-11

- Removed UTF8 BOM from MOF schema

## [1.1.0.0] - 2015-05-01

- Add **xDnsARecord** resource.

## [1.0.0.0] - 2015-04-17

- Initial release with the following resources
  - **xDnsServerSecondaryZone**
  - **xDnsServerZoneTransfer**
