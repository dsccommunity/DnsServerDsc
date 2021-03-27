$zoneName = "Mx.test"

$ConfigurationData = @{
    AllNodes    = , @{
        NodeName        = 'localhost'
        CertificateFile = $Null
    }
    NonNodeData = @{
        DnsRecordMx_CreateRecord_Config = @{
            ZoneName     = $zoneName
            EmailDomain  = "sub.$zoneName"
            MailExchange = "mailserver1.$($zoneName)"
            Priority     = 20
        }
        DnsRecordMx_ModifyRecord_Config = @{
            ZoneName     = $zoneName
            EmailDomain  = "sub.$zoneName"
            MailExchange = "mailserver1.$($zoneName)"
            Priority     = 200
            DnsServer    = 'localhost'
            TimeToLive   = '05:00:00'
            Ensure       = 'Present'
        }
        DnsRecordMx_DeleteRecord_Config = @{
            ZoneName     = $zoneName
            EmailDomain  = "sub.$zoneName"
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
configuration DnsRecordMx_CreateRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordMx 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordMx_CreateRecord_Config.ZoneName
            EmailDomain  = $ConfigurationData.NonNodeData.DnsRecordMx_CreateRecord_Config.EmailDomain
            MailExchange = $ConfigurationData.NonNodeData.DnsRecordMx_CreateRecord_Config.MailExchange
            Priority     = $ConfigurationData.NonNodeData.DnsRecordMx_CreateRecord_Config.Priority
        }
    }
}

<#
    .SYNOPSIS
        Modifies an existing MX record
#>
configuration DnsRecordMx_ModifyRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordMx 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordMx_ModifyRecord_Config.ZoneName
            EmailDomain  = $ConfigurationData.NonNodeData.DnsRecordMx_ModifyRecord_Config.EmailDomain
            MailExchange = $ConfigurationData.NonNodeData.DnsRecordMx_ModifyRecord_Config.MailExchange
            Priority     = $ConfigurationData.NonNodeData.DnsRecordMx_ModifyRecord_Config.Priority
            DnsServer    = $ConfigurationData.NonNodeData.DnsRecordMx_ModifyRecord_Config.DnsServer
            TimeToLive   = $ConfigurationData.NonNodeData.DnsRecordMx_ModifyRecord_Config.TimeToLive
            Ensure       = $ConfigurationData.NonNodeData.DnsRecordMx_ModifyRecord_Config.Ensure
        }
    }
}

<#
    .SYNOPSIS
        Deletes an existing MX record
#>
configuration DnsRecordMx_DeleteRecord_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone "Zone $zoneName"
        {
            Name = $zoneName
        }

        DnsRecordMx 'Integration_Test'
        {
            ZoneName     = $ConfigurationData.NonNodeData.DnsRecordMx_DeleteRecord_Config.ZoneName
            EmailDomain  = $ConfigurationData.NonNodeData.DnsRecordMx_DeleteRecord_Config.EmailDomain
            MailExchange = $ConfigurationData.NonNodeData.DnsRecordMx_DeleteRecord_Config.MailExchange
            Priority     = $ConfigurationData.NonNodeData.DnsRecordMx_DeleteRecord_Config.Priority
            Ensure       = $ConfigurationData.NonNodeData.DnsRecordMx_DeleteRecord_Config.Ensure
        }
    }
}
