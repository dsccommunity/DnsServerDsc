$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath

            NameServer      = @{
                'H.ROOT-SERVERS.NET.' = '198.97.190.53'
                'E.ROOT-SERVERS.NET.' = '192.203.230.10'
                'M.ROOT-SERVERS.NET.' = '202.12.27.33'
                'A.ROOT-SERVERS.NET.' = '198.41.0.4'
                'D.ROOT-SERVERS.NET.' = '199.7.91.13'
                'F.ROOT-SERVERS.NET.' = '192.5.5.241'
                'B.ROOT-SERVERS.NET.' = '192.228.79.201'
                'G.ROOT-SERVERS.NET.' = '192.112.36.4'
                'C.ROOT-SERVERS.NET.' = '192.33.4.12'
                'K.ROOT-SERVERS.NET.' = '193.0.14.129'
                'I.ROOT-SERVERS.NET.' = '192.36.148.17'
                'J.ROOT-SERVERS.NET.' = '192.58.128.30'
                'L.ROOT-SERVERS.NET.' = '199.7.83.42'
            }
        }
    )
}

configuration DSC_xDnsServerRootHint_RemoveAllRootHints_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerRootHint 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            NameServer       = @{}
        }
    }
}

configuration DSC_xDnsServerRootHint_SetRootHints_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerRootHint 'Integration_Test'
        {
            IsSingleInstance = 'Yes'
            NameServer       = $Node.NameServer
        }
    }
}
