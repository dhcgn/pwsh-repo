#Version: 2023-11-13

# This file is located once under the user profile folder and will be loaded from the all profiles.
if ($PSVersionTable.PSVersion.Major -lt 6) {
    Write-Host  "# Loading shared profile " -NoNewline
}
else {
    Write-Host  "⚡ Loading shared profile " -NoNewline
}

# load all script that are located in the same folder as this script
$localScripts = Get-ChildItem $PSScriptRoot -Recurse -Exclude $MyInvocation.MyCommand.Name -Include *.ps1
$localScripts | Sort-Object BaseName | ForEach-Object {
    # Write-Host "Loading user script: $($_.FullName)"
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        Write-Host "#" -NoNewline
    }
    else {
        # Write-Host "📘" -NoNewline
        Write-Host ([char]::ConvertFromUtf32(0x1F4D8)) -NoNewline
    }
    
    . $_.FullName
}
Write-Host ""