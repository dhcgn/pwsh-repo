#BEGIN generated personal profile

# This file is inserted in each profile file and will be always overwritten.

# Load shared profile
$sharedprofile = Join-Path $env:USERPROFILE ".sharedScripting\sharedprofile.ps1"
if (-not (Test-Path $sharedprofile)) {
    Write-Host "Could not find local profile at $sharedprofile" -ForegroundColor Red
    return
}

Set-Alias -Name lsp -Value $sharedprofile
Write-Host "📄 init shared profile: " -ForegroundColor Gray -NoNewline
Write-Host "isp" -ForegroundColor Magenta -NoNewline
Write-Host " (for performance defered)" -ForegroundColor Gray

#END generated personal profile