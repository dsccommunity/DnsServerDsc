<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource DnsRecordTxt.
#>

ConvertFrom-StringData @'
    GettingDnsRecordMessage   = Getting specified DNS {0} record in zone '{1}' from '{3}'.
    CreatingDnsRecordMessage  = Creating {0} record specified in zone '{1}' on '{3}'.
    PropertyIsNotInValidRange = The property '{0}' is not within the valid range of 1 to 254.
'@
