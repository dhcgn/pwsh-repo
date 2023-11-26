<#
.DESCRIPTION
Move media files to folders named after the date when the media was taken or created.
#>

param(
    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]
    $sourceFolder,
    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]
    $targetFolder
)

if (-not (Test-Path $sourceFolder)){
    Write-Host "Source folder '$sourceFolder' does not exist."
    return
}

if (-not (Test-Path $targetFolder)){
    Write-Host "Create folder '$targetFolder'"
    New-Item -Path $targetFolder -ItemType Directory
}

if($null -eq (Get-Command Get-DateTaken -ErrorAction SilentlyContinue)){
    Write-Host "Get-DateTaken function not found. Please load the script 'scripts/media/Get-DateTaken.ps1' first."
    return
}

Get-ChildItem -Path $sourceFolder | ForEach-Object {
    # Write-Host "File: $_"
    $dateDateTaken = Get-DateTaken -file $_
    # Write-Host "Date taken: $dateDateTaken"
    $folderName = $dateDateTaken.ToString('yyyy-MM-dd')
    # Write-Host "Folder name: $folderName"
    
    $targetFolderWithDate = Join-Path -Path $targetFolder -ChildPath ("{0} - NEW" -f $folderName)
    if (-not (Test-Path $targetFolderWithDate)){
        Write-Host "Create folder '$targetFolderWithDate'"
        New-Item -Path $targetFolderWithDate -ItemType Directory
    }
    Move-Item -Path $_.FullName -Destination $targetFolderWithDate -Verbose
}