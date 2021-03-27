$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName           = 'localhost'
            CertificateFile    = $env:DscPublicCertificatePath

            ForwarderIpAddress = @('192.168.0.10', '192.168.0.11')
        }
    )
}

configuration DSC_xDnsServerForwarder_SetForwarderDoNotUseRootHints_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

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

configuration DSC_xDnsServerForwarder_SetForwarderUseRootHints_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

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

configuration DSC_xDnsServerForwarder_RemoveForwarders_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

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

configuration DSC_xDnsServerForwarder_SetUseRootHint_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            UseRootHint      = $true
        }
    }
}

configuration DSC_xDnsServerForwarder_SetEnableReordering_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            EnableReordering = $true
        }
    }
}

configuration DSC_xDnsServerForwarder_SetDisableReordering_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            EnableReordering = $false
        }
    }
}

configuration DSC_xDnsServerForwarder_SetTimeout_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerForwarder 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            Timeout          = 10
        }
    }
}
