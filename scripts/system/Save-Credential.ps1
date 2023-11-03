<#

.SYNOPSIS
Exports encrypted credentials on Windows using the Windows Data Protection API. It prompts the user for a name and description, creates a folder to store the encrypted credentials, and exports the credentials as a Clixml file. If the credentials are successfully exported, the script returns the path to the file.

.EXAMPLE
Save-Credential -Name localadmin -Description "Local Administrator Account"

.DESCRIPTION
This script only exports encrypted credentials on Windows. On non-Windows operating systems such as macOS and Linux, credentials are exported as a plain text stored as a Unicode character array. This provides some obfuscation but does not provide encryption.
This script encrypts credential objects by using the Windows Data Protection API. 

.LINK
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-clixml?view=powershell-7.3

#>

param(
    [Parameter(Mandatory = $True)]
    [string]$Name,
    [Parameter(Mandatory = $False)]
    [string]$Description = "Es wurde keine Beschreibung angegeben."
)

# Warning message if the script is not run on Windows
if ($env:OS -ne "Windows_NT") {
    Write-Warning "This script only exports encrypted credentials on Windows. On non-Windows operating systems such as macOS and Linux, credentials are exported as a plain text stored as a Unicode character array. This provides some obfuscation but does not provide encryption."
}

$folder = Join-Path $env:USERPROFILE "StoredEncryptedCredentials"
if (-not(Test-Path $folder)) {
    New-Item -Path $folder -ItemType Directory
}

$path = Join-Path $folder ($Name + '.xml')

if (Test-Path $path) {
    Write-Warning "Die Datei $path existiert bereits."
    return
}

$cred = Get-Credential -Message $Description
if ($null -ne $cred) {
    $cred | Export-Clixml $path
    $path
}
