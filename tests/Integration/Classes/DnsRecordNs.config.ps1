$zoneName = "Ns.test"

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordNs_CreateRecord_Config = @{
            ZoneName   = $zoneName
            DomainName = $zoneName
            NameServer = 'ns.contoso.com'
        }
        DnsRecordNs_ModifyRecord_Config = @{
            ZoneName   = $zoneName
            DomainName = $zoneName
            NameServer = 'ns.contoso.com'
            DnsServer  = 'localhost'
            TimeToLive = '05:00:00'
            Ensure     = 'Present'
        }
        DnsRecordNs_DeleteRecord_Config = @{
            ZoneName   = $zoneName
            DomainName = $zoneName
            NameServer = 'ns.contoso.com'
            Ensure     = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an NS record
#>
configuration DnsRecordNs_CreateRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordNs 'Integration_Test'
        {
            ZoneName   = $ConfigurationData.NonNodeData.DnsRecordNs_CreateRecord_Config.ZoneName
            DomainName = $ConfigurationData.NonNodeData.DnsRecordNs_CreateRecord_Config.DomainName
            NameServer = $ConfigurationData.NonNodeData.DnsRecordNs_CreateRecord_Config.NameServer
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing NS record
#>
configuration DnsRecordNs_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordNs 'Integration_Test'
        {
            ZoneName   = $ConfigurationData.NonNodeData.DnsRecordNs_ModifyRecord_Config.ZoneName
            DomainName = $ConfigurationData.NonNodeData.DnsRecordNs_ModifyRecord_Config.DomainName
            NameServer = $ConfigurationData.NonNodeData.DnsRecordNs_ModifyRecord_Config.NameServer
            DnsServer  = $ConfigurationData.NonNodeData.DnsRecordNs_ModifyRecord_Config.DnsServer
            TimeToLive = $ConfigurationData.NonNodeData.DnsRecordNs_ModifyRecord_Config.TimeToLive
            Ensure     = $ConfigurationData.NonNodeData.DnsRecordNs_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing NS record
#>
configuration DnsRecordNs_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordNs 'Integration_Test'
        {
            ZoneName   = $ConfigurationData.NonNodeData.DnsRecordNs_DeleteRecord_Config.ZoneName
            DomainName = $ConfigurationData.NonNodeData.DnsRecordNs_DeleteRecord_Config.DomainName
            NameServer = $ConfigurationData.NonNodeData.DnsRecordNs_DeleteRecord_Config.NameServer
            Ensure     = $ConfigurationData.NonNodeData.DnsRecordNs_DeleteRecord_Config.Ensure
        }
    }
}
