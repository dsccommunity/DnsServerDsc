$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName          = 'localhost'
            CertificateFile   = $env:DscPublicCertificatePath

            ForwarderZoneName = 'dsc.test'
            ReverseZoneName   = '1.168.192.in-addr.arpa'
        }
    )
}

configuration MSFT_xDnsServerZoneAging_Prerequisites_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone 'ForwardZone'
        {
            Name = $Node.ForwardZoneName
        }

        xDnsServerPrimaryZone 'ReverseZone'
        {
            Name = $Node.ReverseZoneName
        }
    }
}

configuration MSFT_xDnsServerZoneAging_ForwardZone_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerZoneAging 'Integration_Test'
        {
            Name              = $Node.ForwardZoneName
            Enabled           = $true
            RefreshInterval   = 240
            NoRefreshInterval = 480
        }
    }
}

configuration MSFT_xDnsServerZoneAging_ForwardZoneDisableAging_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerZoneAging 'Integration_Test'
        {
            Name    = $Node.ForwardZoneName
            Enabled = $false
        }
    }
}

configuration MSFT_xDnsServerZoneAging_ReverseZone_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerZoneAging 'Integration_Test'
        {
            Name              = $Node.ReverseZoneName
            Enabled           = $false
            RefreshInterval   = 250
            NoRefreshInterval = 490
        }
    }
}

configuration MSFT_xDnsServerZoneAging_Cleanup_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone 'ForwardZone'
        {
            Ensure = 'Absent'
            Name   = $Node.ForwardZoneName
        }

        xDnsServerPrimaryZone 'ReverseZone'
        {
            Ensure = 'Absent'
            Name   = $Node.ReverseZoneName
        }
    }
}
