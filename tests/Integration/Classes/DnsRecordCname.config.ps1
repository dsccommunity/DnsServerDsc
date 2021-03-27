$zoneName = "Cname.test"

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordCname_CreateRecord_Config = @{
            ZoneName      = $zoneName
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
        }
        DnsRecordCname_ModifyRecord_Config = @{
            ZoneName      = $zoneName
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
            DnsServer     = 'localhost'
            TimeToLive    = '05:00:00'
            Ensure        = 'Present'
        }
        DnsRecordCname_DeleteRecord_Config = @{
            ZoneName      = $zoneName
            Name          = 'bar'
            HostNameAlias = 'quarks.contoso.com'
            Ensure        = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        Create an CNAME record
#>
configuration DnsRecordCname_CreateRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordCname 'Integration_Test'
        {
            ZoneName      = $ConfigurationData.NonNodeData.DnsRecordCname_CreateRecord_Config.ZoneName
            Name          = $ConfigurationData.NonNodeData.DnsRecordCname_CreateRecord_Config.Name
            HostNameAlias = $ConfigurationData.NonNodeData.DnsRecordCname_CreateRecord_Config.HostNameAlias
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing CNAME record
#>
configuration DnsRecordCname_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordCname 'Integration_Test'
        {
            ZoneName      = $ConfigurationData.NonNodeData.DnsRecordCname_ModifyRecord_Config.ZoneName
            Name          = $ConfigurationData.NonNodeData.DnsRecordCname_ModifyRecord_Config.Name
            HostNameAlias = $ConfigurationData.NonNodeData.DnsRecordCname_ModifyRecord_Config.HostNameAlias
            DnsServer     = $ConfigurationData.NonNodeData.DnsRecordCname_ModifyRecord_Config.DnsServer
            TimeToLive    = $ConfigurationData.NonNodeData.DnsRecordCname_ModifyRecord_Config.TimeToLive
            Ensure        = $ConfigurationData.NonNodeData.DnsRecordCname_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing CNAME record
#>
configuration DnsRecordCname_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordCname 'Integration_Test'
        {
            ZoneName      = $ConfigurationData.NonNodeData.DnsRecordCname_DeleteRecord_Config.ZoneName
            Name          = $ConfigurationData.NonNodeData.DnsRecordCname_DeleteRecord_Config.Name
            HostNameAlias = $ConfigurationData.NonNodeData.DnsRecordCname_DeleteRecord_Config.HostNameAlias
            Ensure        = $ConfigurationData.NonNodeData.DnsRecordCname_DeleteRecord_Config.Ensure
        }
    }
}
