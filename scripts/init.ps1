if (-not (Test-Path "C:\ws\workplace-sync.exe")){
    Write-Host "Downloading workplace-sync"
    $url = "https://github.com/dhcgn/workplace-sync/releases/download/0.0.16/ws-0.0.16-windows-amd64.zip"
    Invoke-WebRequest -Uri $url -OutFile "C:\ws\ws.zip"
    Expand-Archive -Path "C:\ws\ws.zip" -DestinationPath "C:\ws"
    Remove-Item "C:\ws\ws.zip"
}

$exes = Get-ChildItem C:\ws\* -File -Include *.exe
$exes | ForEach-Object {
    Set-Alias -Name $_.BaseName -Value $_.FullName -Scope Global
}

$scripts = Get-ChildItem $PSScriptRoot -File -Recurse -Exclude *_Suite.ps1
$scripts | ForEach-Object {
    Set-Alias -Name $_.BaseName -Value $_.FullName -Scope Global
}

$suites = Get-ChildItem $PSScriptRoot -File -Recurse -Include *_Suite.ps1
$suites | ForEach-Object {
    . $_.FullName
}
