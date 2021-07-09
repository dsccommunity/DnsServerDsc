# Welcome to the DnsServerDsc wiki

<sup>*DnsServerDsc v#.#.#*</sup>

Here you will find all the information you need to make use of the DnsServerDsc
DSC resources in the latest release. This includes details of the resources
that are available, current capabilities, known issues, and information to
help plan a DSC based implementation of DnsServerDsc.

Please leave comments, feature requests, and bug reports for this module in
the [issues section](https://github.com/dsccommunity/DnsServerDsc/issues)
for this repository.

## Deprecated resources

The documentation, examples, unit test, and integration tests have been removed
for these deprecated resources. These resources will be removed
in a future release.

### DnsServerDsc

- No deprecated resource at this time

### xDnsServer

The entire module xDnsServer has been deprecated. Please move to DnsServerDsc.

## Getting started

To get started either:

- Install from the PowerShell Gallery using PowerShellGet by running the
  following command:

```powershell
Install-Module -Name DnsServerDsc -Repository PSGallery
```

- Download DnsServerDsc from the [PowerShell Gallery](https://www.powershellgallery.com/packages/DnsServerDsc)
  and then unzip it to one of your PowerShell modules folders (such as
  `$env:ProgramFiles\WindowsPowerShell\Modules`).

To confirm installation, run the below command and ensure you see the DnsServerDsc
DSC resources available:

```powershell
Get-DscResource -Module DnsServerDsc
```

## Prerequisites

The minimum Windows Management Framework (PowerShell) version required is 5.0
or higher, which ships with Windows 10 or Windows Server 2016,
but can also be installed on Windows 7 SP1, Windows 8.1, Windows Server 2012,
and Windows Server 2012 R2.

To use the DSC resources in the module DnsServerDsc the _Microsoft DNS Server_
need to be installed on the node the resource is configured to target. The
_Microsoft DNS Server_ role can be installed in various ways, but one way
is through DSC.

```powershell
WindowsFeature InstallDNS
{
    Ensure = 'Present'
    Name   = 'DNS'
}
```

The DSC resources requires the [DnsServer](https://docs.microsoft.com/en-us/powershell/module/dnsserver)
PowerShell module that is either installed by installing the _Microsoft DNS Server_
role like above, or by just adding the DNS Server Tools part of Remote Server
Administration Tools (RSAT) feature if the target node configures a remote
_Microsoft DNS Server_.

```powershell
WindowsFeature InstallDNSTools
{
    Ensure = 'Present'
    Name   = 'RSAT-DNS-Server'
}
```

## Change log

A full list of changes in each version can be found in the [change log](https://github.com/dsccommunity/DnsServerDsc/blob/main/CHANGELOG.md).
