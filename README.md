# xDnsServer

This module contains DSC resources for the management and
configuration of Windows Server DNS Server.

[![Build Status](https://dev.azure.com/dsccommunity/xDnsServer/_apis/build/status/dsccommunity.xDnsServer?branchName=main)](https://dev.azure.com/dsccommunity/xDnsServer/_build/latest?definitionId=23&branchName=main)
![Azure DevOps coverage (branch)](https://img.shields.io/azure-devops/coverage/dsccommunity/xDnsServer/23/main)
[![codecov](https://codecov.io/gh/dsccommunity/xDnsServer/branch/main/graph/badge.svg)](https://codecov.io/gh/dsccommunity/xDnsServer)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/xDnsServer/23/main)](https://dsccommunity.visualstudio.com/xDnsServer/_test/analytics?definitionId=23&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/xDnsServer?label=xDnsServer%20Preview)](https://www.powershellgallery.com/packages/xDnsServer/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/xDnsServer?label=xDnsServer)](https://www.powershellgallery.com/packages/xDnsServer/)

## Code of Conduct

This project has adopted this [Code of Conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `main` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Resources

- **xDnsRecord** This resource allows for the creation of IPv4 host (A)
  records, CNames, or PTRs against a specific zone on the DNS server.
- **xDnsRecordSrv** This resource allows for the creation of SRV records
  against a specific zone on the DNS server.
- **xDnsServerADZone** sets an AD integrated zone on a given DNS server.
- **xDnsServerClientSubnet** This resource manages the DNS Client Subnets
  that are used in DNS Policies.
- **xDnsServerConditionalForwarder** This resource manages a conditional
  forwarder on a given DNS server.
- **xDnsServerDiagnostics** This resource manages the DNS server diagnostic
  settings/properties.
- **xDnsServerForwarder** sets a DNS forwarder on a given DNS server.
- **xDnsServerPrimaryZone** sets a standalone Primary zone on a given
  DNS server.
- **xDnsServerRootHint** This resource manages root hints on a given
  DNS server.
- **xDnsServerSecondaryZone** sets a Secondary zone on a given DNS server.
  - Secondary zones allow client machine in primary DNS zones to do DNS
    resolution of machines in the secondary DNS zone.
- **xDnsServerSetting** This resource manages the DNS sever settings/properties.
- **xDnsServerZoneAging** This resource manages aging settings for a given
  DNS server zone.
- **xDnsServerZoneScope** This resource manages the zone scope on an existing
  zone on the DNS server.
- **xDnsServerZoneTransfer** This resource allows a DNS Server zone data
  to be replicated to another DNS server.

### xDnsRecord

- **Name**: Specifies the name of the DNS server resource record object
- **Zone**: The name of the zone to create the host record in
- **Target**: Target Hostname or IP Address. *Only Supports IPv4 in the*
  *current release*}
- **DnsServer**: Name of the DnsServer to create the record on.
  - If not specified, defaults to 'localhost'.
- **Type**: DNS Record Type.
  - Values include: { ARecord | CName | Ptr }
- **Ensure**: Whether the host record should be present or removed

### xDnsRecordSrv

- **Zone**: The name of the zone in which to create the SRV record
- **SymbolicName**: Service name for the SRV record. eg: xmpp, ldap, etc.
- **Protocol**: Service transmission protocol ('TCP' or 'UDP')
- **Port**: The TCP or UDP port on which the service is found
- **Target**: Target Hostname for the SRV record.
- **Priority**: Specifies the priority of the SRV record.
  - Defaults to 10
- **Weight**: Specifies the weight of the SRV record.
  - Defaults to 20
- **TTL**: Specifies the Time to Live for the SRV record.
  - Defaults to the zone default.
- **DnsServer**: Name of the DnsServer to create the record on.
  - If not specified, defaults to 'localhost'.
- **Ensure**: Whether the host record should be present or removed

### xDnsServerADZone

- **Name**: Name of the AD DNS zone
- **Ensure**: Whether the AD zone should be present or removed
- **DynamicUpdate**: AD zone dynamic DNS update option.
  - If not specified, defaults to 'Secure'.
  - Valid values include: { None | NonSecureAndSecure | Secure }
- **ReplicationScope**: AD zone replication scope option.
  - Valid values include: { Custom | Domain | Forest | Legacy }
- **DirectoryPartitionName**: Name of the directory partition on which to
  store the zone.
  - Use this parameter when the ReplicationScope parameter has a value of
    Custom.
- **ComputerName**: Specifies a DNS server.
  - If you do not specify this parameter, the command runs on the local
    system.
- **Credential**: Specifies the credential to use to create the AD zone
  on a remote computer.
  - This parameter can only be used when you also are passing a value for
    the `ComputerName` parameter.

### xDnsServerClientSubnet

Requires Windows Server 2016 onwards

- **Name**: Specifies the name of the client subnet.
- **IPv4Subnet**: Specify an array (1 or more values) of IPv4 Subnet addresses
  in CIDR Notation.
- **IPv6Subnet**: Specify an array (1 of more values) of IPv6 Subnet addresses
  in CIDR Notation.
- **Ensure**: Whether the client subnet should be present or removed.

### xDnsServerConditionalForwarder

- **Ensure**: Ensure whether the zone is absent or present.
- **Name**: The name of the zone to manage.
- **MasterServers**: The IP addresses the forwarder should use. Mandatory
  if Ensure is present.
- **ReplicationScope**: Whether the conditional forwarder should be replicated
  in AD, and the scope of that replication.
  - Valid values are: { None | Custom | Domain | Forest | Legacy }
  - Default is None.
- **DirectoryPartitionName**: The name of the directory partition to use
  when the ReplicationScope is Custom. This value is ignored for all other
  replication scopes.

### xDnsServerDiagnostics

- **Name**: Key for the resource. It doesn't matter what it is as long as
  it's unique within the configuration.
- **Answers**: Specifies whether to enable the logging of DNS responses.
- **EnableLogFileRollover**: Specifies whether to enable log file rollover.
- **EnableLoggingForLocalLookupEvent**: Specifies whether the DNS server
  logs local lookup events.
- **EnableLoggingForPluginDllEvent**: Specifies whether the DNS server logs
  dynamic link library (DLL) plug-in events.
- **EnableLoggingForRecursiveLookupEvent**: Specifies whether the DNS server
  logs recursive lookup events.
- **EnableLoggingForRemoteServerEvent**: Specifies whether the DNS server
  logs remote server events.
- **EnableLoggingForServerStartStopEvent**: Specifies whether the DNS server
  logs server start and stop events.
- **EnableLoggingForTombstoneEvent**: Specifies whether the DNS server logs
  tombstone events.
- **EnableLoggingForZoneDataWriteEvent**: Specifies Controls whether the DNS
  server logs zone data write events.
- **EnableLoggingForZoneLoadingEvent**: Specifies whether the DNS server logs
  zone load events.
- **EnableLoggingToFile**: Specifies whether the DNS server logs logging-to-file.
- **EventLogLevel**: Specifies an event log level. Valid values are Warning,
   Error, and None.
- **FilterIPAddressList**: Specifies an array of IP addresses to filter.
  When you enable logging, traffic to and from these IP addresses is logged.
  If you do not specify any IP addresses, traffic to and from all IP addresses
  is logged.
- **FullPackets**: Specifies whether the DNS server logs full packets.
- **LogFilePath**: Specifies a log file path.
- **MaxMBFileSize**: Specifies the maximum size of the log file. This parameter
  is relevant if you set EnableLogFileRollover and EnableLoggingToFile to $True.
- **Notifications**: Specifies whether the DNS server logs notifications.
- **Queries**: Specifies whether the DNS server allows query packet exchanges
  to pass through the content filter, such as the IPFilterList parameter.
- **QuestionTransactions**: Specifies whether the DNS server logs queries.
- **ReceivePackets**: Specifies whether the DNS server logs receive packets.
- **SaveLogsToPersistentStorage**: Specifies whether the DNS server saves
  logs to persistent storage.
- **SendPackets**: Specifies whether the DNS server logs send packets.
- **TcpPackets**: Specifies whether the DNS server logs TCP packets.
- **UdpPackets**: Specifies whether the DNS server logs UDP packets.
- **UnmatchedResponse**: Specifies whether the DNS server logs unmatched
  responses.
- **Update**: Specifies whether the DNS server logs updates.
- **UseSystemEventLog**: Specifies whether the DNS server uses the system
  event log for logging.
- **WriteThrough**: Specifies whether the DNS server logs write-throughs.

### xDnsServerForwarder

- **IsSingleInstance**: Specifies the resource is a single instance, the
  value must be 'Yes'
- **IPAddresses**: IP addresses of the forwarders
- **UseRootHint**: Specifies if you want to use root hint or not

### xDnsServerPrimaryZone

- **Name**: Name of the primary DNS zone
- **ZoneFile**: Name of the primary DNS zone file.
  - If not specified, defaults to 'ZoneName.dns'.
- **Ensure**: Whether the primary zone should be present or removed
- **DynamicUpdate**: Primary zone dynamic DNS update option.
  - If not specified, defaults to 'None'.
  - Valid values include: { None | NonSecureAndSecure }

### xDnsServerRootHint

- **IsSingleInstance**: Specifies the resource is a single instance, the
  value must be 'Yes'
- **NameServer**: A hashtable that defines the name server. Key and value
  must be strings.

### xDnsServerSecondaryZone

- **Name**: Name of the secondary zone
- **MasterServers**: IP address or DNS name of the secondary DNS servers
- **Ensure**: Whether the secondary zone should be present or removed
- **Type**: Type of the DNS server zone

### xDnsServerSetting

- **Name**: Key for the resource.  It doesn't matter what it is as long
  as it's unique within the configuration.
- **AddressAnswerLimit**: Maximum number of host records returned in response
  to an address request. Values between 5 and 28 are valid.
- **AllowUpdate**: Specifies whether the DNS Server accepts dynamic update
  requests.
- **AutoCacheUpdate**: Indicates whether the DNS Server attempts to update
  its cache entries using data from root servers.
- **AutoConfigFileZones**: Indicates which standard primary zones that are
  authoritative for the name of the DNS Server must be updated when the name
  server changes.
- **BindSecondaries**: Determines the AXFR message format when sending to
  non-Microsoft DNS Server secondaries.
- **BootMethod**: Initialization method for the DNS Server.
- **DefaultAgingState**: Default ScavengingInterval value set for all
  Active Directory-integrated zones created on this DNS Server.
- **DefaultNoRefreshInterval**: No-refresh interval, in hours, set for all
  Active Directory-integrated zones created on this DNS Server.
- **DefaultRefreshInterval**:  Refresh interval, in hours, set for all
  Active Directory-integrated zones created on this DNS Server.
- **DisableAutoReverseZones**: Indicates whether the DNS Server automatically
  creates standard reverse look up zones.
- **DisjointNets**: Indicates whether the default port binding for a socket
  used to send queries to remote DNS Servers can be overridden.
- **DsPollingInterval**: Interval, in seconds, to poll the DS-integrated zones.
- **DsTombstoneInterval**: Lifetime of tombstoned records in Directory Service
  integrated zones, expressed in seconds.
- **EDnsCacheTimeout**: Lifetime, in seconds, of the cached information describing
  the EDNS version supported by other DNS Servers.
- **EnableDirectoryPartitions**: Specifies whether support for application
  directory partitions is enabled on the DNS Server.
- **EnableDnsSec**: Specifies whether the DNS Server includes DNSSEC-specific
  RRs, KEY, SIG, and NXT in a response.
- **EnableEDnsProbes** :Specifies the behavior of the DNS Server. When TRUE,
  the DNS Server always responds with OPT resource records according to RFC 2671,
  unless the remote server has indicated it does not support EDNS in a prior
  exchange. If FALSE, the DNS Server responds to queries with OPTs only if OPTs
  are sent in the original query.
- **EventLogLevel**: Indicates which events the DNS Server records in the
  Event Viewer system log.
- **ForwardDelegations**: Specifies whether queries to delegated sub-zones
  are forwarded.
- **Forwarders**: Enumerates the list of IP addresses of Forwarders to which
  the DNS Server forwards queries.
- **ForwardingTimeout**: Time, in seconds, a DNS Server forwarding a query
  will wait for resolution from the forwarder before attempting to resolve
  the query itself.
- **IsSlave**: TRUE if the DNS server does not use recursion when name-resolution
  through forwarders fails.
- **ListenAddresses**: Enumerates the list of IP addresses on which the DNS
  Server can receive queries.
- **LocalNetPriority**: Indicates whether the DNS Server gives priority to
  the local net address when returning A records.
- **LogFileMaxSize**: Size of the DNS Server debug log, in bytes.
- **LogFilePath**: File name and path for the DNS Server debug log.
- **LogIPFilterList**: List of IP addresses used to filter DNS events written
  to the debug log.
- **LogLevel**: Indicates which policies are activated in the Event Viewer
  system log.
- **LooseWildcarding**: Indicates whether the DNS Server performs loose
  wildcarding.
- **MaxCacheTTL**: Maximum time, in seconds, the record of a recursive name
  query may remain in the DNS Server cache.
- **MaxNegativeCacheTTL**: Maximum time, in seconds, a name error result from
  a recursive query may remain in the DNS Server cache.
- **NameCheckFlag**: Indicates the set of eligible characters to be used in
  DNS names.
- **NoRecursion**: Indicates whether the DNS Server performs recursive look
  ups. TRUE indicates recursive look ups are not performed.
- **RecursionRetry**: Elapsed seconds before retrying a recursive look up.
- **RecursionTimeout**: Elapsed seconds before the DNS Server gives up recursive
  query.
- **RoundRobin**: Indicates whether the DNS Server round robins multiple A records.
- **RpcProtocol**: RPC protocol or protocols over which administrative RPC runs.
- **ScavengingInterval**: Interval, in hours, between two consecutive scavenging
  operations performed by the DNS Server.
- **SecureResponses**: Indicates whether the DNS Server exclusively saves records
  of names in the same subtree as the server that provided them.
- **SendPort**: Port on which the DNS Server sends UDP queries to other servers.
- **StrictFileParsing**: Indicates whether the DNS Server parses zone files
  strictly.
- **UpdateOptions**: Restricts the type of records that can be dynamically
  updated on the server, used in addition to the AllowUpdate settings on
  Server and Zone objects.
- **WriteAuthorityNS**: Specifies whether the DNS Server writes NS and SOA
  records to the authority section on successful response.
- **XfrConnectTimeout**: Time, in seconds, the DNS Server waits for a
  successful TCP connection to a remote server when attempting a zone transfer.
- **DsAvailable**: Indicates whether there is an available DS on the DNS
  Server. This is a read-only property.

### xDnsServerZoneAging

- **Name**: Name of the DNS forward or reverse loookup zone.
- **Enabled**: Option to enable scavenge stale resource records on the zone.
- **RefreshInterval**: Refresh interval for record scavencing in hours.
  Default value is 7 days.
- **NoRefreshInterval**: No-refresh interval for record scavencing in hours.
  Default value is 7 days.

### xDnsServerZoneScope

Requires Windows Server 2016 onwards

- **Name**: Specifies the name of the Zone Scope.
- **ZoneName**: Specify the existing DNS Zone to add a scope to.
- **Ensure**: Whether the Zone Scope should be present or removed.

### xDnsServerZoneTransfer

- **Name**: Name of the DNS zone
- **Type**: Type of transfer allowed.
  - Values include: { None | Any | Named | Specific }
- **SecondaryServer**: IP address or DNS name of DNS servers where zone
  information can be transfered.
