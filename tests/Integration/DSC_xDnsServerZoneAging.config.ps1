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

configuration DSC_xDnsServerZoneAging_Prerequisites_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

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

configuration DSC_xDnsServerZoneAging_ForwardZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

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

configuration DSC_xDnsServerZoneAging_ForwardZoneDisableAging_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerZoneAging 'Integration_Test'
        {
            Name    = $Node.ForwardZoneName
            Enabled = $false
        }
    }
}

configuration DSC_xDnsServerZoneAging_ReverseZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

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

configuration DSC_xDnsServerZoneAging_Cleanup_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

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
