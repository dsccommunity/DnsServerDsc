$zoneName = "Ns.test"
$zoneScope = 'external'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordNsScoped_CreateRecord_Config = @{
            ZoneName   = $zoneName
            ZoneScope  = $zoneScope
            DomainName = 'contoso.com'
            NameServer = 'ns.contoso.com'
        }
        DnsRecordNsScoped_ModifyRecord_Config = @{
            ZoneName   = $zoneName
            ZoneScope  = $zoneScope
            DomainName = 'contoso.com'
            NameServer = 'ns.contoso.com'
            DnsServer  = 'localhost'
            TimeToLive = '05:00:00'
            Ensure     = 'Present'
        }
        DnsRecordNsScoped_DeleteRecord_Config = @{
            ZoneName   = $zoneName
            ZoneScope  = $zoneScope
            DomainName = 'contoso.com'
            NameServer = 'ns.contoso.com'
            Ensure     = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an NS record
#>
configuration DnsRecordNsScoped_CreateRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDscPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerDscZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordNsScoped 'Integration_Test'
        {
            ZoneName   = $ConfigurationData.NonNodeData.DnsRecordNsScoped_CreateRecord_Config.ZoneName
            ZoneScope  = $ConfigurationData.NonNodeData.DnsRecordNsScoped_CreateRecord_Config.ZoneScope
            DomainName = $ConfigurationData.NonNodeData.DnsRecordNsScoped_CreateRecord_Config.DomainName
            NameServer = $ConfigurationData.NonNodeData.DnsRecordNsScoped_CreateRecord_Config.NameServer
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing NS record
#>
configuration DnsRecordNsScoped_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDscPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerDscZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordNsScoped 'Integration_Test'
        {
            ZoneName   = $ConfigurationData.NonNodeData.DnsRecordNsScoped_ModifyRecord_Config.ZoneName
            ZoneScope  = $ConfigurationData.NonNodeData.DnsRecordNsScoped_ModifyRecord_Config.ZoneScope
            DomainName = $ConfigurationData.NonNodeData.DnsRecordNsScoped_ModifyRecord_Config.DomainName
            NameServer = $ConfigurationData.NonNodeData.DnsRecordNsScoped_ModifyRecord_Config.NameServer
            DnsServer  = $ConfigurationData.NonNodeData.DnsRecordNsScoped_ModifyRecord_Config.DnsServer
            TimeToLive = $ConfigurationData.NonNodeData.DnsRecordNsScoped_ModifyRecord_Config.TimeToLive
            Ensure     = $ConfigurationData.NonNodeData.DnsRecordNsScoped_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing NS record
#>
configuration DnsRecordNsScoped_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDscPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerDscZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordNsScoped 'Integration_Test'
        {
            ZoneName   = $ConfigurationData.NonNodeData.DnsRecordNsScoped_DeleteRecord_Config.ZoneName
            ZoneScope  = $ConfigurationData.NonNodeData.DnsRecordNsScoped_DeleteRecord_Config.ZoneScope
            DomainName = $ConfigurationData.NonNodeData.DnsRecordNsScoped_DeleteRecord_Config.DomainName
            NameServer = $ConfigurationData.NonNodeData.DnsRecordNsScoped_DeleteRecord_Config.NameServer
            Ensure     = $ConfigurationData.NonNodeData.DnsRecordNsScoped_DeleteRecord_Config.Ensure
        }
    }
}
