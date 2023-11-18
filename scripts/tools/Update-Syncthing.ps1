
<#
.DESCRIPTION
Download syncthing from github and install it as scheduled task to start on startup.

.NOTES
TODO: Download always the latest release from github

Source https://github.com/syncthing/syncthing/releases/download/v1.26.1/syncthing-windows-amd64-v1.26.1.zip
#>

param(
    [switch]$SkipDownload
)

$targetFolder = Join-Path ([Environment]::GetFolderPath('CommonApplicationData')) 'syncthing'
if (-not (Test-Path $targetFolder)) {
    Write-Host "Creating folder $targetFolder"
    New-Item -Path $targetFolder -ItemType Directory
}

$targetFile = Join-Path $targetFolder 'syncthing.exe'

if (-not $SkipDownload) {
    $hashBefore = @{}
    if (Test-Path $targetFile) {
        Write-Host "Update syncthing"
        $hashBefore = Get-FileHash -Path $targetFile -Algorithm SHA256
    }
    else {
        Write-Host "Install syncthing"
    }

    Write-Host "Download syncthing"
    $url = 'https://github.com/syncthing/syncthing/releases/download/v1.26.1/syncthing-windows-amd64-v1.26.1.zip'
    $zipFile = Join-Path $targetFolder 'syncthing.zip'
    Invoke-WebRequest -Uri $url -OutFile $zipFile

    Write-Host "Extract syncthing"
    $tempUnzipFolder = Join-Path $targetFolder 'temp'
    Expand-Archive -Path $zipFile -DestinationPath $tempUnzipFolder -Force
    Remove-Item -Path $zipFile -Force

    # Kill running processes
    Write-Host "Kill running syncthing processes"
    Get-Process -Name syncthing -ErrorAction Ignore | Stop-Process -Force -Verbose

    # Replace syncthing.exe
    Write-Host "Replace syncthing.exe"
    if (Test-Path $targetFile) {
        Start-Sleep -Seconds 1
        Remove-Item -Path $targetFile -Force
    }

    Get-ChildItem -Path $tempUnzipFolder -Recurse -Include 'syncthing.exe' | Move-Item -Destination $targetFile -Force
    Remove-Item -Path $tempUnzipFolder -Force -Recurse

    Write-Host "Update syncthing"
    $hashAfter = Get-FileHash -Path $targetFile -Algorithm SHA256
    if ($hashBefore.Hash -ne $hashAfter.Hash) {
        Write-Host "Hash before: $($hashBefore.Hash)"
        Write-Host "Hash after: $($hashAfter.Hash)"
        Write-Host "Hashes are not equal. Syncthing was updated."
    }
    else {
        Write-Host "Hashes are equal. Syncthing was NOT updated but file was replaced."
    }
}

# Place startup script
Write-Host "Place startup script"

$taskName = 'syncthing-pwsh'

$startScriptContent = @'
<#
.DESCRIPTION
Starts the syncthing.exe next to this script as a new process without showing the console window of the new process.
#>

$logFile = Join-Path $PSScriptRoot 'syncthing.log'
$exe = Join-Path $PSScriptRoot 'syncthing.exe' 
if (-NOT (Test-Path $exe)) {
    Write-Error "File $exe does not exist."
    exit 1
}

Write-Host "Stop syncthing processes"
Get-Process -Name syncthing -ErrorAction Ignore | Stop-Process -Force -Verbose

Write-Host "Start syncthing process"
Start-Process -FilePath $exe  -WindowStyle Hidden -ArgumentList '--no-console', '--no-browser', "--logfile=$logFile"
'@

$startScript = Join-Path $targetFolder 'hidden_start.ps1'
Set-Content -Path $startScript -Value $startScriptContent

# Check if script is running as administrator

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an Administrator to create or modify a scheduled task. Please re-run this script as an Administrator."
    Write-Host "Starting syncthing without scheduled task."
    . $startScript

    # TODO refactor to function, duplicated code!
    # Waiting for syncthing to start
    Write-Host "Waiting for syncthing to start"
    Start-Sleep -Seconds 1 

    # Print logging full path
    $logFile = Join-Path $targetFolder 'syncthing.log'
    Write-Host "Syncthing log file: $logFile"

    $guiUrls = Select-String -Path $logFile -Pattern "Access the GUI via the following URL: (.*)" | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique
    $guiUrlsAggregated = $guiUrls -join ", "

    Write-Host "Syncthing GUI Urls: $guiUrlsAggregated "
    return
}

# Setup a ScheduledTask to start syncthing on startup
Write-Host "Setup scheduled task to start syncthing on startup"



if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Write-Host "Remove scheduled task $taskName"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
}

<#
syncthing [serve]
          [--audit] [--auditfile=<file|-|-->] [--browser-only] [--device-id]
          [--generate=<dir>] [--gui-address=<address>] [--gui-apikey=<key>]
          [--home=<dir> | --config=<dir> --data=<dir>]
          [--logfile=<filename>] [--logflags=<flags>]
          [--log-max-old-files=<num>] [--log-max-size=<num>]
          [--no-browser] [--no-console] [--no-restart] [--paths] [--paused]
          [--no-default-folder] [--skip-port-probing]
          [--reset-database] [--reset-deltas] [--unpaused] [--allow-newer-config]
          [--upgrade] [--no-upgrade] [--upgrade-check] [--upgrade-to=<url>]
          [--verbose] [--version] [--help] [--debug-*]
#>

$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden $startScript" -WorkingDirectory $targetFolder
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$st = Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Description "Start syncthing on startup" -ErrorAction SilentlyContinue -ErrorVariable err
if ($err) {
    Write-Host "Error creating scheduled task $taskName"
    Write-Host $err
}


# $st | Format-List
# $st.Triggers | Format-List
# $st.Actions | Format-List

# TODO refactor to function, duplicated code!
. $startScript

# Waiting for syncthing to start
Write-Host "Waiting for syncthing to start"
Start-Sleep -Seconds 1 

# Print logging full path
$logFile = Join-Path $targetFolder 'syncthing.log'
Write-Host "Syncthing log file: $logFile"

$guiUrls = Select-String -Path $logFile -Pattern "Access the GUI via the following URL: (.*)" | ForEach-Object { $_.Matches.Groups[1].Value } | Select-Object -Unique
$guiUrlsAggregated = $guiUrls -join ", "

Write-Host "Syncthing GUI Urls: $guiUrlsAggregated "
