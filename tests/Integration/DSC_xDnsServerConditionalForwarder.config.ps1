$ConfigurationData = @{
    AllNodes    = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath
        }
    )

    NonNodeData = @{
        MasterServers                                                  = '192.168.1.1', '192.168.1.2'
        DSC_xDnsServerConditionalForwarder_NoChange_Config            = @{
            Ensure   = 'Present'
            ZoneName = 'nochange.none'
        }

        DSC_xDnsServerConditionalForwarder_FixIncorrectMasters_Config = @{
            Ensure   = 'Present'
            ZoneName = 'fixincorrectmasters.none'
        }

        DSC_xDnsServerConditionalForwarder_ReplacePrimary_Config      = @{
            Ensure   = 'Present'
            ZoneName = 'replaceprimary.none'
        }

        DSC_xDnsServerConditionalForwarder_CreateNew_Config           = @{
            Ensure   = 'Present'
            ZoneName = 'createnew.none'
        }

        DSC_xDnsServerConditionalForwarder_RemoveExisting_Config      = @{
            Ensure   = 'Absent'
            ZoneName = 'removeexisting.none'
        }

        DSC_xDnsServerConditionalForwarder_IgnorePrimary_Config       = @{
            Ensure   = 'Absent'
            ZoneName = 'ignoreprimary.none'
        }

        DSC_xDnsServerConditionalForwarder_DoNothing_Config           = @{
            Ensure   = 'Absent'
            ZoneName = 'donothing.none'
        }
    }
}

<#
    .SYNOPSIS
        Tests no action is taken on a correctly configured zone.
#>
configuration DSC_xDnsServerConditionalForwarder_NoChange_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure        = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_NoChange_Config.Ensure
            Name          = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_NoChange_Config.ZoneName
            MasterServers = $ConfigurationData.NonNodeData.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Tests master servers on an existing zone are corrected.
#>
configuration DSC_xDnsServerConditionalForwarder_FixIncorrectMasters_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure        = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_FixIncorrectMasters_Config.Ensure
            Name          = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_FixIncorrectMasters_Config.ZoneName
            MasterServers = $ConfigurationData.NonNodeData.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Tests an existing primary zone can be replaced with a conditional forwarder.
#>
configuration DSC_xDnsServerConditionalForwarder_ReplacePrimary_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure        = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_ReplacePrimary_Config.Ensure
            Name          = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_ReplacePrimary_Config.ZoneName
            MasterServers = $ConfigurationData.NonNodeData.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Creates a new conditional forwarder.
#>
configuration DSC_xDnsServerConditionalForwarder_CreateNew_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure        = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_CreateNew_Config.Ensure
            Name          = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_CreateNew_Config.ZoneName
            MasterServers = $ConfigurationData.NonNodeData.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Removes an existing conditional forwarder.
#>
configuration DSC_xDnsServerConditionalForwarder_RemoveExisting_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_RemoveExisting_Config.Ensure
            Name   = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_RemoveExisting_Config.ZoneName
        }
    }
}

<#
    .SYNOPSIS
        Ignores a primary zone of the same name when ensuring a conditional zone is absent.
#>
configuration DSC_xDnsServerConditionalForwarder_IgnorePrimary_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_IgnorePrimary_Config.Ensure
            Name   = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_IgnorePrimary_Config.ZoneName
        }
    }
}

<#
    .SYNOPSIS
        Does nothing when the zone does not exist.
#>
configuration DSC_xDnsServerConditionalForwarder_DoNothing_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test'
        {
            Ensure = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_DoNothing_Config.Ensure
            Name   = $ConfigurationData.NonNodeData.DSC_xDnsServerConditionalForwarder_DoNothing_Config.ZoneName
        }
    }
}
