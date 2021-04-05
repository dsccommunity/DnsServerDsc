$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath
        }
    )
}

<#
    .SYNOPSIS
        Test the property Enable setting, set to $false.
#>
configuration DnsServerRecursion_DisableRecursion_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerRecursion 'Integration_Test'
        {
            DnsServer = 'localhost'
            Enable    = $false
        }
    }
}

<#
    .SYNOPSIS
        Test the property Enable setting, set to $true.
#>
configuration DnsServerRecursion_EnableRecursion_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerRecursion 'Integration_Test'
        {
            DnsServer = 'localhost'
            Enable    = $true
        }
    }
}

<#
    .SYNOPSIS
        Test the property AdditionalTimeout setting, set to 5.
#>
configuration DnsServerRecursion_SetAdditionalTimeout_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerRecursion 'Integration_Test'
        {
            DnsServer         = 'localhost'
            AdditionalTimeout = 5
        }
    }
}

<#
    .SYNOPSIS
        Test the property RetryInterval setting, set to 4.
#>
configuration DnsServerRecursion_SetRetryInterval_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerRecursion 'Integration_Test'
        {
            DnsServer     = 'localhost'
            RetryInterval = 4
        }
    }
}

<#
    .SYNOPSIS
        Test the property Timeout setting, set to 9.
#>
configuration DnsServerRecursion_SetTimeout_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerRecursion 'Integration_Test'
        {
            DnsServer = 'localhost'
            Timeout   = 9
        }
    }
}
