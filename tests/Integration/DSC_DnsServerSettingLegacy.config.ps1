$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName             = 'localhost'
            CertificateFile      = $env:DscPublicCertificatePath
            DnsServer            = 'localhost'
            DisjointNets         = $false
            NoForwarderRecursion = $false
            LogLevel             = 2197877553
        }
    )
}

Configuration DSC_DnsServerSettingLegacy_SetSettings_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerSettingLegacy 'Integration_Test'
        {

            DnsServer            = $Node.DnsServer
            DisjointNets         = $Node.DisjointNets
            NoForwarderRecursion = $Node.NoForwarderRecursion
            LogLevel             = $Node.LogLevel
        }
    }
}
