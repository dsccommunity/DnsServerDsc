$ConfigurationData = @{
    AllNodes    = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath
        }
    )

    NonNodeData = @{
        MasterServers                                                  = '192.168.1.1', '192.168.1.2'
        DSC_DnsServerConditionalForwarder_NoChange_Config            = @{
            Ensure   = 'Present'
            ZoneName = 'nochange.none'
        }

        DSC_DnsServerConditionalForwarder_FixIncorrectMasters_Config = @{
            Ensure   = 'Present'
            ZoneName = 'fixincorrectmasters.none'
        }

        DSC_DnsServerConditionalForwarder_ReplacePrimary_Config      = @{
            Ensure   = 'Present'
            ZoneName = 'replaceprimary.none'
        }

        DSC_DnsServerConditionalForwarder_CreateNew_Config           = @{
            Ensure   = 'Present'
            ZoneName = 'createnew.none'
        }

        DSC_DnsServerConditionalForwarder_RemoveExisting_Config      = @{
            Ensure   = 'Absent'
            ZoneName = 'removeexisting.none'
        }

        DSC_DnsServerConditionalForwarder_IgnorePrimary_Config       = @{
            Ensure   = 'Absent'
            ZoneName = 'ignoreprimary.none'
        }

        DSC_DnsServerConditionalForwarder_DoNothing_Config           = @{
            Ensure   = 'Absent'
            ZoneName = 'donothing.none'
        }
    }
}

<#
    .SYNOPSIS
        Tests no action is taken on a correctly configured zone.
#>
configuration DSC_DnsServerConditionalForwarder_NoChange_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure        = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_NoChange_Config.Ensure
            Name          = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_NoChange_Config.ZoneName
            MasterServers = $ConfigurationData.NonNodeData.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Tests master servers on an existing zone are corrected.
#>
configuration DSC_DnsServerConditionalForwarder_FixIncorrectMasters_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure        = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_FixIncorrectMasters_Config.Ensure
            Name          = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_FixIncorrectMasters_Config.ZoneName
            MasterServers = $ConfigurationData.NonNodeData.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Tests an existing primary zone can be replaced with a conditional forwarder.
#>
configuration DSC_DnsServerConditionalForwarder_ReplacePrimary_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure        = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_ReplacePrimary_Config.Ensure
            Name          = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_ReplacePrimary_Config.ZoneName
            MasterServers = $ConfigurationData.NonNodeData.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Creates a new conditional forwarder.
#>
configuration DSC_DnsServerConditionalForwarder_CreateNew_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure        = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_CreateNew_Config.Ensure
            Name          = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_CreateNew_Config.ZoneName
            MasterServers = $ConfigurationData.NonNodeData.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Removes an existing conditional forwarder.
#>
configuration DSC_DnsServerConditionalForwarder_RemoveExisting_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_RemoveExisting_Config.Ensure
            Name   = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_RemoveExisting_Config.ZoneName
        }
    }
}

<#
    .SYNOPSIS
        Ignores a primary zone of the same name when ensuring a conditional zone is absent.
#>
configuration DSC_DnsServerConditionalForwarder_IgnorePrimary_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_IgnorePrimary_Config.Ensure
            Name   = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_IgnorePrimary_Config.ZoneName
        }
    }
}

<#
    .SYNOPSIS
        Does nothing when the zone does not exist.
#>
configuration DSC_DnsServerConditionalForwarder_DoNothing_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_DoNothing_Config.Ensure
            Name   = $ConfigurationData.NonNodeData.DSC_DnsServerConditionalForwarder_DoNothing_Config.ZoneName
        }
    }
}
