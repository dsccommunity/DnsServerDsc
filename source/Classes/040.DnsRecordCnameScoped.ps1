<#
    .SYNOPSIS
        The DnsRecordCnameScoped DSC resource manages CNAME DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordCnameScoped DSC resource manages CNAME DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
#>

[DscResource()]
class DnsRecordCnameScoped : DnsRecordCname
{
    [DscProperty(Key)]
    [System.String]
    $ZoneScope

    DnsRecordCnameScoped() : base ($PSScriptRoot)
    {
    }

    [DnsRecordCnameScoped] Get()
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
}
