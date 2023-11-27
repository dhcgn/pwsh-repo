<#
.EXAMPLE
Get-LatestGithubRelease -DownloadFolder C:\temp -AssetFilter restic_*_windows_amd64.zip -Repository restic/restic
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [System.IO.DirectoryInfo]
    $DownloadFolder,
    [Parameter(Mandatory = $true)]
    $AssetFilter,
    [Parameter(Mandatory = $true)]
    $Repository
)

# Check folder exists
if (-not (Test-Path $DownloadFolder -PathType Container)) {
    Write-Error "Folder $DownloadFolder does not exist" -Category ObjectNotFound
    return
}

$Repository = $Repository.TrimStart("/")
$Repository = $Repository.TrimEnd("/")

# Get latest release
$url = "https://api.github.com/repos/$Repository/releases/latest"
$j = Invoke-RestMethod -Uri $url
if ($null -eq $j) {
    Write-Error "Could not get latest release from $Repository with $url" -Category InvalidResult
    return
}
$asset = $j.assets | ? { $_.name -like $AssetFilter }
$url = $asset  | % { $_.browser_download_url }
$assetname = $asset  | % { $_.name }
Write-Host "Download $assetname from $url"

if ($null -eq $url -or $null -eq $assetname) {
    Write-Error "Could not find asset with filter $AssetFilter" -Category InvalidResult
    return
}

$tempFilePath = Join-Path $env:TEMP $assetname
Invoke-WebRequest -Uri $url -OutFile $tempFilePath

$tempFolder = Join-Path $env:TEMP ('Get-LatestResticExecutable-' + [System.Guid]::NewGuid())
Expand-Archive -Path $tempFilePath -DestinationPath $tempFolder -Force

$exe = Get-ChildItem $tempFolder -Recurse -Include *.exe
Move-Item -Path $exe -Destination $DownloadFolder -Force

Remove-Item -Path $tempFilePath -Force
Remove-Item -Path $tempFolder -Recurse -Force 

Get-ChildItem $DownloadFolder -Recurse -Filter $exe.Name