<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource DnsRecordSrv.
#>

<#
    Exemple of StringData for Class based resource
#>
ConvertFrom-StringData @'
    GettingDnsRecordMessage   = Getting DNS record '{0}' with target of '{1}' ({2}) in zone '{3}', from '{4}'
    CreatingDnsRecordMessage  = Creating {0} record for symbolic name '{1}' with target '{2}' in zone '{3}' on '{4}'.
'@
