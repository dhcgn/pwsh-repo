<#
    .Description
    Get the SSH Config folder in sync by copying all files from /mnt/c/Users/%USERNAME%/.ssh/ to the wsl instance
    Call this script from the wsl instance
#>

$windowsUser = cmd.exe /c "echo %USERNAME%" 2>$null
if ($LASTEXITCODE -ne 0 -or $null -eq $windowsUser){
    Write-Error "Could not get Windows User"
    return
}

Write-Host "Windows User: $windowsUser"

$source = '/mnt/c/Users/' + $windowsUser + '/.ssh/*'
$destination = '~/.ssh/'

# Check if source exists
if (-Not (Test-Path $source)){
    Write-Error "Source does not exist: " + $source
    return
}

# Check if command dos2unix exists
if (-Not (Get-Command dos2unix -ErrorAction SilentlyContinue)){
    Write-Error "dos2unix is not installed"
    return
}

Copy-Item -Path $source -Destination $destination -Exclude known_hosts* -Recurse -Verbose -Force 

# Set permissions and line endings
Get-ChildItem -Path $destination | ForEach-Object { chmod 600 $_.FullName; dos2unix $_.FullName }