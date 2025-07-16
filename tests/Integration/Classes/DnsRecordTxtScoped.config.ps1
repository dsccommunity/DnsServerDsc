$zoneName = 'TxtScoped.test'
$zoneScope = 'external'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordTxtScoped_CreateRecord_Config = @{
            ZoneName        = $zoneName
            ZoneScope       = $zoneScope
            Name            = 'test'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
        }
        DnsRecordTxtScoped_ModifyRecord_Config = @{
            ZoneName        = $zoneName
            ZoneScope       = $zoneScope
            Name            = 'test'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
            DnsServer       = 'localhost'
            TimeToLive      = '05:00:00'
            Ensure          = 'Present'
        }
        DnsRecordTxtScoped_DeleteRecord_Config = @{
            ZoneName        = $zoneName
            ZoneScope       = $zoneScope
            Name            = 'test'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
            Ensure          = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an Txt Scoped record
#>
configuration DnsRecordTxtScoped_CreateRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope 'external scope' {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordTxtScoped 'Integration_Test'
        {
            ZoneName        = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_CreateRecord_Config.ZoneName
            ZoneScope       = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_CreateRecord_Config.ZoneScope
            Name            = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_CreateRecord_Config.Name
            DescriptiveText = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_CreateRecord_Config.DescriptiveText
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing Txt Scoped record
#>
configuration DnsRecordTxtScoped_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope 'external scope' {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordTxtScoped 'Integration_Test'
        {
            ZoneName        = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_ModifyRecord_Config.ZoneName
            ZoneScope       = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_ModifyRecord_Config.ZoneScope
            Name            = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_ModifyRecord_Config.Name
            DescriptiveText = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_ModifyRecord_Config.DescriptiveText
            DnsServer       = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_ModifyRecord_Config.DnsServer
            TimeToLive      = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_ModifyRecord_Config.TimeToLive
            Ensure          = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing Txt Scoped record
#>
configuration DnsRecordTxtScoped_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsServerZoneScope 'external scope' {
            ZoneName = $zoneName
            Name     = $zoneScope
        }

        DnsRecordTxtScoped 'Integration_Test'
        {
            ZoneName        = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_DeleteRecord_Config.ZoneName
            ZoneScope       = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_DeleteRecord_Config.ZoneScope
            Name            = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_DeleteRecord_Config.Name
            DescriptiveText = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_DeleteRecord_Config.DescriptiveText
            Ensure          = $ConfigurationData.NonNodeData.DnsRecordTxtScoped_DeleteRecord_Config.Ensure
        }
    }
}
