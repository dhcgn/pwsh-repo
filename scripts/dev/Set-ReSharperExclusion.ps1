#Requires -RunAsAdministrator
<#
.SYNOPSIS
    This script adds certain paths and processes to the exclusion list of Windows Defender.

.DESCRIPTION
    The script first checks if the Add-MpPreference command is available. If not, it throws an error and exits.
    If the command is available, it adds the JetBrains Transient folder, Visual Studio IDE executable, MSBuild executable, and a development folder to the exclusion list of Windows Defender. This is done to prevent these paths and processes from being scanned by Windows Defender, which can improve performance.

.PARAMETER None
    This script does not take any parameters.

.EXAMPLE
    .\Set-ReSharperExclusion.ps1

.NOTES
    Make sure to run this script with administrative privileges as it modifies Windows Defender settings.
#>

if ($null -eq (Get-Command Add-MpPreference)){
    Write-Error "Add-MpPreference is not available"
    return
}

# Docs https://docs.microsoft.com/en-us/powershell/module/defender/add-mppreference?view=win10-ps
Add-MpPreference -ExclusionPath "%LOCALAPPDATA%\JetBrains\Transient"

Resolve-Path "C:\Program Files (x86)\Microsoft Visual Studio\*\*\Common7\IDE\devenv.exe" | ForEach-Object{Add-MpPreference -ExclusionProcess $_}
Resolve-Path "C:\Program Files (x86)\Microsoft Visual Studio\*\*\Common7\IDE\devenv.exe" | ForEach-Object{Add-MpPreference -ExclusionPath $_}

Resolve-Path HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\* | Get-ItemProperty | ForEach-Object{Resolve-Path ("{0}msbuild.exe" -f $_.MSBuildToolsPath)} | ForEach-Object{Add-MpPreference -ExclusionProcess $_}
Resolve-Path HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\* | Get-ItemProperty | ForEach-Object{Resolve-Path ("{0}msbuild.exe" -f $_.MSBuildToolsPath)} | ForEach-Object{Add-MpPreference -ExclusionPath $_}

# Dev Folder
Resolve-Path "C:\dev*" |  ForEach-Object{Add-MpPreference -ExclusionPath $_}