$scriptFolder = Join-Path $PSScriptRoot "scripts"

Get-ChildItem $scriptFolder -Recurse -Include *_Suite.ps1 `
    | Select-String -Pattern "^function global:(.*) {" `
    | ForEach-Object{$_.Matches.Groups[1].Value}

Get-ChildItem $scriptFolder -Recurse -Exclude *_Suite.ps1 -Include *.ps1 `
    | ForEach-Object { $_.BaseName }