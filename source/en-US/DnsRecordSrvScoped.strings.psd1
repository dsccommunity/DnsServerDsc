<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource DnsRecordSrvScoped.
#>

ConvertFrom-StringData @'
    GettingDnsRecordMessage   = Getting DNS record '{0}' with target of '{1}' ({2}) in zone '{3}' with the '{4}' scope, from '{5}'.
    CreatingDnsRecordMessage  = Creating {0} record for symbolic name '{1}' with target '{2}' in zone '{3}' with the '{4}' scope on '{5}'.
    GettingDscResourceObject = Calling GetResourceRecord() from the {0} class to get the object's current state.
    RecordNotFound = A matching DNS resource record not found.
    RecordFound = A matching DNS resource record was found.
    ModifyingExistingRecord = Modifying existing record.
    RemovingExistingRecord = Removing existing record.
    AddingNewRecord = Calling AddResourceRecord() from the {0} class to create a new record.
    PropertyIsNotInDesiredState = DNS record property '{0}' is not correct. Expected '{1}', actual '{2}'.
    ObjectInDesiredState = DNS record is in the desired state.
    ObjectNotInDesiredState = DNS record is NOT in the desired state.
    GetResourceRecordNotImplemented = GetResourceRecord() not implemented.
    AddResourceRecordNotImplemented = AddResourceRecord() not implemented.
    NewResourceObjectFromRecordNotImplemented = NewDscResourceObjectFromRecord() not implemented.
'@
