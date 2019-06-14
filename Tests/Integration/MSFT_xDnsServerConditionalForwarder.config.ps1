#region HEADER
# Integration Test Config Template Version: 1.2.1
#endregion

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName          = 'localhost'
            ConfigurationName = 'MSFT_xDnsServerConditionalForwarder_NoChange_Config'
            CertificateFile   = $env:DscPublicCertificatePath
            Ensure            = 'Present'
            ZoneName          = 'nochange.example'
            MasterServers     = '192.168.1.1', '192.168.1.2'
        }
        @{
            NodeName          = 'localhost'
            ConfigurationName = 'MSFT_xDnsServerConditionalForwarder_FixIncorrectMasters_Config'
            CertificateFile   = $env:DscPublicCertificatePath
            Ensure            = 'Present'
            ZoneName          = 'fixincorrectmasters.example'
            MasterServers     = '192.168.1.1', '192.168.1.2'
        }
        @{
            NodeName          = 'localhost'
            ConfigurationName = 'MSFT_xDnsServerConditionalForwarder_ReplacePrimary_Config'
            CertificateFile   = $env:DscPublicCertificatePath
            Ensure            = 'Present'
            ZoneName          = 'replaceprimary.example'
            MasterServers     = '192.168.1.1', '192.168.1.2'
        }
        @{
            NodeName          = 'localhost'
            ConfigurationName = 'MSFT_xDnsServerConditionalForwarder_CreateNew_Config'
            CertificateFile   = $env:DscPublicCertificatePath
            Ensure            = 'Present'
            ZoneName          = 'createnew.example'
            MasterServers     = '192.168.1.1', '192.168.1.2'
        }
        @{
            NodeName          = 'localhost'
            ConfigurationName = 'MSFT_xDnsServerConditionalForwarder_RemoveExisting_Config'
            CertificateFile   = $env:DscPublicCertificatePath
            Ensure            = 'Absent'
            ZoneName          = 'removeexisting.example'
        }
        @{
            NodeName          = 'localhost'
            ConfigurationName = 'MSFT_xDnsServerConditionalForwarder_IgnorePrimary_Config'
            CertificateFile   = $env:DscPublicCertificatePath
            Ensure            = 'Absent'
            ZoneName          = 'ignoreprimary.example'
        }
        @{
            NodeName          = 'localhost'
            ConfigurationName = 'MSFT_xDnsServerConditionalForwarder_DoNothing_Config'
            CertificateFile   = $env:DscPublicCertificatePath
            Ensure            = 'Absent'
            ZoneName          = 'donothing.example'
        }
    )
}

<#
    .SYNOPSIS
        Tests no action is taken on a correctly configured zone.
#>
$con
configuration MSFT_xDnsServerConditionalForwarder_NoChange_Config {
    Import-DscResource -ModuleName xDnsServer

    node $AllNodes.Where{ $_.ConfigurationName -eq 'MSFT_xDnsServerConditionalForwarder_NoChange_Config' }.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test' {
            Ensure        = $Node.Ensure
            Name          = $Node.ZoneName
            MasterServers = $Node.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Tests master servers on an existing zone are corrected.
#>
configuration MSFT_xDnsServerConditionalForwarder_FixIncorrectMasters_Config {
    Import-DscResource -ModuleName xDnsServer

    node $AllNodes.Where{ $_.ConfigurationName -eq 'MSFT_xDnsServerConditionalForwarder_FixIncorrectMasters_Config' }.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test' {
            Ensure        = $Node.Ensure
            Name          = $Node.ZoneName
            MasterServers = $Node.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Tests an existing primary zone can be replaced with a conditional forwarder.
#>
configuration MSFT_xDnsServerConditionalForwarder_ReplacePrimary_Config {
    Import-DscResource -ModuleName xDnsServer

    node $AllNodes.Where{ $_.ConfigurationName -eq 'MSFT_xDnsServerConditionalForwarder_ReplacePrimary_Config' }.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test' {
            Ensure        = $Node.Ensure
            Name          = $Node.ZoneName
            MasterServers = $Node.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Creates a new conditional forwarder.
#>
configuration MSFT_xDnsServerConditionalForwarder_CreateNew_Config {
    Import-DscResource -ModuleName xDnsServer

    node $AllNodes.Where{ $_.ConfigurationName -eq 'MSFT_xDnsServerConditionalForwarder_CreateNew_Config' }.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test' {
            Ensure        = $Node.Ensure
            Name          = $Node.ZoneName
            MasterServers = $Node.MasterServers
        }
    }
}

<#
    .SYNOPSIS
        Removes an existing conditional forwarder.
#>
configuration MSFT_xDnsServerConditionalForwarder_RemoveExisting_Config {
    Import-DscResource -ModuleName xDnsServer

    node $AllNodes.Where{ $_.ConfigurationName -eq 'MSFT_xDnsServerConditionalForwarder_RemoveExisting_Config' }.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test' {
            Ensure = $Node.Ensure
            Name   = $Node.ZoneName
        }
    }
}

<#
    .SYNOPSIS
        Ignores a primary zone of the same name when ensuring a conditional zone is absent.
#>
configuration MSFT_xDnsServerConditionalForwarder_IgnorePrimary_Config {
    Import-DscResource -ModuleName xDnsServer

    node $AllNodes.Where{ $_.ConfigurationName -eq 'MSFT_xDnsServerConditionalForwarder_IgnorePrimary_Config' }.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test' {
            Ensure = $Node.Ensure
            Name   = $Node.ZoneName
        }
    }
}

<#
    .SYNOPSIS
        Does nothing when the zone does not exist.
#>
configuration MSFT_xDnsServerConditionalForwarder_DoNothing_Config {
    Import-DscResource -ModuleName xDnsServer

    node $AllNodes.Where{ $_.ConfigurationName -eq 'MSFT_xDnsServerConditionalForwarder_DoNothing_Config' }.NodeName
    {
        xDnsServerConditionalForwarder 'Integration_Test' {
            Ensure = $Node.Ensure
            Name   = $Node.ZoneName
        }
    }
}
