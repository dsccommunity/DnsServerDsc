$zoneName = 'Txt.test'

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordTxt_CreateRecord_Config = @{
            ZoneName        = $zoneName
            Name            = 'test'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
        }
        DnsRecordTxt_ModifyRecord_Config = @{
            ZoneName        = $zoneName
            Name            = 'test'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
            DnsServer       = 'localhost'
            TimeToLive      = '05:00:00'
            Ensure          = 'Present'
        }
        DnsRecordTxt_DeleteRecord_Config = @{
            ZoneName        = $zoneName
            Name            = 'test'
            DescriptiveText = 'Example text for test.contoso.com TXT record.'
            Ensure          = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an Txt record
#>
configuration DnsRecordTxt_CreateRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordTxt 'Integration_Test'
        {
            ZoneName        = $ConfigurationData.NonNodeData.DnsRecordTxt_CreateRecord_Config.ZoneName
            Name            = $ConfigurationData.NonNodeData.DnsRecordTxt_CreateRecord_Config.Name
            DescriptiveText = $ConfigurationData.NonNodeData.DnsRecordTxt_CreateRecord_Config.DescriptiveText
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing Txt record
#>
configuration DnsRecordTxt_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordTxt 'Integration_Test'
        {
            ZoneName        = $ConfigurationData.NonNodeData.DnsRecordTxt_ModifyRecord_Config.ZoneName
            Name            = $ConfigurationData.NonNodeData.DnsRecordTxt_ModifyRecord_Config.Name
            DescriptiveText = $ConfigurationData.NonNodeData.DnsRecordTxt_ModifyRecord_Config.DescriptiveText
            DnsServer       = $ConfigurationData.NonNodeData.DnsRecordTxt_ModifyRecord_Config.DnsServer
            TimeToLive      = $ConfigurationData.NonNodeData.DnsRecordTxt_ModifyRecord_Config.TimeToLive
            Ensure          = $ConfigurationData.NonNodeData.DnsRecordTxt_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing Txt record
#>
configuration DnsRecordTxt_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordTxt 'Integration_Test'
        {
            ZoneName        = $ConfigurationData.NonNodeData.DnsRecordTxt_DeleteRecord_Config.ZoneName
            Name            = $ConfigurationData.NonNodeData.DnsRecordTxt_DeleteRecord_Config.Name
            DescriptiveText = $ConfigurationData.NonNodeData.DnsRecordTxt_DeleteRecord_Config.DescriptiveText
            Ensure          = $ConfigurationData.NonNodeData.DnsRecordTxt_DeleteRecord_Config.Ensure
        }
    }
}
