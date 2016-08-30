configuration Sample_DnsSettings
{
    Import-DscResource -ModuleName xDnsServer

    node localhost
    {
        xDnsServerSetting DnsServerProperties
        {
            Name = 'DnsServerSetting'
            ListenAddresses = '10.0.0.4'
            IsSlave = $true
            Forwarders = '168.63.129.16','8.8.8.8'
            RoundRobin = $true
            LocalNetPriority = $true
            SecureResponses = $true
            NoRecursion = $false
            BindSecondaries = $false
            StrictFileParsing = $false
            ScavengingInterval = 168
            LogLevel = 50393905
        }
    }
}

Sample_DnsSettings
