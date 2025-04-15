$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                         = 'localhost'
            CertificateFile                  = $env:DscPublicCertificatePath

            # Stub zone
            StubZoneName                  = 'dsc.test'
            StubZoneFile                  = 'dsc.test.file.dns'
            StubMasterServers             = '192.168.1.1','192.168.1.2'

        }
    )
}

<#
    .SYNOPSIS
        Creates a file-backed stub zone using the default values for parameters.
#>
configuration DSC_DnsServerStubZone_AddStubZoneUsingDefaultValues_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerStubZone 'Integration_Test'
        {
            Name = $Node.StubZoneName
            MasterServers = $Node.StubMasterServers
        }
    }
}

<#
    .SYNOPSIS
        Removes a file-backed stub zone.

    .NOTES
        This configuration is used multiple times to remove the file-backed stub zone.
#>
configuration DSC_DnsServerStubZone_RemoveStubZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerStubZone 'Integration_Test'
        {
            Ensure = 'Absent'
            Name   = $Node.StubZoneName
            MasterServers = $Node.StubMasterServers
            ZoneFile = $Node.StubZoneFile
        }
    }
}

<#
    .SYNOPSIS
        Creates a file-backed stub zone by specifying values for each parameter.
#>
configuration DSC_DnsServerStubZone_AddForwardZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerStubZone 'Integration_Test'
        {
            Ensure        = 'Present'
            Name          = $Node.StubZoneName
            ZoneFile      = $Node.StubZoneFile
            MasterServers = $Node.StubMasterServers
        }
    }
}
