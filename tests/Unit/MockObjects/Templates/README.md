# How to create Mock Objects

Create a DNS record of the required type using DNS Manager UI or, in some cases, use the PowerShell cmdlet Add-DnsServerResourceRecord.
After that, retrieve the record using PowerShell, for example:
```Powershell
Get-DnsServerResourceRecord -ZoneName contoso.com -RRType WINS
```
Then save the record in XML format:
```Powershell
Get-DnsServerResourceRecord -ZoneName contoso.com -RRType WINS | Export-Clixml -Path C:\Temp\WinsRecordInstance.xml
```

<# TODO: This list should be updated from time to time. It should be helpfull for later development of project. #>
<# TODO: Files added to tests/Unit/MockObjects/Templates directory could be excessive and provided only for ease of development.
For example: WksRecordInstance_MultiTCP.xml, WksRecordInstance_MultiUDP.xml, WksRecordInstance_SingleTCP.xml, WksRecordInstance_SingleUDP.xml. When Wks Resouce implemented excessive files should be removed.
#>

# DNS Record types from DnsServerDsc Issues on GitHub
-[x] DnsRecordDhcId: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/155

- [x] DnsRecordDName: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/154

- [x] DnsRecordWinsR: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/152

- [x] DnsRecordWins: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/151

- [x] DnsRecordTxt: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/150

- [x] DnsRecordX25: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/144
A hypothetical X.121 address could be 23451234567890. In this example, 2345 is the DNIC, and 1234567890 is the NTN.

- [x] DnsRecordWks: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/143
IP address, Protocol (TCP,UDP)

- [x] DnsRecordRt: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/142

- [x] DnsRecordRp: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/141

- [x] DnsRecordIsdn: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/139

- [x] DnsRecordAtma: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/138
E164 or NSAP

- [x] DnsRecordAfsdb: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/137

- [x] DnsRecordHInfo: New resource proposal
https://github.com/dsccommunity/DnsServerDsc/issues/136

# DNS Types that could be seen in DNS Manager UI
Agenda for prefixes:
  [V] - Issue with resource proposal present in DnsServerDsc project and MockObject provided for usage.
  [X] - Dns Resource already present in DnsServerDsc project and MockObject provided for usage.
  [Z] - There is no issue with resource proposal present in DnsServerDsc project but MockObject provided for later usage.
  [!] - MockObject is not available. Resource could be created using DNS Manager UI or Powershell but there was a problem with getting object and saving it as xml file.
----------
- [V] AFD Database (AFSDB)
- [X] Alias (CNAME)
- [V] ATM Address (ATMA)
- [Z] Delegation Signer (DS)
- [V] DHCID
- [Z] DNS KEY (DNSKEY)
- [V] Domain Alias (DNAME)
- [X] Host (A or AAAA)
- [V] Host Information (HINFO)
- [V] ISDN
- [X] Mail Exchanger (MX)
- [Z] Mail Group (MG)
- [Z] Mailbox (MB)
- [Z] Mailbox Information (MINFO)
- [Z] Naming Authority Pointer (NAPTR)
- [!] Next Domain (NXT)
- [X] Pointer (PTR)
- [Z] Public Key (KEY) - Complex resourse
- [Z] Renamed Mailbox (MR)
- [V] Responsible Person (RP)
- [V] Route Through (RT)
- [X] Service Location (SRV)
- [!] Signature (SIG)
- [V] Text (TXT)
- [V] Well Known Services (WKS)
- [V] X.25

# DNS Types from Get-DnsServerResourceRecord RRType parameter values
All resource type parameters that could be used with Get-DnsServerResourceRecord Cmdlet.
Agenda for prefixes:
  [X] - Resource associated with RRType parameter already implemented
  [V] - Resource associated with RRType parameter have corresponding Issue and MockObject and waiting for implementation
  [Z] - Resource associated with RRType parameter doesn't have corresponding Issue but have a MockObject and could be implemented
  [!] - Resource associated with RRType parameter is unknown
----------
- [X] A
- [X] AAAA
- [V] Afsdb
- [V] Atma
- [X] CName
- [V] DhcId
- [V] DName
- [Z] DnsKey
- [Z] DS
- [!] Gpos
- [V] HInfo
- [V] Isdn
- [Z] Key
- [!] Loc
- [!] Mb
- [!] Md
- [!] Mf
- [Z] Mg
- [Z] MInfo
- [Z] Mr
- [X] Mx
- [Z] Naptr
- [!] NasP
- [!] NasPtr
- [X] Ns
- [!] NSec
- [!] NSec3
- [!] NSec3Param
- [!] NsNxt
- [X] Ptr
- [V] Rp
- [!] RRSig
- [V] Rt
- [!] Soa - Complex record tied to a zone itself
- [X] Srv
- [!] Tlsa
- [V] Txt
- [V] Wins - Could be created using Add-DnsServerResourceRcord cmdlet only
- [V] WinsR - Could be created using Add-DnsServerResourceRcord cmdlet only
- [V] Wks
- [V] X25

# Example of DHCID record base64 parameter creation
```Powershell
$StringEncode = "This is a test string."
$EncodeString = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($StringEncode))
Write-Host $EncodeString
'VGhpcyBpcyBhIHRlc3Qgc3RyaW5nLg=='
```

# Notes for WINS resource
Created only for Forward Lookup Zones
```Powershell
# Resource could be created with
Add-DnsServerResourceRecord -ZoneName example.com -Wins -WinsServers 10.10.10.10 -LookupTimeout $(New-TimeSpan -Hours 5) -CacheTimeout $(New-TimeSpan -Hours 5)
# Resource MockObject could be exported with
Get-DnsServerResourceRecord -ZoneName example.com -RRType Wins | Export-Clixml -Path C:\Temp\WinsRecordInstance.xml
```
Resource could be removed only with
```Powerhsell
Remove-DnsServerResourceRecord -ZoneName example.com -RRType Wins -Name "@"
```

# Notes for WINSR resource
Created only for Reverse Lookup Zones
```Powershell
# Resource could be created with
Add-DnsServerResourceRecord -ZoneName 98.10.in-addr.arpa -WinsR -ResultDomain example.com -LookupTimeout $(New-TimeSpan -Hours 5) -CacheTimeout $(New-TimeSpan -Hours 5)
# Resource MockObject could be exported with
Get-DnsServerResourceRecord -ZoneName 98.10.in-addr.arpa -RRType WinsR | Export-Clixml -Path C:\Temp\WinsrRecordInstance.xml
```
Resource could be removed only with
```Powershell
Remove-DnsServerResourceRecord -ZoneName 98.10.in-addr.arpa -RRType WinsR -Name "@"
```
