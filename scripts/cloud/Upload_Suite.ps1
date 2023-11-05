function global:Publish-FileUnprotected {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]
        $File
    )

    $source = (Resolve-Path $File).Path
    if ($null -eq $source) {
        Write-Error "File not found: $File"
        return
    }

    if (Test-Path -Path $File -PathType Container) {
        $temp = New-TemporaryFile
        Remove-Item -Path $temp
        $temp = $temp.FullName + ".zip"
        $File = $temp
        Compress-Archive -Path $source -DestinationPath $temp
        $source = $temp
    }

    $link = Publish-File -File $source

    Write-Host "Link: $link"
}

function global:Publish-FilePasswortProtected {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]
        $File
    )

    $source = (Resolve-Path $File).Path
    if ($null -eq $source) {
        Write-Error "File not found: $File"
        return
    }

    $7zipExe = "C:\Program Files\7-Zip\7z.exe"
    if(-not (Test-Path $7zipExe )){
        Write-Error "7zip not at $7zipExe found, please install it first"
        return
    }
 
    $rnd7zip = Get-RandomSecure -Strength (64 / 8)
    $7zipname = ("{0}.7z" -f $rnd7zip)
    $7zipfile = Join-Path $env:TEMP $7zipname

    $pass = Get-RandomSecure -Strength (128 / 8)
    
    .$7zipExe a "$($7zipfile)" "$source" -p"$pass" -mhe=on
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create 7zip file."
        return
    }

    $link = Publish-File -File $7zipfile

    Remove-Item $7zipfile

    Write-Host ""
    Write-Host "Link: $link"
    Write-Host "Pass: $pass"
}

# function global:Publish-AgeFileToHosting {
#     param (
#         [Parameter(Mandatory = $true)]
#         [System.IO.FileInfo]
#         $File
#     )

#     $r = Invoke-WebRequest https://agefiles.hdev.io/ -In $File -Method POST
#     if ($r.StatusCode -ne 200) {
#         Write-Error "Failed to upload file to hosting, status code $($r.StatusCode)"
#         return
#     }
#     Write-Host ("Link: {0}" -f $r.Content)
# }

function global:Publish-File {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]
        $File
    )

    $source = (Resolve-Path $File).Path
    if ($null -eq $source) {
        Write-Error "File not found: $File"
        return
    }

    if (Test-Path -Path $File -PathType Container) {
        Write-Error "Directory not supported"
    }

    if (-not (Test-Rclone)) {
        return
    }

    $hashsumhex = (Get-FileHash -Path $source -Algorithm SHA256).Hash
    $hashData = [System.Convert]::FromHexString($hashsumhex) | Select-Object -First (64/8)
    $base64sum = [System.Convert]::ToBase64String($hashData)
    $base64sum = $base64sum.Replace("+", "-").Replace("/", "_").Replace("=", "")
    

    $rnd = Get-RandomSecure -Strength (128 / 8)
    $dir = ("{0:yyyy-MM-dd}_{1}_{2}" -f (Get-Date), $rnd, $base64sum)
    
    $rcloneConf = Join-Path $env:USERPROFILE ".rclone\rclone.conf"
    $publicHost = Get-Content -Path (Join-Path $env:USERPROFILE ".rclone\host.txt")
    $sanitzedFileName = (Get-ChildItem $source).Name -replace "[^a-zA-Z0-9+\._]","-"

    rclone copyto $source r2:pub-sync/_/$dir/$sanitzedFileName --progress --config $rcloneConf | Out-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Error "rclone upload failed."
        return
    }

    $urlencodedFilename = [uri]::EscapeDataString($sanitzedFileName)
    $link = ("https://$publicHost/_/{0:yyyy-MM-dd}_{1}_{2}/{3}" -f (Get-Date), $rnd, $base64sum, $urlencodedFilename)
    $link
}

function global:Get-PublishedFiles{
    if (-not (Test-Rclone)) {
        return
    }
    $rcloneConf = Join-Path $env:USERPROFILE ".rclone\rclone.conf"
    $publicHost = Get-Content -Path (Join-Path $env:USERPROFILE ".rclone\host.txt")
    rclone lsf r2:pub-sync/_/ -R --config $rcloneConf  | ? { $_ -notlike "*/" } | % { "https://$publicHost/_/{0}" -f $_ }
}


function global:Test-Rclone {
    if ($null -eq (Get-Command rclone -ErrorAction Ignore)) {
        Write-Error "rclone not found, please install it first and add it to your path. You could run workplace-sync.exe -host ws.hdev.io -name rclone"
        return $false
    }

    $rcloneConf = Join-Path $env:USERPROFILE ".rclone\rclone.conf"
    if (-not (Test-Path $rcloneConf)) {
        Write-Error "rclone config not found: $rcloneConf"
        return $false
    }
    
    $publicHost = Join-Path $env:USERPROFILE ".rclone\host.txt"
    if (-not (Test-Path $publicHost)) {
        Write-Error "rclone public host not found: $publicHost"
        return $false
    }
   
    $true
}