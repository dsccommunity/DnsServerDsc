$zoneName = "Mx.test"
$zoneScope = 'external'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordMxScoped_CreateRecord_Config = @{
            ZoneName     = $zoneName
            ZoneScope    = $zoneScope
            EmailDomain  = $zoneName
            MailExchange = "mailserver1.$($zoneName)"
            Priority     = 20
        }
        DnsRecordMxScoped_ModifyRecord_Config = @{
            ZoneName     = $zoneName
            ZoneScope    = $zoneScope
            EmailDomain  = $zoneName
            MailExchange = "mailserver1.$($zoneName)"
            Priority     = 200
            DnsServer    = 'localhost'
            TimeToLive   = '05:00:00'
            Ensure       = 'Present'
        }
        DnsRecordMxScoped_DeleteRecord_Config = @{
            ZoneName     = $zoneName
            ZoneScope    = $zoneScope
            EmailDomain  = $zoneName
            MailExchange = "mailserver1.$($zoneName)"
            Priority     = 0
            Ensure       = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an MX record
#>
configuration DnsRecordMxScoped_CreateRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        xDnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordMxScoped 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordMxScoped_CreateRecord_Config.ZoneName
            ZoneScope    = $ConfigurationData.NonNodeData.DnsRecordMxScoped_CreateRecord_Config.ZoneScope
            EmailDomain  = $ConfigurationData.NonNodeData.DnsRecordMxScoped_CreateRecord_Config.EmailDomain
            MailExchange = $ConfigurationData.NonNodeData.DnsRecordMxScoped_CreateRecord_Config.MailExchange
            Priority     = $ConfigurationData.NonNodeData.DnsRecordMxScoped_CreateRecord_Config.Priority
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing MX record
#>
configuration DnsRecordMxScoped_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        xDnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordMxScoped 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordMxScoped_ModifyRecord_Config.ZoneName
            ZoneScope    = $ConfigurationData.NonNodeData.DnsRecordMxScoped_ModifyRecord_Config.ZoneScope
            EmailDomain  = $ConfigurationData.NonNodeData.DnsRecordMxScoped_ModifyRecord_Config.EmailDomain
            MailExchange = $ConfigurationData.NonNodeData.DnsRecordMxScoped_ModifyRecord_Config.MailExchange
            Priority     = $ConfigurationData.NonNodeData.DnsRecordMxScoped_ModifyRecord_Config.Priority
            DnsServer    = $ConfigurationData.NonNodeData.DnsRecordMxScoped_ModifyRecord_Config.DnsServer
            TimeToLive   = $ConfigurationData.NonNodeData.DnsRecordMxScoped_ModifyRecord_Config.TimeToLive
            Ensure       = $ConfigurationData.NonNodeData.DnsRecordMxScoped_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing MX record
#>
configuration DnsRecordMxScoped_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        xDnsServerZoneScope "external scope" {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordMxScoped 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordMxScoped_DeleteRecord_Config.ZoneName
            ZoneScope    = $ConfigurationData.NonNodeData.DnsRecordMxScoped_DeleteRecord_Config.ZoneScope
            EmailDomain  = $ConfigurationData.NonNodeData.DnsRecordMxScoped_DeleteRecord_Config.EmailDomain
            MailExchange = $ConfigurationData.NonNodeData.DnsRecordMxScoped_DeleteRecord_Config.MailExchange
            Priority     = $ConfigurationData.NonNodeData.DnsRecordMxScoped_DeleteRecord_Config.Priority
            Ensure       = $ConfigurationData.NonNodeData.DnsRecordMxScoped_DeleteRecord_Config.Ensure
        }
    }
}
