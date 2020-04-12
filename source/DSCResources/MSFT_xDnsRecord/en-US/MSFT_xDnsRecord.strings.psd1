# culture="en-US"
ConvertFrom-StringData @'
    GettingDnsRecordMessage   = Getting DNS record '{0}' ({1}) in zone '{2}', from '{3}'.
    CreatingDnsRecordMessage  = Creating DNS record '{0}' for target '{1}' in zone '{2}' on '{3} with a TTL of '{4}'.
    CreatingTimespan          = Creating new timespan with: '{0}' - days, '{1}' - hours, '{2}' - minutes, '{3}' - seconds.
    UpdatingTTL               = Updating DNS record '{0}' for target '{1}' in zone '{2}' on '{3} with a TTL of '{4}'.
    RemovingDnsRecordMessage  = Removing DNS record '{0}' for target '{1}' in zone '{2}' on '{3}'.
    NotDesiredPropertyMessage = DNS record property '{0}' is not correct. Expected '{1}', actual '{2}'
    InDesiredStateMessage     = DNS record '{0}' is in the desired state.
    NotInDesiredStateMessage  = DNS record '{0}' is NOT in the desired state.
'@
