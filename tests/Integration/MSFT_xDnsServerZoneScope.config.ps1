$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath

            ForwardZoneName = 'dsc.test'
            ZoneScopeName   = 'dsc_Europe'
        }
    )
}

configuration MSFT_xDnsServerZoneScope_Prerequisites_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone 'ForwardZone'
        {
            Name = $Node.ForwardZoneName
        }
    }
}

configuration MSFT_xDnsServerZoneScope_AddZoneScope_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerZoneScope 'Integration_Test'
        {
            Name     = $Node.ZoneScopeName
            ZoneName = $Node.ForwardZoneName
        }
    }
}

configuration MSFT_xDnsServerZoneScope_RemoveZoneScope_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerZoneScope 'Integration_Test'
        {
            Ensure   = 'Absent'
            Name     = $Node.ZoneScopeName
            ZoneName = $Node.ForwardZoneName
        }
    }
}


configuration MSFT_xDnsServerZoneScope_Cleanup_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone 'ForwardZone'
        {
            Ensure = 'Absent'
            Name   = $Node.ForwardZoneName
        }
    }
}
