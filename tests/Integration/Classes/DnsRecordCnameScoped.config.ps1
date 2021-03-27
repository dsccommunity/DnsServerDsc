$zoneName = "Cname.test"
$zoneScope = 'external'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordCnameScoped_CreateRecord_Config = @{
            ZoneName      = $zoneName
            ZoneScope     = $zoneScope
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
        }
        DnsRecordCnameScoped_ModifyRecord_Config = @{
            ZoneName      = $zoneName
            ZoneScope     = $zoneScope
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
            DnsServer     = 'localhost'
            TimeToLive    = '05:00:00'
            Ensure        = 'Present'
        }
        DnsRecordCnameScoped_DeleteRecord_Config = @{
            ZoneName      = $zoneName
            ZoneScope     = $zoneScope
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
            Ensure        = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an CNAME record
#>
configuration DnsRecordCnameScoped_CreateRecord_Config
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

        DnsRecordCnameScoped 'Integration_Test'
        {
            ZoneName      = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_CreateRecord_Config.ZoneName
            ZoneScope     = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_CreateRecord_Config.ZoneScope
            Name          = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_CreateRecord_Config.Name
            HostNameAlias = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_CreateRecord_Config.HostNameAlias
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing CNAME record
#>
configuration DnsRecordCnameScoped_ModifyRecord_Config
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

        DnsRecordCnameScoped 'Integration_Test'
        {
            ZoneName      = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_ModifyRecord_Config.ZoneName
            ZoneScope     = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_ModifyRecord_Config.ZoneScope
            Name          = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_ModifyRecord_Config.Name
            HostNameAlias = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_ModifyRecord_Config.HostNameAlias
            DnsServer     = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_ModifyRecord_Config.DnsServer
            TimeToLive    = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_ModifyRecord_Config.TimeToLive
            Ensure        = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing CNAME record
#>
configuration DnsRecordCnameScoped_DeleteRecord_Config
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

        DnsRecordCnameScoped 'Integration_Test'
        {
            ZoneName      = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_DeleteRecord_Config.ZoneName
            ZoneScope     = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_DeleteRecord_Config.ZoneScope
            Name          = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_DeleteRecord_Config.Name
            HostNameAlias = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_DeleteRecord_Config.HostNameAlias
            Ensure        = $ConfigurationData.NonNodeData.DnsRecordCnameScoped_DeleteRecord_Config.Ensure
        }
    }
}
