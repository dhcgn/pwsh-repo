<#
.DESCRIPTION
Extract audio as mp3 from video using ffmpeg
#>

param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({ $_.Exists })]
    [System.IO.FileInfo]
    $InputVideoFile,
    [System.IO.FileInfo]
    $OutputAudioFile
)

# Check ffmpeg
if ($null -eq (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg is not installed. Please install ffmpeg and try again. And make is available in the PATH."
    exit 1
}

if($null -eq $OutputAudioFile) {
    $OutputAudioFile = [System.IO.Path]::ChangeExtension($InputVideoFile.FullName, ".mp3")
}

if ($OutputAudioFile.Exists) {
    Write-Warning "File $OutputAudioFile already exists. Prepending with timestamp."
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $OutputAudioFile = [System.IO.Path]::ChangeExtension($InputVideoFile.FullName, ".$timestamp.mp3")
}

$cmd = "ffmpeg -i ""$InputVideoFile"" ""$OutputAudioFile"""
Write-Host "Running command: $cmd"
Invoke-Expression $cmd
if ($LASTEXITCODE -ne 0) {
    Write-Error "ffmpeg failed with exit code $LASTEXITCODE"
    exit 1
}

Get-ChildItem $OutputAudioFile
