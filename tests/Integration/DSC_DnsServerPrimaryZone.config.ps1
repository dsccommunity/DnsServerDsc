<#
    .NOTES
        More information about subnetted reverse lookup zone can be found here
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
            ClassfulReverseZoneDynamicUpdate = 'NonSecureAndSecure'

            # Classless reverse zone
            ClasslessReverseZoneName         = '64-26.100.168.192.in-addr.arpa'
        }
    )
}

<#
    .SYNOPSIS
        Creates a file-backed primary zone using the default values for parameters.
#>
configuration DSC_DnsServerPrimaryZone_AddForwardZoneUsingDefaultValues_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'Integration_Test'
        {
            Name = $Node.ForwardZoneName
        }
    }
}

<#
    .SYNOPSIS
        Removes a file-backed primary zone.

    .NOTES
        This configuration is used multiple times to remove the file-backed
        primary zone.
#>
configuration DSC_DnsServerPrimaryZone_RemoveForwardZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'Integration_Test'
        {
            Ensure = 'Absent'
            Name   = $Node.ForwardZoneName
        }
    }
}

<#
    .SYNOPSIS
        Creates a file-backed primary zone by specifying values for each parameter.
#>
configuration DSC_DnsServerPrimaryZone_AddForwardZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'Integration_Test'
        {
            Ensure        = 'Present'
            Name          = $Node.ForwardZoneName
            ZoneFile      = $Node.ForwardZoneFile
            DynamicUpdate = $Node.ForwardZoneDynamicUpdate
        }
    }
}

<#
    .SYNOPSIS
        Creates a file-backed classful reverse primary zone by specifying values
        for each parameter.
#>
configuration DSC_DnsServerPrimaryZone_AddClassfulReverseZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'Integration_Test'
        {
            Ensure        = 'Present'
            Name          = $Node.ClassfulReverseZoneName
            ZoneFile      = $Node.ClassfulReverseZoneFile
            DynamicUpdate = $Node.ClassfulReverseZoneDynamicUpdate
        }
    }
}

<#
    .SYNOPSIS
        Creates a file-backed classful reverse primary zone by specifying values
        for each parameter.
#>
configuration DSC_DnsServerPrimaryZone_RemoveClassfulReverseZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'Integration_Test'
        {
            Ensure = 'Absent'
            Name   = $Node.ClassfulReverseZoneName
        }
    }
}

<#
    .SYNOPSIS
        Creates a file-backed classless reverse primary zone by using default values.
#>
configuration DSC_DnsServerPrimaryZone_AddClasslessReverseZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'Integration_Test'
        {
            Name = $Node.ClasslessReverseZoneName
        }
    }
}

<#
    .SYNOPSIS
        Creates a file-backed classful reverse primary zone by specifying values
        for each parameter.
#>
configuration DSC_DnsServerPrimaryZone_RemoveClasslessReverseZone_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerPrimaryZone 'Integration_Test'
        {
            Ensure = 'Absent'
            Name   = $Node.ClasslessReverseZoneName
        }
    }
}
