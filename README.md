[![Build status](https://ci.appveyor.com/api/projects/status/qqspiio117bgaieo/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xdnsserver/branch/master)

# xDnsServer

The **xDnsServer** DSC resources configure and manage a DNS server. They include **xDnsServerPrimaryZone**, **xDnsServerSecondaryZone**, **xDnsServerZoneTransfer** and **xDnsARecord**.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


## Resources

* **xDnsServerPrimaryZone** sets a standalone Primary zone on a given DNS server.
__NOTE: AD integrated zones are not (yet) supported.__
* **xDnsServerSecondaryZone** sets a Secondary zone on a given DNS server.
Secondary zones allow client machine in primary DNS zones to do DNS resolution of machines in the secondary DNS zone.
* **xDnsServerZoneTransfer** This resource allows a DNS Server zone data to be replicated to another DNS server.
* **xDnsRecord** This resource allwos for the creation of IPv4 host (A) records or CNames against a specific zone on the DNS server


### xDnsServerPrimaryZone

* **Name**: Name of the primary DNS zone
* **ZoneFile**: Name of the primary DNS zone file.
 * If not specified, defaults to 'ZoneName.dns'.
* **Ensure**: Whether the primary zone should be present or removed
* **DynamicUpdate**: Primary zone dynamic DNS update option.
 * If not specified, defaults to 'None'.
 * Valid values include: { None | NonsecureAndSecure }

### xDnsServerSecondaryZone

* **Name**: Name of the secondary zone
* **MasterServers**: IP address or DNS name of the secondary DNS servers
* **Ensure**: Whether the secondary zone should be present or removed
* **Type**: Type of the DNS server zone

### xDnsServerZoneTransfer

* **Name**: Name of the DNS zone
* **Type**: Type of transfer allowed. 
Values include: { None | Any | Named | Specific }
* **SecondaryServer**: IP address or DNS name of DNS servers where zone information can be transfered.

### xDnsARecord {Will be removed in a future release}
* **Name**: Name of the host
* **Zone**: The name of the zone to create the host record in
* **Target**: Target Hostname or IP Address {*Only Supports IPv4 in the current release*}
* **Type**: DNS Record Type.
Values include: { A-Record | C-Name }
* **Ensure**: Whether the host record should be present or removed

### xDnsRecord
* **Name**: Name of the host
* **Zone**: The name of the zone to create the host record in
* **Target**: Target Hostname or IP Address {*Only Supports IPv4 in the current release*}
* **Type**: DNS Record Type.
Values include: { A-Record | C-Name }
* **Ensure**: Whether the host record should be present or removed


## Versions

### Unreleased

### 1.5.0.0

* Added Resource xDnsRecord with support for CNames. 
This will replace xDnsARecord in a future release.

### 1.5.0.0

* Added **xDnsServerPrimaryZone** resource

### 1.4.0.0
* Added support for removing DNS A records

### 1.3.0.0

* Fix to retrieving settings for record data

### 1.2.0.0

* Removed UTF8 BOM from MOF schema

### 1.1

* Add **xDnsARecord** resource.

### 1.0

*   Initial release with the following resources 
    * **xDnsServerSecondaryZone**
    * **xDnsServerZoneTransfer**

## Examples

### Configuring a DNS Transfer Zone

```powershell
configuration Sample_xDnsServerZoneTransfer_TransferToAnyServer
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DnsZoneName,

        [Parameter(Mandatory)]
        [String]$TransferType
    )
    Import-DscResource -module xDnsServer
    xDnsServerZoneTransfer TransferToAnyServer
    {
        Name = $DnsZoneName
        Type = $TransferType
    }
}
Sample_xDnsServerZoneTransfer_TransferToAnyServer -DnsZoneName 'demo.contoso.com' -TransferType 'Any'
```

### Configuring a Primary Standalone DNS Zone

```powershell
configuration Sample_xDnsServerPrimaryZone
{
    param
    (
        [Parameter(Mandatory)]
        [String]$ZoneName,
        [Parameter()] [ValidateNotNullOrEmpty()]
        [String]$ZoneFile = "$ZoneName.dns",
        [Parameter()] [ValidateSet('None','NonsecureAndSecure')]
        [String]$DynamicUpdate = 'None' 
    )
    
    Import-DscResource -module xDnsServer
    xDnsServerPrimaryZone addPrimaryZone
    {
        Ensure        = 'Present'                
        Name          = $ZoneName
        ZoneFile      = $ZoneFile
        DynamicUpdate = $DynamicUpdate
    }
}
Sample_xDnsServerPrimaryZone -ZoneName 'demo.contoso.com' -DyanmicUpdate 'NonsecureAndSecure' 
```

### Configuring a Secondary DNS Zone

```powershell
configuration Sample_xDnsServerSecondaryZone
{
    param
    (
        [Parameter(Mandatory)]
        [String]$ZoneName,
        [Parameter(Mandatory)]
        [String[]]$SecondaryDnsServer
    )

    Import-DscResource -module xDnsServer
    xDnsServerSecondaryZone sec
    {
        Ensure        = 'Present'                
        Name          = $ZoneName
        MasterServers = $SecondaryDnsServer

    }
}
Sample_xDnsServerSecondaryZone -ZoneName 'demo.contoso.com' -SecondaryDnsServer '192.168.10.2' 
```

### Adding a DNS ARecord

```powershell
configuration Sample_Arecord
{
    Import-DscResource -module xDnsServer
    xDnsRecord TestRecord
    {
        Name = "testArecord"
        Target = "192.168.0.123"
        Zone = "contoso.com" 
	Type = "ARecord"
        Ensure = "Present"
    }
}
Sample_Arecord 
```

### Adding a DNS CName

```powershell
configuration Sample_CName
{
    Import-DscResource -module xDnsServer
    xDnsRecord TestRecord
    {
        Name = "testCName"
        Target = "test.contoso.com"
        Zone = "contoso.com" 
	Type = "CName"
        Ensure = "Present"
    }
}
Sample_Crecord 
```

### Removing a DNS A Record

```powershell
configuration Sample_Remove_Record
{
    Import-DscResource -module xDnsServer
    xDnsARecord RemoveTestRecord
    {
        Name = "testArecord"
        Target = "192.168.0.123"
        Zone = "contoso.com"
	Type = "ARecord"
        Ensure = "Absent" 
    }
}
Sample_Sample_Remove_Record
```
