$resourceProperties = @()
$resourceProperties += New-xDscResourceProperty -Name Name -Type String -Attribute Key -Description "Specifies a name for the new DNS application directory partition."
$resourceProperties += New-xDscResourceProperty -Name Ensure -Type String -Attribute Required -ValidateSet "Present","Absent" -Description "Specifies if the DNS directory partition should be added (Present) or removed (Absent)"

$dnsServerDirectoryPartitionParameters = @{
    Name         = 'MSFT_xDnsServerDirectoryPartition' 
    Property     = $resourceProperties 
    FriendlyName = 'xDnsServerDirectoryPartition' 
    ModuleName   = 'xDnsServer' 
    Path         = 'C:\Program Files\WindowsPowerShell\Modules\' 
} 
 
New-xDscResource @dnsServerDirectoryPartitionParameters