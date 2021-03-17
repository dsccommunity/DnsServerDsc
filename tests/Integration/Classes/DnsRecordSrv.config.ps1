$zoneName = "srv.test"

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordSrv_CreateRecord_Config = @{
            ZoneName     = $zoneName
            SymbolicName = 'dummy'
            Port         = '33179'
            Target       = 'dummy.contoso.com'
            Priority     = 10
            Weight       = 20
            Protocol     = 'tcp'
        }
        DnsRecordSrv_ModifyRecord_Config = @{
            ZoneName     = $zoneName
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
        DnsRecordSrv_DeleteRecord_Config = @{
            ZoneName     = $zoneName
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
configuration DnsRecordSrv_CreateRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordSrv 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordSrv_CreateRecord_Config.ZoneName
            SymbolicName = $ConfigurationData.NonNodeData.DnsRecordSrv_CreateRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.DnsRecordSrv_CreateRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.DnsRecordSrv_CreateRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.DnsRecordSrv_CreateRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.DnsRecordSrv_CreateRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.DnsRecordSrv_CreateRecord_Config.Weight
        }
    }
}

<#
    .SYNOPSIS
        Add TimeToLive, Priority, and Weight to an existing SRV record
#>
configuration DnsRecordSrv_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordSrv 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.ZoneName
            SymbolicName = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.Weight
            TimeToLive   = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.TimeToLive
            DnsServer    = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.DnsServer
            Ensure       = $ConfigurationData.NonNodeData.DnsRecordSrv_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing SRV record
#>
configuration DnsRecordSrv_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordSrv 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.ZoneName
            SymbolicName = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.Weight
            TimeToLive   = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.TimeToLive
            DnsServer    = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.DnsServer
            Ensure       = $ConfigurationData.NonNodeData.DnsRecordSrv_DeleteRecord_Config.Ensure
        }
    }
}
