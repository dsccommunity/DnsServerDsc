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
- xDnsRecord
  - Added TTL parameter.
- xDNSServerClientSubnet
  - Added integration tests.

### Changed

- xDnsServer
  - Resolve style guideline violations for hashtables

### Removed

- xDnsServer
  - BREAKING CHANGE: The DSC resource xDnsARecord was removed and are replaced
    by the DSC resource xDnsRecord.

### Fixed

- xDnsServer
  - Enable Unit Tests to be run locally.
- xDnsServerDiagnostics
  - Fix EnableLogFileRollover Parameter name in README.
- xDnsRecord
  - Fix "Removing a DNS A Record" example.
