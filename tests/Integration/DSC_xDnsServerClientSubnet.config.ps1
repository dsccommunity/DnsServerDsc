$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        Allows reading the configuration data from a JSON file, for real testing
        scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName        = 'localhost'
                CertificateFile = $env:DscPublicCertificatePath
            }
        )
    }
}

<#
    .SYNOPSIS
        This configuration will add a Client Subnet to the DNS Server
#>
Configuration DSC_xDnsServerClientSubnet_AddIPv4Subnet_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node $AllNodes.NodeName
    {
        xDnsServerClientSubnet 'Integration_Test'
        {
            Name       = 'ClientSubnetA'
            IPv4Subnet = '10.1.1.0/24'
            Ensure     = 'Present'
        }
    }
}

<#
    .SYNOPSIS
        This configuration will change the Client Subnet on the DNS Server
#>
Configuration DSC_xDnsServerClientSubnet_ChangeIPv4Subnet_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node $AllNodes.NodeName
    {
        xDnsServerClientSubnet 'Integration_Test'
        {
            Name       = 'ClientSubnetA'
            IPv4Subnet = '10.1.2.0/24'
            Ensure     = 'Present'
        }
    }
}

<#
    .SYNOPSIS
        This configuration will change the Client Subnet on the DNS Server to an array
#>
Configuration DSC_xDnsServerClientSubnet_ArrayIPv4Subnet_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node $AllNodes.NodeName
    {
        xDnsServerClientSubnet 'Integration_Test'
        {
            Name       = 'ClientSubnetA'
            IPv4Subnet = '10.1.1.0/24','10.1.2.0/24'
            Ensure     = 'Present'
        }
    }
}

<#
    .SYNOPSIS
        This configuration will remove the Client Subnet on the DNS Server to an array
#>
Configuration DSC_xDnsServerClientSubnet_RemoveIPv4Subnet_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node $AllNodes.NodeName
    {
        xDnsServerClientSubnet 'Integration_Test'
        {
            Name       = 'ClientSubnetA'
            Ensure     = 'Absent'
        }
    }
}

<#
    .SYNOPSIS
        This configuration will add a Client Subnet to the DNS Server
#>
Configuration DSC_xDnsServerClientSubnet_AddIPv6Subnet_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node $AllNodes.NodeName
    {
        xDnsServerClientSubnet 'Integration_Test'
        {
            Name       = 'ClientSubnetA'
            IPv6Subnet = 'db8::1/28'
            Ensure     = 'Present'
        }
    }
}

<#
    .SYNOPSIS
        This configuration will add a Client Subnet to the DNS Server
#>
Configuration DSC_xDnsServerClientSubnet_ChangeIPv6Subnet_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node $AllNodes.NodeName
    {
        xDnsServerClientSubnet 'Integration_Test'
        {
            Name       = 'ClientSubnetA'
            IPv6Subnet = '2001:db8::/32'
            Ensure     = 'Present'
        }
    }
}

<#
    .SYNOPSIS
        This configuration will add an array of IPv6 Client Subnet to the DNS Server
#>
Configuration DSC_xDnsServerClientSubnet_ArrayIPv6Subnet_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node $AllNodes.NodeName
    {
        xDnsServerClientSubnet 'Integration_Test'
        {
            Name       = 'ClientSubnetA'
            IPv6Subnet = '2001:db8::/32', 'db8::1/28'
            Ensure     = 'Present'
        }
    }
}

<#
    .SYNOPSIS
        This configuration will remove the IPv6 Client Subnet to the DNS Server
#>
Configuration DSC_xDnsServerClientSubnet_RemoveIPv6Subnet_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node $AllNodes.NodeName
    {
        xDnsServerClientSubnet 'Integration_Test'
        {
            Name       = 'ClientSubnetA'
            Ensure     = 'Absent'
        }
    }
}
