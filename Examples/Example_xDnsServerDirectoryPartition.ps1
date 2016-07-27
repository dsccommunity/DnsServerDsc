configuration DnsServerDirectoryPartition
{
    Import-DscResource -ModuleName xDnsServer

    node localhost
    {
        xDnsServerDirectoryPartition AddContoso
        {
            Name = 'contoso.com'
            Ensure = 'Present'
        }
        xDnsServerDirectoryPartition AddContoso
        {
            Name = 'child.contoso.com'
            Ensure = 'Absent'
        }
    }
}

DnsServerDirectoryPartition -OutputPath C:\dscDns

Start-DscConfiguration -Path C:\dscDNS -Wait -Force -Verbose