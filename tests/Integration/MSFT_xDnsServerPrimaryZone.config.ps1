<#
    .NOTES
        More information about subnetted reverse lookup can be found here
        https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-subnetted-reverse-lookup-zone
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                         = 'localhost'
            CertificateFile                  = $env:DscPublicCertificatePath

            # Forward zone
            ForwardZoneName                  = 'dsc.test'
            ForwardZoneFile                  = 'dsc.test.file.dns'
            ForwardZoneDynamicUpdate         = 'NonSecureAndSecure'

            # Classful reverse zone
            ClassfulReverseZoneName          = '1.168.192.in-addr.arpa'
            ClassfulReverseZoneFile          = '1.168.192.in-addr.arpa.dns'
            ClassfulReverseZoneDynamicUpdate = 'None'
        }
    )
}

<#
    .SYNOPSIS
        Creates a file-backed primary zone using the default values for parameters.
#>
configuration MSFT_xDnsServerPrimaryZone_AddForwardZoneUsingDefaultValues_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone 'Integration_Test'
        {
            Name          = $Node.ForwardZoneName
        }
    }
}

<#
    .SYNOPSIS
        Removes a file-backed primary zone.

    .NOTES
        This configuration is used multiple times to remove the  file-backed
        primary zone.
#>
configuration MSFT_xDnsServerPrimaryZone_RemoveForwardZone_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone 'Integration_Test'
        {
            Ensure        = 'Absent'
            Name          = $Node.ForwardZoneName
        }
    }
}

<#
    .SYNOPSIS
        Creates a file-backed primary zone using by specifying values for each
        parameter.
#>
configuration MSFT_xDnsServerPrimaryZone_AddForwardZone_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerPrimaryZone 'Integration_Test'
        {
            Ensure        = 'Present'
            Name          = $Node.ForwardZoneName
            ZoneFile      = $Node.ForwardZoneFile
            DynamicUpdate = $Node.ForwardZoneDynamicUpdate
        }
    }
}