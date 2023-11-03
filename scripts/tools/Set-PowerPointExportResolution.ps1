# https://docs.microsoft.com/en-us/office/troubleshoot/powerpoint/change-export-slide-resolution
$path = "HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options"
$old = Get-ItemProperty -Path $path  -ErrorAction Ignore | % { $_.ExportBitmapResolution }
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
