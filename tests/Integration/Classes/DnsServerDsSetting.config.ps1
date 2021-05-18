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
        Sets the Directory Partition AutoEnlist Interval.
#>
configuration DnsServerDsSetting_DirectoryPartitionAutoEnlistInterval_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer    = 'localhost'
            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
        }
    }
}

<#
    .SYNOPSIS
        Configure the Lazy Update Interval.
#>
configuration DnsServerDsSetting_LazyUpdateInterval_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer    = 'localhost'
            LazyUpdateInterval = 3
        }
    }
}

<#
    .SYNOPSIS
        Configures the Minimum Background Load Threads.
#>
configuration DnsServerDsSetting_MinimumBackgroundLoadThreads_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer       = 'localhost'
            MinimumBackgroundLoadThreads = 1
        }
    }
}

<#
    .SYNOPSIS
        Configures the Polling Interval.
#>
configuration DnsServerDsSetting_PollingInterval_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer       = 'localhost'
            PollingInterval = 180
        }
    }
}

<#
    .SYNOPSIS
        Configure the Remote Replication Delay.
#>
configuration DnsServerDsSetting_RemoteReplicationDelay_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer    = 'localhost'
            RemoteReplicationDelay = 30
        }
    }
}

<#
    .SYNOPSIS
        Set cache timeout.
#>
configuration DnsServerDsSetting_TombstoneInterval_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer    = 'localhost'
            TombstoneInterval = '14.00:00:00'
        }
    }
}

<#
    .SYNOPSIS
        Set cache timeout.
#>
configuration DnsServerDsSetting_All_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerDsSetting 'Integration_Test'
        {
            DnsServer    = 'localhost'
            DirectoryPartitionAutoEnlistInterval = '1.00:00:00'
            LazyUpdateInterval = 3
            MinimumBackgroundLoadThreads = 1
            PollingInterval = 180
            RemoteReplicationDelay = 30
            TombstoneInterval = '14.00:00:00'
        }
    }
}
