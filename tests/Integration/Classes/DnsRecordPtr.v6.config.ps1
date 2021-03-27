$zoneName = '0.0.d.f.ip6.arpa'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordPtr_CreateRecord_Config_v6 = @{
            ZoneName  = $zoneName
            IpAddress = 'fd00::515c:0:0:d59'
            Name      = 'quarks.contoso.com'
        }
        DnsRecordPtr_ModifyRecord_Config_v6 = @{
            ZoneName  = $zoneName
            IpAddress = 'fd00::515c:0:0:d59'
            Name      = 'quarks.contoso.com'
            DnsServer = 'localhost'
            TimeToLive = '05:00:00'
            Ensure    = 'Present'
        }
        DnsRecordPtr_DeleteRecord_Config_v6 = @{
            ZoneName  = $zoneName
            IpAddress = 'fd00::515c:0:0:d59'
            Name      = 'quarks.contoso.com'
            Ensure    = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an IPv6 PTR record
#>
configuration DnsRecordPtr_CreateRecord_Config_v6
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordPtr 'Integration_Test'
        {
            ZoneName  = $ConfigurationData.NonNodeData.DnsRecordPtr_CreateRecord_Config_v6.ZoneName
            IpAddress = $ConfigurationData.NonNodeData.DnsRecordPtr_CreateRecord_Config_v6.IpAddress
            Name      = $ConfigurationData.NonNodeData.DnsRecordPtr_CreateRecord_Config_v6.Name
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing IPv6 PTR record
#>
configuration DnsRecordPtr_ModifyRecord_Config_v6
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordPtr 'Integration_Test'
        {
            ZoneName  = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config_v6.ZoneName
            IpAddress = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config_v6.IpAddress
            Name      = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config_v6.Name
            DnsServer = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config_v6.DnsServer
            TimeToLive = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config_v6.TimeToLive
            Ensure    = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config_v6.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing IPv6 PTR record
#>
configuration DnsRecordPtr_DeleteRecord_Config_v6
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordPtr 'Integration_Test'
        {
            ZoneName  = $ConfigurationData.NonNodeData.DnsRecordPtr_DeleteRecord_Config_v6.ZoneName
            IpAddress = $ConfigurationData.NonNodeData.DnsRecordPtr_DeleteRecord_Config_v6.IpAddress
            Name      = $ConfigurationData.NonNodeData.DnsRecordPtr_DeleteRecord_Config_v6.Name
            Ensure    = $ConfigurationData.NonNodeData.DnsRecordPtr_DeleteRecord_Config_v6.Ensure
        }
    }
}
