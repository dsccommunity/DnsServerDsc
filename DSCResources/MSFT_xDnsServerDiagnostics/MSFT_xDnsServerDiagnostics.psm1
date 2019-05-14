Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    Assert-Module -Name DnsServer

    Write-Verbose ($LocalizedData.GettingDnsServerDiagnostics)

    $dnsServerDiagnostics = Get-DnsServerDiagnostics -ErrorAction Stop

    $returnValue = @{
        Name                                 = $Name
        Answers                              = $dnsServerDiagnostics.Answers
        EnableLogFileRollover                = $dnsServerDiagnostics.EnableLogFileRollover
        EnableLoggingForLocalLookupEvent     = $dnsServerDiagnostics.EnableLoggingForLocalLookupEvent
        EnableLoggingForPluginDllEvent       = $dnsServerDiagnostics.EnableLoggingForPluginDllEvent
        EnableLoggingForRecursiveLookupEvent = $dnsServerDiagnostics.EnableLoggingForRecursiveLookupEvent
        EnableLoggingForRemoteServerEvent    = $dnsServerDiagnostics.EnableLoggingForRemoteServerEvent
        EnableLoggingForServerStartStopEvent = $dnsServerDiagnostics.EnableLoggingForServerStartStopEvent
        EnableLoggingForTombstoneEvent       = $dnsServerDiagnostics.EnableLoggingForTombstoneEvent
        EnableLoggingForZoneDataWriteEvent   = $dnsServerDiagnostics.EnableLoggingForZoneDataWriteEvent
        EnableLoggingForZoneLoadingEvent     = $dnsServerDiagnostics.EnableLoggingForZoneLoadingEvent
        EnableLoggingToFile                  = $dnsServerDiagnostics.EnableLoggingToFile
        EventLogLevel                        = $dnsServerDiagnostics.EventLogLevel
        FilterIPAddressList                  = $dnsServerDiagnostics.FilterIPAddressList
        FullPackets                          = $dnsServerDiagnostics.FullPackets
        LogFilePath                          = $dnsServerDiagnostics.LogFilePath
        MaxMBFileSize                        = $dnsServerDiagnostics.MaxMBFileSize
        Notifications                        = $dnsServerDiagnostics.Notifications
        Queries                              = $dnsServerDiagnostics.Queries
        QuestionTransactions                 = $dnsServerDiagnostics.QuestionTransactions
        ReceivePackets                       = $dnsServerDiagnostics.ReceivePackets
        SaveLogsToPersistentStorage          = $dnsServerDiagnostics.SaveLogsToPersistentStorage
        SendPackets                          = $dnsServerDiagnostics.SendPackets
        TcpPackets                           = $dnsServerDiagnostics.TcpPackets
        UdpPackets                           = $dnsServerDiagnostics.UdpPackets
        UnmatchedResponse                    = $dnsServerDiagnostics.UnmatchedResponse
        Update                               = $dnsServerDiagnostics.Update
        UseSystemEventLog                    = $dnsServerDiagnostics.UseSystemEventLog
        WriteThrough                         = $dnsServerDiagnostics.WriteThrough
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.Boolean]
        $Answers,

        [System.Boolean]
        $EnableLogFileRollover,

        [System.Boolean]
        $EnableLoggingForLocalLookupEvent,

        [System.Boolean]
        $EnableLoggingForPluginDllEvent,

        [System.Boolean]
        $EnableLoggingForRecursiveLookupEvent,

        [System.Boolean]
        $EnableLoggingForRemoteServerEvent,

        [System.Boolean]
        $EnableLoggingForServerStartStopEvent,

        [System.Boolean]
        $EnableLoggingForTombstoneEvent,

        [System.Boolean]
        $EnableLoggingForZoneDataWriteEvent,

        [System.Boolean]
        $EnableLoggingForZoneLoadingEvent,

        [System.Boolean]
        $EnableLoggingToFile,

        [System.UInt32]
        $EventLogLevel,

        [System.String[]]
        $FilterIPAddressList,

        [System.Boolean]
        $FullPackets,

        [System.String]
        $LogFilePath,

        [System.UInt32]
        $MaxMBFileSize,

        [System.Boolean]
        $Notifications,

        [System.Boolean]
        $Queries,

        [System.Boolean]
        $QuestionTransactions,

        [System.Boolean]
        $ReceivePackets,

        [System.Boolean]
        $SaveLogsToPersistentStorage,

        [System.Boolean]
        $SendPackets,

        [System.Boolean]
        $TcpPackets,

        [System.Boolean]
        $UdpPackets,

        [System.Boolean]
        $UnmatchedResponse,

        [System.Boolean]
        $Update,

        [System.Boolean]
        $UseSystemEventLog,

        [System.Boolean]
        $WriteThrough
    )

    $PSBoundParameters.Remove('Name')
    $DnsServerDiagnostics = Remove-CommonParameter -Hashtable $PSBoundParameters

    Set-DnsServerDiagnostics @DnsServerDiagnostics
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.Boolean]
        $Answers,

        [System.Boolean]
        $EnableLogFileRollover,

        [System.Boolean]
        $EnableLoggingForLocalLookupEvent,

        [System.Boolean]
        $EnableLoggingForPluginDllEvent,

        [System.Boolean]
        $EnableLoggingForRecursiveLookupEvent,

        [System.Boolean]
        $EnableLoggingForRemoteServerEvent,

        [System.Boolean]
        $EnableLoggingForServerStartStopEvent,

        [System.Boolean]
        $EnableLoggingForTombstoneEvent,

        [System.Boolean]
        $EnableLoggingForZoneDataWriteEvent,

        [System.Boolean]
        $EnableLoggingForZoneLoadingEvent,

        [System.Boolean]
        $EnableLoggingToFile,

        [System.UInt32]
        $EventLogLevel,

        [System.String[]]
        $FilterIPAddressList,

        [System.Boolean]
        $FullPackets,

        [System.String]
        $LogFilePath,

        [System.UInt32]
        $MaxMBFileSize,

        [System.Boolean]
        $Notifications,

        [System.Boolean]
        $Queries,

        [System.Boolean]
        $QuestionTransactions,

        [System.Boolean]
        $ReceivePackets,

        [System.Boolean]
        $SaveLogsToPersistentStorage,

        [System.Boolean]
        $SendPackets,

        [System.Boolean]
        $TcpPackets,

        [System.Boolean]
        $UdpPackets,

        [System.Boolean]
        $UnmatchedResponse,

        [System.Boolean]
        $Update,

        [System.Boolean]
        $UseSystemEventLog,

        [System.Boolean]
        $WriteThrough
    )

    Write-Verbose -Message 'Evaluating the DNS Server Diagnostics.'

    $currentState = Get-TargetResource -Name $Name

    $desiredState = $PSBoundParameters

    $result = Test-DscParameterState -CurrentValues $currentState -DesiredValues $desiredState -TurnOffTypeChecking -Verbose:$VerbosePreference

    return $result
}

Export-ModuleMember -Function *-TargetResource
