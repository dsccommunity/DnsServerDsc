$zoneName = "0.168.192.in-addr.arpa"

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordPtr_CreateRecord_Config = @{
            ZoneName  = $zoneName
            IpAddress = '192.168.0.9'
            Name      = 'quarks.contoso.com'
        }
        DnsRecordPtr_ModifyRecord_Config = @{
            ZoneName  = $zoneName
            IpAddress = '192.168.0.9'
            Name      = 'quarks.contoso.com'
            DnsServer = 'localhost'
            TimeToLive = '05:00:00'
            Ensure    = 'Present'
        }
        DnsRecordPtr_DeleteRecord_Config = @{
            ZoneName  = $zoneName
            IpAddress = '192.168.0.9'
            Name      = 'quarks.contoso.com'
            Ensure    = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an PTR record
#>
configuration DnsRecordPtr_CreateRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordPtr 'Integration_Test'
        {
            ZoneName  = $ConfigurationData.NonNodeData.DnsRecordPtr_CreateRecord_Config.ZoneName
            IpAddress = $ConfigurationData.NonNodeData.DnsRecordPtr_CreateRecord_Config.IpAddress
            Name      = $ConfigurationData.NonNodeData.DnsRecordPtr_CreateRecord_Config.Name
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing PTR record
#>
configuration DnsRecordPtr_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordPtr 'Integration_Test'
        {
            ZoneName  = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config.ZoneName
            IpAddress = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config.IpAddress
            Name      = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config.Name
            DnsServer = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config.DnsServer
            TimeToLive = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config.TimeToLive
            Ensure    = $ConfigurationData.NonNodeData.DnsRecordPtr_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing PTR record
#>
configuration DnsRecordPtr_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordPtr 'Integration_Test'
        {
            ZoneName  = $ConfigurationData.NonNodeData.DnsRecordPtr_DeleteRecord_Config.ZoneName
            IpAddress = $ConfigurationData.NonNodeData.DnsRecordPtr_DeleteRecord_Config.IpAddress
            Name      = $ConfigurationData.NonNodeData.DnsRecordPtr_DeleteRecord_Config.Name
            Ensure    = $ConfigurationData.NonNodeData.DnsRecordPtr_DeleteRecord_Config.Ensure
        }
    }
}
