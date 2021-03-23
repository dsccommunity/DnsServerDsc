$zoneName = "Aaaa.test"
$zoneScope = 'external'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordAaaaScoped_CreateRecord_Config = @{
            ZoneName    = $zoneName
            ZoneScope   = $zoneScope
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
        }
        DnsRecordAaaaScoped_ModifyRecord_Config = @{
            ZoneName    = $zoneName
            ZoneScope   = $zoneScope
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
            DnsServer   = 'localhost'
            TimeToLive  = '05:00:00'
            Ensure      = 'Present'
        }
        DnsRecordAaaaScoped_DeleteRecord_Config = @{
            ZoneName    = $zoneName
            ZoneScope   = $zoneScope
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
            Ensure      = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an AAAA record
#>
configuration DnsRecordAaaaScoped_CreateRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        xDnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordAaaaScoped 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_CreateRecord_Config.ZoneName
            ZoneScope   = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_CreateRecord_Config.ZoneScope
            Name        = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_CreateRecord_Config.Name
            IPv6Address = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_CreateRecord_Config.IPv6Address
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing AAAA record
#>
configuration DnsRecordAaaaScoped_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        xDnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordAaaaScoped 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_ModifyRecord_Config.ZoneName
            ZoneScope   = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_ModifyRecord_Config.ZoneScope
            Name        = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_ModifyRecord_Config.Name
            IPv6Address = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_ModifyRecord_Config.IPv6Address
            DnsServer   = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_ModifyRecord_Config.DnsServer
            TimeToLive  = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_ModifyRecord_Config.TimeToLive
            Ensure      = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing AAAA record
#>
configuration DnsRecordAaaaScoped_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        xDnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordAaaaScoped 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_DeleteRecord_Config.ZoneName
            ZoneScope   = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_DeleteRecord_Config.ZoneScope
            Name        = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_DeleteRecord_Config.Name
            IPv6Address = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_DeleteRecord_Config.IPv6Address
            Ensure      = $ConfigurationData.NonNodeData.DnsRecordAaaaScoped_DeleteRecord_Config.Ensure
        }
    }
}
