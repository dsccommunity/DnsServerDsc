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
        }
        MSFT_xDnsRecordMx_ModifyRecord_Config = @{
            Name         = '@'
            Zone         = 'mx.test'
            Target       = 'mail.contoso.com'
            Priority     = '200'
            DnsServer    = 'localhost'
            TTL          = '05:00:00'
            Ensure       = 'Present'
        }
        MSFT_xDnsRecordMx_DeleteRecord_Config = @{
            Name         = '@'
            Zone         = 'mx.test'
            Target       = 'mail.contoso.com'
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
        }
    }
}


<#
    .SYNOPSIS
        Change TTL and Priority of an existing MX record
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
            Ensure       = $ConfigurationData.NonNodeData.MSFT_xDnsRecordMx_DeleteRecord_Config.Ensure
        }
    }
}
