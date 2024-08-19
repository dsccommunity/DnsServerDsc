using module .\Modules\DscResource.Base

# Import nested, 'DscResource.Common' module
$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\DscResource.Common'
Import-Module -Name $script:dscResourceCommonModulePath

# TODO: The goal would be to remove this, when no classes and public or private functions need it.
$script:dnsServerDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\DnsServerDsc.Common'
Import-Module -Name $script:dnsServerDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'
