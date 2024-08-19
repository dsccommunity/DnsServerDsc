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

configuration DSC_DnsServerZoneScope_Prerequisites_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'ForwardZone'
        {
            Name = $Node.ForwardZoneName
        }
    }
}

configuration DSC_DnsServerZoneScope_AddZoneScope_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerZoneScope 'Integration_Test'
        {
            Name     = $Node.ZoneScopeName
            ZoneName = $Node.ForwardZoneName
        }
    }
}

configuration DSC_DnsServerZoneScope_RemoveZoneScope_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerZoneScope 'Integration_Test'
        {
            Ensure   = 'Absent'
            Name     = $Node.ZoneScopeName
            ZoneName = $Node.ForwardZoneName
        }
    }
}

configuration DSC_DnsServerZoneScope_Cleanup_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'ForwardZone'
        {
            Ensure = 'Absent'
            Name   = $Node.ForwardZoneName
        }
    }
}
