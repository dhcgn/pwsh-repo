<#
.SYNOPSIS
    This script changes the export resolution of PowerPoint slides.

.DESCRIPTION
    The Set-PowerPointExportResolution.ps1 script changes the export resolution of PowerPoint slides by modifying a registry key. The new resolution is set to 300 DPI. If the registry key does not exist, it is created.

.EXAMPLE
    .\Set-PowerPointExportResolution.ps1

    This will set the export resolution of PowerPoint slides to 300 DPI.

#>
# https://docs.microsoft.com/en-us/office/troubleshoot/powerpoint/change-export-slide-resolution
$path = "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options"
$old = Get-ItemProperty -Path $path  -ErrorAction Ignore | ForEach-Object { $_.ExportBitmapResolution }
$new = 300
if ($null -ne $old) {
    Write-Host "Old value: $old"
    Write-Host "New value: $new"

    Set-ItemProperty -Path $path  `
    -Name ExportBitmapResolution `
    -Value $new
}else{
    Write-Host "Old value: not set"
    Write-Host "New value: $new"

    New-ItemProperty -Path $path  `
    -Name ExportBitmapResolution `
    -PropertyType DWord `
    -Value $new
}
