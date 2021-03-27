$zoneName = "srv.test"
$zoneScope = 'external'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordSrvScoped_CreateRecord_Config = @{
            ZoneName     = $zoneName
            ZoneScope    = $zoneScope
            SymbolicName = 'dummy'
            Port         = '33179'
            Target       = 'dummy.contoso.com'
            Priority     = 10
            Weight       = 20
            Protocol     = 'tcp'
        }
        DnsRecordSrvScoped_ModifyRecord_Config = @{
            ZoneName     = $zoneName
            ZoneScope    = $zoneScope
            SymbolicName = 'dummy'
            Port         = '33179'
            Target       = 'dummy.contoso.com'
            Weight       = '100'
            Priority     = '200'
            DnsServer    = 'localhost'
            TimeToLive   = '05:00:00'
            Protocol     = 'tcp'
            Ensure       = 'Present'
        }
        DnsRecordSrvScoped_DeleteRecord_Config = @{
            ZoneName     = $zoneName
            ZoneScope    = $zoneScope
            SymbolicName = 'dummy'
            Port         = '33179'
            Target       = 'dummy.contoso.com'
            Protocol     = 'tcp'
            Priority     = 0
            Weight       = 0
            Ensure       = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an SRV record
#>
configuration DnsRecordSrvScoped_CreateRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope "external scope"
        {
            Name     = $zoneScope
            ZoneName = $zoneName
        }

        DnsRecordSrvScoped 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_CreateRecord_Config.ZoneName
            ZoneScope    = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_CreateRecord_Config.ZoneScope
            SymbolicName = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_CreateRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_CreateRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_CreateRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_CreateRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_CreateRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_CreateRecord_Config.Weight
        }
    }
}


<#
    .SYNOPSIS
        Add TimeToLive, Priority, and Weight to an existing SRV record
#>
configuration DnsRecordSrvScoped_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope "external scope"
        {
            Name     = $zoneScope
            ZoneName = $zoneName
        }

        DnsRecordSrvScoped 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.ZoneName
            ZoneScope    = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.ZoneScope
            SymbolicName = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.Weight
            TimeToLive   = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.TimeToLive
            DnsServer    = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.DnsServer
            Ensure       = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_ModifyRecord_Config.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Deletes an existing SRV record
#>
configuration DnsRecordSrvScoped_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope "external scope"
        {
            Name     = $zoneScope
            ZoneName = $zoneName
        }

        DnsRecordSrvScoped 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.ZoneName
            ZoneScope    = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.ZoneScope
            SymbolicName = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.Weight
            TimeToLive   = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.TimeToLive
            DnsServer    = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.DnsServer
            Ensure       = $ConfigurationData.NonNodeData.DnsRecordSrvScoped_DeleteRecord_Config.Ensure
        }
    }
}
