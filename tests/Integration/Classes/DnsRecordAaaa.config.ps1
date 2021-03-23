$zoneName = "Aaaa.test"

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordAaaa_CreateRecord_Config = @{
            ZoneName    = $zoneName
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
        }
        DnsRecordAaaa_ModifyRecord_Config = @{
            ZoneName    = $zoneName
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
            DnsServer   = 'localhost'
            TimeToLive  = '05:00:00'
            Ensure      = 'Present'
        }
        DnsRecordAaaa_DeleteRecord_Config = @{
            ZoneName    = $zoneName
            Name        = 'www'
            IPv6Address = '2001:db8:85a3::8a2e:370:7334'
            Ensure      = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an AAAA record
#>
configuration DnsRecordAaaa_CreateRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordAaaa 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAaaa_CreateRecord_Config.ZoneName
            Name        = $ConfigurationData.NonNodeData.DnsRecordAaaa_CreateRecord_Config.Name
            IPv6Address = $ConfigurationData.NonNodeData.DnsRecordAaaa_CreateRecord_Config.IPv6Address
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing AAAA record
#>
configuration DnsRecordAaaa_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordAaaa 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAaaa_ModifyRecord_Config.ZoneName
            Name        = $ConfigurationData.NonNodeData.DnsRecordAaaa_ModifyRecord_Config.Name
            IPv6Address = $ConfigurationData.NonNodeData.DnsRecordAaaa_ModifyRecord_Config.IPv6Address
            DnsServer   = $ConfigurationData.NonNodeData.DnsRecordAaaa_ModifyRecord_Config.DnsServer
            TimeToLive  = $ConfigurationData.NonNodeData.DnsRecordAaaa_ModifyRecord_Config.TimeToLive
            Ensure      = $ConfigurationData.NonNodeData.DnsRecordAaaa_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing AAAA record
#>
configuration DnsRecordAaaa_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordAaaa 'Integration_Test'
        {
            ZoneName    = $ConfigurationData.NonNodeData.DnsRecordAaaa_DeleteRecord_Config.ZoneName
            Name        = $ConfigurationData.NonNodeData.DnsRecordAaaa_DeleteRecord_Config.Name
            IPv6Address = $ConfigurationData.NonNodeData.DnsRecordAaaa_DeleteRecord_Config.IPv6Address
            Ensure      = $ConfigurationData.NonNodeData.DnsRecordAaaa_DeleteRecord_Config.Ensure
        }
    }
}
