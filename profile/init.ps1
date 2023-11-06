<#
.SYNOPSIS
    My personal init script to setup my environment
#>
param(
    [switch]
    $GeneratedSharedProfileFromLocal = $false
)

# setup profiles
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File
}

$profiles = Resolve-Path ("{0}\*PowerShell*\*_profile.ps1" -f [Environment]::GetFolderPath("MyDocuments"))

$generatedSharedProfile = $null
if ($GeneratedSharedProfileFromLocal -eq $true) {
    $generatedSharedProfile = Get-Content (Join-Path $PSScriptRoot "shell.ps1")
}
else {
    $url = "https://raw.githubusercontent.com/dhcgn/pwsh-repo/main/profile/shell.ps1"
    $generatedSharedProfile = Invoke-WebRequest -Uri  $url -UseBasicParsing | ForEach-Object { $_.Content }
}

$header = "#BEGIN generated personal profile"
$footer = "#END generated personal profile"
foreach ($profile in $profiles) {
    $content = Get-Content $profile
    if ($content -notcontains $header) {
        Write-Host "Adding generated profile to $profile"
        $content += $generatedSharedProfile
        Set-Content $profile $content
        continue
    }

    Write-Host "Updating generated profile in $profile"
    $start = $content.IndexOf($header)
    $end = $content.IndexOf($footer)
    
    if ($start -eq 0 -and $end -eq ($content.Length - 1)) {
        $content = $generatedSharedProfile
    }
    elseif ($start -eq 0) {
        $content = $generatedSharedProfile + $content[($end + 1)..($content.Length)]
    }
    else {
        $content = $content[0..($start - 1)] + $generatedSharedProfile + $content[($end + 1)..($content.Length - 1)]
    }

    Set-Content $profile $content
}

# Set or update the local profile

$localProfileFolder = Join-Path $env:USERPROFILE ".sharedScripting"
if (-not (Test-Path $localProfileFolder)) {
    Write-Host "Creating $localProfileFolder"
    New-Item -Path $localProfileFolder -ItemType Directory
}

$localProfileFile = Join-Path $localProfileFolder "sharedprofile.ps1"
if (-not (Test-Path $localProfileFile)) {
    Write-Host "Creating $localProfileFile"
    New-Item -Path $localProfileFile -ItemType File
}

$localUserProfileRemote = $null
if ($GeneratedSharedProfileFromLocal -eq $true) {
    $localUserProfileRemote = Get-Content (Join-Path $PSScriptRoot "sharedprofile.ps1")
}
else {
    $url = "https://raw.githubusercontent.com/dhcgn/pwsh-repo/main/profile/sharedprofile.ps1"
    $localUserProfileRemote = Invoke-WebRequest -Uri  $url -UseBasicParsing | ForEach-Object { $_.Content }
}

$versionRemote = $localUserProfileRemote | Select-String -Pattern "#Version: (.*)" | ForEach-Object { $_.Matches.Groups[1].Value }
$versionLocal = Select-String -Path $localProfileFile -Pattern "#Version: (.*)" | ForEach-Object { $_.Matches.Groups[1].Value }

if ($versionRemote -ne $versionLocal) {
    Write-Host "Updating $localProfileFile, from '$versionLocal' to '$versionRemote'"
    $localUserProfileRemote | Set-Content $localProfileFile
}
else {
    Write-Host "Skipping $localProfileFile, already up to date with '$versionRemote'"
}

# Copy sample script to sharedScripting

function Save-SampleScript {
    param (
        $ScriptName
    )
    $sampleScript = $null
    if ($GeneratedSharedProfileFromLocal -eq $true) {
        $sampleScript = Get-Content (Join-Path $PSScriptRoot "$ScriptName")
    }
    else {
        $url = "https://raw.githubusercontent.com/dhcgn/pwsh-repo/main/profile/$ScriptName"
        $sampleScript = Invoke-WebRequest -Uri  $url -UseBasicParsing | ForEach-Object { $_.Content }
    }
    $sampleScriptPath = Join-Path $localProfileFolder "$ScriptName"
    Set-Content -Path $sampleScriptPath -Value $sampleScript
}

Save-SampleScript -ScriptName "99_load_pwsh-repo.ps1.sample"
Save-SampleScript -ScriptName "10_set-tools-to-alias.ps1.sample"
Save-SampleScript -ScriptName "00_vars.ps1.sample"