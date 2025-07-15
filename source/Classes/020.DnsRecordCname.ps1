<#
    .SYNOPSIS
        The DnsRecordCname DSC resource manages CNAME DNS records against a specific zone on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordCname DSC resource manages CNAME DNS records against a specific zone on a Domain Name System (DNS) server.

    .PARAMETER Ensure
        If the CNAME DNS record should be present or absent on the server
        being configured. Default values is 'Present'.

    .PARAMETER DnsServer
        x

    .PARAMETER Name
        Specifies the name of a DNS server resource record object. (Key Parameter)

    .PARAMETER ZoneName
        x

    .PARAMETER HostNameAlias
        Specifies a a canonical name target for a CNAME record. This must be a fully qualified domain name (FQDN). (Key Parameter)
        Dot at the end of provided value will be added automatically by DNS itself,
        but special RFC compliant regex is used for validation to prevent undesirable behavior when value is malformatted.

    .PARAMETER TimeToLive
        x

    .PARAMETER Reasons
        x
#>

[DscResource()]
class DnsRecordCname : ResourceBase
{
    [DscProperty()]
    [Ensure]
    $Ensure = [Ensure]::Present

    [DscProperty(Key)]
    [System.String]
    $DnsServer = 'localhost'

    [DscProperty(Key)]
    [System.String]
    $Name

    [DscProperty(Key)]
    [System.String]
    $ZoneName

    [DscProperty(Key)]
    [System.String]
    $HostNameAlias

    [DscProperty()]
    [System.String]
    $TimeToLive

    [DscProperty(NotConfigurable)]
    [DnsServerReason[]]
    $Reasons

    # Hidden property to determine whether the class is a scoped version
    hidden [System.Boolean] $isScoped

    DnsRecordCname() : base ($PSScriptRoot)
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            #'DnsServer',
            #'Name',
            #'ZoneName'
        )

        # Determine scope
        $this.isScoped = $this.PSObject.Properties.Name -contains 'ZoneScope'
        if ($this.isScoped)
        {
            $this.ExcludeDscProperties += 'ZoneScope'
        }
    }

    [DnsRecordCname] Get()
    {
        return ([ResourceBase] $this).Get()
    }

    [void] Set()
    {
        ([ResourceBase] $this).Set()
    }

    [System.Boolean] Test()
    {
        return ([ResourceBase] $this).Test()
    }

    # Base method Get() call this method to get the current state as a Hashtable.
    [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $getParameters = @{
            ComputerName = $properties.DnsServer
            ZoneName     = $this.ZoneName
            RRType       = 'CNAME'
            Name         = $this.Name
        }

        if ($this.isScoped)
        {
            $getParameters.Add('ZoneScope', $this.ZoneScope)
        }

        $state = @{
            Ensure    = [Ensure]::Absent
            DnsServer = $this.DnsServer
            ZoneName  = $this.ZoneName
            Name      = $this.Name
        }

        $getCurrentStateResult = Get-DnsServerResourceRecord @getParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_.RecordData.HostNameAlias -eq $this.HostnameAlias
        }

        if ($getCurrentStateResult)
        {
            $state.Ensure = [Ensure]::Present
            $state.Add('HostNameAlias', $getCurrentStateResult.RecordData.HostNameAlias)
        }

        return $state
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced and that are not in desired state.
    #>
    [void] Modify([System.Collections.Hashtable] $properties)
    {
        if ($properties.ContainsKey('Ensure') -and $properties.Ensure -eq [Ensure]::Absent -and $this.Ensure -eq [Ensure]::Absent)
        {
            # Ensure was not in desired state so the resource should be removed
            $this.RemoveResourceRecord()
        }
        elseif ($properties.ContainsKey('Ensure') -and $properties.Ensure -eq [Ensure]::Present -and $this.Ensure -eq [Ensure]::Present)
        {
            # Ensure was not in desired state so the resource shoul be created
            $this.AddResourceRecord()
        }
        else
        {
            # Resource exist but one or more properties are not in the desired state
            $dnsParameters = @{
                ComputerName = $this.DnsServer
                ZoneName     = $this.ZoneName
            }

            if ($this.isScoped)
            {
                $dnsParameters.Add('ZoneScope', $this.ZoneScope)
            }

            # Copy the existing record and modify values as appropriate
            $existingRecord = $this.GetResourceRecord()
            $newRecord = [Microsoft.Management.Infrastructure.CimInstance]::new($existingRecord)

            foreach ($key in $properties.Keys.Where({ $_ -ne 'Ensure' }))
            {
                switch ($key)
                {
                    'TimeToLive'
                    {
                        $newRecord.$key = [System.TimeSpan] $properties.$key
                    }

                    default
                    {
                        $newRecord.$key = $properties.$key
                    }
                }
            }

            Set-DnsServerResourceRecord @dnsParameters -OldInputObject $existingRecord -NewInputObject $newRecord -Verbose
        }
    }

    hidden [Microsoft.Management.Infrastructure.CimInstance] GetResourceRecord()
    {
        Write-Verbose -Message ($this.localizedData.GettingDnsRecordMessage -f 'CNAME', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'CNAME'
            Name         = $this.Name
        }

        if ($this.isScoped)
        {
            $dnsParameters.Add('ZoneScope', $this.ZoneScope)
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_.RecordData.HostNameAlias -eq $this.HostnameAlias
        }

        return $record
    }

    hidden [void] AddResourceRecord()
    {
        $addParameters = @{
            ZoneName      = $this.ZoneName
            ComputerName  = $this.DnsServer
            CNAME         = $true
            Name          = $this.Name
            HostNameAlias = $this.HostNameAlias
        }

        if ($null -ne $this.TimeToLive)
        {
            $addParameters.Add('TimeToLive', $this.TimeToLive)
        }

        if ($this.isScoped)
        {
            $addParameters.Add('ZoneScope', $this.ZoneScope)
        }

        Write-Verbose -Message ($this.localizedData.CreatingDnsRecordMessage -f 'CNAME', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        Add-DnsServerResourceRecord @addParameters
    }

    hidden [void] RemoveResourceRecord()
    {
        Write-Verbose -Message ($this.localizedData.RemovingDnsRecordMessage -f 'CNAME', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $removeParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'CNAME'
            Name         = $this.Name
        }

        Remove-DnsServerResourceRecord @removeParameters
    }

    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
    }

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('AvoidEmptyNamedBlocks', '')]
    hidden [void] NormalizeProperties([System.Collections.Hashtable] $properties)
    {
        if (-not ($properties.HostNameAlias).EndsWith('.'))
        {
            $this.HostNameAlias = $this.HostNameAlias + '.'
        }
    }
}
