<#
.SYNOPSIS
    Removes duplicate files from a directory by comparing their hashes.

.DESCRIPTION
    Removes duplicate files from a directory by comparing their hashes.
    The first file in the group is kept, the rest are deleted after confirmation.
    
.EXAMPLE
    Remove-DuplicatesByHash -Directory C:\temp\test -Recurse    
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    $Directory,
    [switch]
    $Recurse
)

$getChildItemArgs = @{
    Path = $Directory
    Recurse = $Recurse
    File = $true
  }

$duplicates = Get-ChildItem @getChildItemArgs | `
    Get-FileHash | `
    Group-Object Hash | `
    Where-Object{$_.Count -gt 1} | `
    ForEach-Object{$_.Group | Select-Object -Skip 1}

if ($duplicates.Count -eq 0) {
    Write-Host "No duplicates found in $Directory"
    return
}

Write-Host "Found $($duplicates.Count) duplicates in $Directory, these will be deleted after prompt:"
$duplicates | Format-Table Path, Hash -AutoSize

$duplicates | Remove-Item -Force -Confirm
