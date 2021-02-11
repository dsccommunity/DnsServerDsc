# culture="en-US"
ConvertFrom-StringData @'
    GettingDnsRecordMessage   = Getting DNS record '{0}' with target of '{1}' ({2}) in zone '{3}', from '{4}'.
    CreatingDnsRecordMessage  = Creating DNS record '{0}' for symbolic name '{1}' with target '{2}' in zone '{3}' on '{4}'.
    UpdatingDnsRecordMessage  = Updating DNS record '{0}' for symbolic name '{1}' with target '{2}' in zone '{3}' on '{4}'.
    RemovingDnsRecordMessage  = Removing DNS record '{0}' for symbolic name '{1}' with target '{2}' in zone '{3}' on '{4}'.
    NotDesiredPropertyMessage = DNS record property '{0}' is not correct. Expected '{1}', actual '{2}'
    InDesiredStateMessage     = DNS record '{0}' is in the desired state.
    NotInDesiredStateMessage  = DNS record '{0}' is NOT in the desired state.
'@
