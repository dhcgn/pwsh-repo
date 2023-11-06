#Version: 2023-11-06

# This file is located once under the user profile folder and will be loaded from the all profiles.
Write-Host  "⚡ Loading shared profile"
# load all script that are located in the same folder as this script
$localScripts = Get-ChildItem $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name
$localScripts | Sort-Object BaseName | ForEach-Object {
    Write-Host "Loading user script: $($_.FullName)"
    . $_.FullName
}