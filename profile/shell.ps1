#BEGIN generated personal profile

# This file is inserted in each profile file and will be always overwritten.

# Load shared profile
$sharedprofile = Join-Path $env:USERPROFILE "Local\SharedScripting\sharedprofile.ps1"
if (-not (Test-Path $sharedprofile)) {
    Write-Host "Could not find local profile at $sharedprofile" -ForegroundColor Red
    return
}
. $sharedprofile

#END generated personal profile