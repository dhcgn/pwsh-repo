<#
.SYNOPSIS
    My personal init script to setup my environment
#>

# workplace-sync
if (-not (Test-Path "C:\ws")) {
    Write-Host "Creating C:\ws"
    New-Item -Path "C:\ws" -ItemType Directory
}

if (-not (Test-Path "C:\ws\workplace-sync.exe")) {
    Write-Host "Downloading workplace-sync"
    $url = "https://github.com/dhcgn/workplace-sync/releases/download/0.0.16/ws-0.0.16-windows-amd64.zip"
    Invoke-WebRequest -Uri $url -OutFile "C:\ws\ws.zip"
    Expand-Archive -Path "C:\ws\ws.zip" -DestinationPath "C:\ws"
    Remove-Item "C:\ws\ws.zip"
}

# install bare minumum
if(-Not (Test-Path "C:\ws\age.exe")) {
    . "C:\ws\workplace-sync.exe" -host ws.hdev.io -name age
}

# setup profiles
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File
}

$profiles = Resolve-Path C:\Users\*\OneDrive\Documents\*\*_profile.ps1
$generatedSharedProfile = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dhcgn/pwsh-repo/merge-with-shared-profile/profile/user.ps1" -UseBasicParsing | %{$_.RawContent}
$header = "#BEGIN generated personal profile"
$footer = "#END generated personal profile"
foreach ($profile in $profiles) {
    $content = Get-Content $profile
    if ($content -notcontains $header) {
        $content += $generatedSharedProfile
        Set-Content $profile $content
        continue
    }

    $start = $content.IndexOf($header)
    $end = $content.IndexOf($footer)
    $content = $content[0..($start-1)] + $generatedSharedProfile + $content[($end+1)..($content.Length-1)]
    Set-Content $profile $content
}
