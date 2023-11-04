#Version: 2

# This file is located once under the user profile folder and will be loaded from the all profiles.

# load all script that are located in the same folder as this script
$localScripts = Get-ChildItem $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name
$localScripts | ForEach-Object {
    Write-Host "Loading user script: $($_.FullName)"
    . $_.FullName
}

#Add portable executables to path
$exes = Get-ChildItem C:\ws\* -File -Include *.exe
$exes | ForEach-Object {
    Set-Alias -Name $_.BaseName -Value $_.FullName -Scope Global
}
