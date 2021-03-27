$zoneName = "A.test"
$zoneScope = 'external'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordAScoped_CreateRecord_Config = @{
            ZoneName    = $zoneName
            ZoneScope   = $zoneScope
            Name        = 'www'
            IPv4Address = '192.168.50.10'
        }
        DnsRecordAScoped_ModifyRecord_Config = @{
            ZoneName    = $zoneName
            ZoneScope   = $zoneScope
            Name        = 'www'
            IPv4Address = '192.168.50.10'
            DnsServer   = 'localhost'
            TimeToLive  = '05:00:00'
            Ensure      = 'Present'
        }
        DnsRecordAScoped_DeleteRecord_Config = @{
            ZoneName    = $zoneName
            ZoneScope   = $zoneScope
            Name        = 'www'
            IPv4Address = '192.168.50.10'
            Ensure      = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an A record
#>
configuration DnsRecordAScoped_CreateRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordAScoped 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAScoped_CreateRecord_Config.ZoneName
            ZoneScope   = $ConfigurationData.NonNodeData.DnsRecordAScoped_CreateRecord_Config.ZoneScope
            Name        = $ConfigurationData.NonNodeData.DnsRecordAScoped_CreateRecord_Config.Name
            IPv4Address = $ConfigurationData.NonNodeData.DnsRecordAScoped_CreateRecord_Config.IPv4Address
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing A record
#>
configuration DnsRecordAScoped_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordAScoped 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAScoped_ModifyRecord_Config.ZoneName
            ZoneScope   = $ConfigurationData.NonNodeData.DnsRecordAScoped_ModifyRecord_Config.ZoneScope
            Name        = $ConfigurationData.NonNodeData.DnsRecordAScoped_ModifyRecord_Config.Name
            IPv4Address = $ConfigurationData.NonNodeData.DnsRecordAScoped_ModifyRecord_Config.IPv4Address
            DnsServer   = $ConfigurationData.NonNodeData.DnsRecordAScoped_ModifyRecord_Config.DnsServer
            TimeToLive  = $ConfigurationData.NonNodeData.DnsRecordAScoped_ModifyRecord_Config.TimeToLive
            Ensure      = $ConfigurationData.NonNodeData.DnsRecordAScoped_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing A record
#>
configuration DnsRecordAScoped_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordAScoped 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAScoped_DeleteRecord_Config.ZoneName
            ZoneScope   = $ConfigurationData.NonNodeData.DnsRecordAScoped_DeleteRecord_Config.ZoneScope
            Name        = $ConfigurationData.NonNodeData.DnsRecordAScoped_DeleteRecord_Config.Name
            IPv4Address = $ConfigurationData.NonNodeData.DnsRecordAScoped_DeleteRecord_Config.IPv4Address
            Ensure      = $ConfigurationData.NonNodeData.DnsRecordAScoped_DeleteRecord_Config.Ensure
        }
    }
}
