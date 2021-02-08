$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        MSFT_xDnsRecordSrv_CreateRecord_Config = @{
            Zone         = 'srv.test'
            SymbolicName = 'dummy'
            Port         = '33179'
            Target       = 'dummy.contoso.com'
            Protocol     = 'tcp'
        }
        MSFT_xDnsRecordSrv_ModifyRecord_Config = @{
            Zone         = 'srv.test'
            SymbolicName = 'dummy'
            Weight       = '100'
            Priority     = '200'
            DnsServer    = ''
            TTL          = '05:00:00'
            Port         = '33179'
            Target       = 'dummy.contoso.com'
            Protocol     = 'tcp'
            Ensure       = 'Present'
        }
        MSFT_xDnsRecordSrv_DeleteRecord_Config = @{
            Zone         = 'srv.test'
            SymbolicName = 'dummy'
            Port         = '33179'
            Target       = 'dummy.contoso.com'
            Protocol     = 'tcp'
            Ensure       = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an SRV record
#>
configuration MSFT_xDnsRecordSrv_CreateRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsRecordSrv 'Integration_Test'
        {
            Zone         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.Zone
            SymbolicName = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.Weight
            TTL          = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.TTL
            DnsServer    = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.DnsServer
            Ensure       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_CreateRecord_Config.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Add TTL, Priority, and Weight to an existing SRV record
#>
configuration MSFT_xDnsRecordSrv_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsRecordSrv 'Integration_Test'
        {
            Zone         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.Zone
            SymbolicName = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.Weight
            TTL          = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.TTL
            DnsServer    = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.DnsServer
            Ensure       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_ModifyRecord_Config.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Deletes an existing SRV record
#>
configuration MSFT_xDnsRecordSrv_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsRecordSrv 'Integration_Test'
        {
            Zone         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.Zone
            SymbolicName = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.SymbolicName
            Protocol     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.Protocol
            Port         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.Port
            Target       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.Priority
            Weight       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.Weight
            TTL          = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.TTL
            DnsServer    = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.DnsServer
            Ensure       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordSrv_DeleteRecord_Config.Ensure
        }
    }
}
