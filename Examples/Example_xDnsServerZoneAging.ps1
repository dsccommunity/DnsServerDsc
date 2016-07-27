configuration DnsZoneAging
{
    Import-DscResource -ModuleName xDnsServer

    node localhost
    {
        xDnsServerZoneAging DnsServerZoneAging
        {
            ZoneName          = 'contoso.com'
            AgingEnabled      = $true
            RefreshInterval   = '7.00:00:00'
            NoRefreshInterval = '7.00:00:00'
            ScavengeServers   = '10.0.0.4','10.0.0.5'
        }
    }
}

DnsZoneAging -OutputPath C:\dscDns

Start-DscConfiguration -Path C:\dscDNS -Wait -Force -Verbose

