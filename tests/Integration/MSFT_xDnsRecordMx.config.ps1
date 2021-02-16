$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        MSFT_xDnsRecordMx_CreateRecord_Config = @{
            Name         = '@'
            Zone         = 'mx.test'
            Target       = 'mail.contoso.com'
            Priority     = '10'
        }
        MSFT_xDnsRecordMx_ModifyRecord_Config = @{
            Name         = '@'
            Zone         = 'mx.test'
            Target       = 'mail.contoso.com'
            Priority     = '10'
            DnsServer    = 'localhost'
            TTL          = '05:00:00'
            Ensure       = 'Present'
        }
        MSFT_xDnsRecordMx_DeleteRecord_Config = @{
            Name         = '@'
            Zone         = 'mx.test'
            Target       = 'mail.contoso.com'
            Priority     = '10'
            Ensure       = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an MX record
#>
configuration MSFT_xDnsRecordMx_CreateRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsRecordMx 'Integration_Test'
        {
            Zone         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_CreateRecord_Config.Zone
            Name         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_CreateRecord_Config.Name
            Target       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_CreateRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_CreateRecord_Config.Priority
        }
    }
}


<#
    .SYNOPSIS
        Change TTL of an existing MX record
#>
configuration MSFT_xDnsRecordMx_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsRecordMx 'Integration_Test'
        {
            Zone         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_ModifyRecord_Config.Zone
            Name         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_ModifyRecord_Config.Name
            Target       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_ModifyRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_ModifyRecord_Config.Priority
            TTL          = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_ModifyRecord_Config.TTL
            DnsServer    = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_ModifyRecord_Config.DnsServer
            Ensure       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_ModifyRecord_Config.Ensure
        }
    }
}


<#
    .SYNOPSIS
        Deletes an existing MX record
#>
configuration MSFT_xDnsRecordMx_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsRecordMx 'Integration_Test'
        {
            Zone         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_DeleteRecord_Config.Zone
            Name         = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_DeleteRecord_Config.Name
            Target       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_DeleteRecord_Config.Target
            Priority     = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_DeleteRecord_Config.Priority
            Ensure       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_DeleteRecord_Config.Ensure
        }
    }
}
