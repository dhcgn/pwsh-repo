<#
.SYNOPSIS
    This script loads encrypted credentials from a specified file path.

.DESCRIPTION
    The Load-Credential.ps1 script loads encrypted credentials from a specified file path. The credentials are stored in an XML file in the "StoredEncryptedCredentials" folder in the user's profile directory. The name of the XML file is the name of the credential passed as a parameter to the script. If the XML file does not exist, a message is displayed.

.PARAMETER Name
    The name of the credential to load. This parameter is mandatory.

.EXAMPLE
    Load-Credential -Name localadmin

    This will load the encrypted credentials from the "localadmin.xml" file in the "StoredEncryptedCredentials" folder in the user's profile directory.

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
