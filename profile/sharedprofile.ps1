#Version: 2023-11-06-11:30

# This file is located once under the user profile folder and will be loaded from the all profiles.
Write-Host  "⚡ Loading shared profile " -NoNewline
# load all script that are located in the same folder as this script
$localScripts = Get-ChildItem $PSScriptRoot -Recurse -Exclude $MyInvocation.MyCommand.Name -Include *.ps1
$localScripts | Sort-Object BaseName | ForEach-Object {
    # Write-Host "Loading user script: $($_.FullName)"
    Write-Host "📘" -NoNewline
    . $_.FullName
}
Write-Host ""