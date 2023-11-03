<#

.SYNOPSIS
Loads encrypted credentials from a specified file path

.EXAMPLE
Load-Credential -Name localadmin

.DESCRIPTION

.LINK

#>
param(
    [Parameter(Mandatory = $True)]
    [string]$Name
)
$folder = Join-Path $env:USERPROFILE "StoredEncryptedCredentials"
$path = Join-Path  $folder ($Name + '.xml')
if (Test-Path ($path )) {
    Import-Clixml $path
}
else {
    Write-Host "Datei $path nicht vorhanden."
}
