<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource DnsRecordBase.
#>

<#
    Exemple of StringData for Class based resource
#>
ConvertFrom-StringData @'
    GettingDscResourceObject = Calling GetResourceRecord() from the {0} class to get the object's current state.
    RecordNotFound = A matching DNS resource record not found.
    RecordFound = A matching DNS resource record was found.
    RemovingExisitngRecord = Removing existing record.
    AddingNewRecord = Calling AddresourceRecord() from the {0} class to create a new record.
    PropertyIsNotInDesiredState = DNS record property '{0}' is not correct. Expected '{1}', actual '{2}'
    ObjectInDesiredState = DNS record is in the desired state.
    ObjectNotInDesiredState = DNS record is NOT in the desired state.
'@
