[![Build status](https://ci.appveyor.com/api/projects/status/qqspiio117bgaieo/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xdnsserver/branch/master)

# xDnsServer

The **xDnsServer** DSC resources configure and manage a DNS server. They include **xDnsServerSecondaryZone**, **xDnsServerZoneTransfer** and **xDnsARecord**.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


## Resources

* **xDnsServerSecondaryZone** sets a Secondary zone on a given DNS server.
Secondary zones allow client machine in primary DNS zones to do DNS resolution of machines in the secondary DNS zone.
* **xDnsServerZoneTransfer** This resource allows a DNS Server zone data to be replicated to another DNS server.
* **xDnsARecord** This resource allwos for the creation of A records agaisnt a specific zone on the DNS server


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

### xDnsARecord
* **Name**: Name of the DNS zone
* **Zone**: The name of the zone to create the record in
* **Target**: The IP address of the A record


## Versions

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

### Adding a DNS A Record

```powershell
configuration Sample_Arecord
{
    Import-DscResource -module xDnsServer
    xDnsARecord TestRecord
    {
        Name = "testArecord"
        Target = "192.168.0.123"
        Zone = "contoso.com" 
    }
}
Sample_Arecord 
```
