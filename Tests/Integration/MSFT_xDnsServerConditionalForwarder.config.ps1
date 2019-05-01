configuration MSFT_xDnsServerConditionalForwarder_config {
    Import-DscResource -ModuleName xDnsServer

    node localhost
    {
        WindowsFeature InstallDns
        {
            Name                 = 'DNS'
            Ensure               = 'Present'
            IncludeAllSubFeature = $true
        }

        xDnsServerConditionalForwarder present.example {
            Ensure        = 'Present'
            Name          = 'present.example'
            MasterServers = '192.168.1.1', '192.168.1.2'
        }

        xDnsServerConditionalForwarder absent.example {
            Ensure = 'Absent'
            Name   = 'absent.example'
        }
    }
}
