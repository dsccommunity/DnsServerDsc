# Change log for xDnsServer

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For older change log history see the [historic changelog](HISTORIC_CHANGELOG.md).

## [Unreleased]

### Added

- xDnsServer
  - Added automatic release with a new CI pipeline.
  - Add unit tests for the Get-LocalizedData, NewTerminatingError, and
    Assert-Module helper functions.
  - Added description README files for each resource.
  - Add example files for resources
  - OptIn to the following Dsc Resource Meta Tests:
    - Common Tests - Validate Localization
    - Common Tests - Validate Example Files To Be Published
  - Standardize Resource Localization.
  - Added the build taks to publish content to the GitHub wiki repository.
- xDNSServerClientSubnet
  - Added integration tests.
- xDnsRecordSrv
  - Added new resource to manage SRV records

### Changed

- xDnsServer
  - Resolve style guideline violations for hashtables
  - Update pipeline files.
  - Renamed the default branch to `main` ([issue #131](https://github.com/dsccommunity/xDnsServer/issues/131)).
  - Uses `PublishPipelineArtifact` in pipeline.

### Removed

- xDnsServer
  - BREAKING CHANGE: The DSC resource xDnsARecord was removed and are replaced
    by the DSC resource xDnsRecord.
  - Removing resource parameter information from README.md in favor of
    GitHub repository wiki.

### Fixed

- xDnsServer
  - Enable Unit Tests to be run locally.
  - Rename integration tests so they are run in the pipeline ([issue #134](https://github.com/dsccommunity/xDnsServer/issues/134)).
  - Added back the build task to create releases on GitHub.
  - Fix property descriptions in schema throughout.
- xDnsServerDiagnostics
  - Fix EnableLogFileRollover Parameter name in README.
- xDnsRecord
  - Fix "Removing a DNS A Record" example.
- xDnsServerDiagnostics
  - Fixed typo in parameter `EnableLogFileRollover`.
  - Updated integration test to correct template.
- xDnsServerSettings
  - Updated integration test to correct template.
- xDnsServerAdZone
  - Now the parameter `ComputerName` can be used without throwing an exception
    ([issue 79](https://github.com/PowerShell/xDnsServer/issues/79)).
