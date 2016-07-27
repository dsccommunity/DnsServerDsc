$resourceProperties = @()

$resourceProperties += New-xDscResourceProperty -Name ZoneName -Type String -Attribute Key -Description "Specifies the name of a zone. This cmdlet is relevant only for primary zones."
$resourceProperties += New-xDscResourceProperty -Name AgingEnabled -Type Boolean -Attribute Write -Description "Indicates whether to enable aging and scavenging for a zone."
$resourceProperties += New-xDscResourceProperty -Name ScavengeServers -Type String[] -Attribute Write -Description "Specifies an array of IP addresses for DNS servers."
$resourceProperties += New-xDscResourceProperty -Name RefreshInterval -Type String -Attribute Write -Description "Specifies the refresh interval as a TimeSpan object."
$resourceProperties += New-xDscResourceProperty -Name NoRefreshInterval -Type String -Attribute Write -Description "Specifies the length of time as a TimeSpan object."

$dnsServerZoneAgingparameters = @{
    Name         = 'MSFT_xDnsServerZoneAging' 
    Property     = $resourceProperties 
    FriendlyName = 'xDnsServerZoneAging' 
    ModuleName   = 'xDnsServer' 
    Path         = 'C:\Program Files\WindowsPowerShell\Modules\' 
} 
 
New-xDscResource @dnsServerZoneAgingparameters