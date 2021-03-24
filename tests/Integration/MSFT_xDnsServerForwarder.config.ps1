$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName           = 'localhost'
            CertificateFile    = $env:DscPublicCertificatePath

            ForwarderIpAddress = @('192.168.0.10', '192.168.0.11')
        }
    )
}

configuration MSFT_xDnsServerForwarder_SetForwarderDoNotUseRootHints_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            IPAddresses      = $Node.ForwarderIpAddress
            UseRootHint      = $false
        }
    }
}

configuration MSFT_xDnsServerForwarder_SetForwarderUseRootHints_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            IPAddresses      = $Node.ForwarderIpAddress
            UseRootHint      = $true
        }
    }
}

configuration MSFT_xDnsServerForwarder_RemoveForwarders_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            IPAddresses      = @()
            UseRootHint      = $false
        }
    }
}

configuration MSFT_xDnsServerForwarder_SetUseRootHint_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            UseRootHint      = $true
        }
    }
}

configuration MSFT_xDnsServerForwarder_SetEnableReordering_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            EnableReordering = $true
        }
    }
}

configuration MSFT_xDnsServerForwarder_SetDisableReordering_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            EnableReordering = $false
        }
    }
}

configuration MSFT_xDnsServerForwarder_SetTimeout_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            Timeout          = 10
        }
    }
}
