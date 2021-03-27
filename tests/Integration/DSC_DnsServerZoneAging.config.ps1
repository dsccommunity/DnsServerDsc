$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath

            ForwardZoneName = 'dsc.test'
            ReverseZoneName = '1.168.192.in-addr.arpa'
        }
    )
}

configuration DSC_DnsServerZoneAging_Prerequisites_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'ForwardZone'
        {
            Name = $Node.ForwardZoneName
        }

        DnsServerPrimaryZone 'ReverseZone'
        {
            Name = $Node.ReverseZoneName
        }
    }
}

configuration DSC_DnsServerZoneAging_ForwardZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerZoneAging 'Integration_Test'
        {
            Name              = $Node.ForwardZoneName
            Enabled           = $true
            RefreshInterval   = 240
            NoRefreshInterval = 480
        }
    }
}

configuration DSC_DnsServerZoneAging_ForwardZoneDisableAging_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerZoneAging 'Integration_Test'
        {
            Name    = $Node.ForwardZoneName
            Enabled = $false
        }
    }
}

configuration DSC_DnsServerZoneAging_ReverseZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerZoneAging 'Integration_Test'
        {
            Name              = $Node.ReverseZoneName
            Enabled           = $false
            RefreshInterval   = 250
            NoRefreshInterval = 490
        }
    }
}

configuration DSC_DnsServerZoneAging_Cleanup_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'ForwardZone'
        {
            Ensure = 'Absent'
            Name   = $Node.ForwardZoneName
        }

        DnsServerPrimaryZone 'ReverseZone'
        {
            Ensure = 'Absent'
            Name   = $Node.ReverseZoneName
        }
    }
}
