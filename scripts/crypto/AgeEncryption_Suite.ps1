<#
.SYNOPSIS
    Encrypt files with age encryption with multiple keys defiend in $AgeEncryptionKeys

.EXAMPLE
    $f = New-TemporaryFile; Set-Content $f "Hello World"; Encrypt-File -File $f | %{Decrypt-File -File $_ | Get-Content}      
#>
function global:Encrypt-File {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] $File,
        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $Destination,
        [Parameter(Mandatory = $true)]
        [String[]] $Receipents,
        [Parameter(Mandatory = $false)]
        [Switch] $AsciiArmor = $false

    )

    Test-AgeCapailities

    if (-not (Test-Path $File)) {
        Write-Error "File not found at $File"
        return
    }

    [string]$in = Resolve-Path $File
    $out = $in + ".age"
    if ($Destination -ne $null) {
        $out = $Destination
    }

    if (Test-Path $out) {
        $out = $out + ("_{0:yyyy-MM-dd_HH-mm-ss-fff}" -f (Get-Date))
    }

    $cmd = "age -e "
    foreach ($key in $Receipents) {
        $cmd += " -r $($key) "
    }
    if ($AsciiArmor) {
        $cmd += " -a $in"
    }
    else {
        $cmd += " -o $out $in"
    }
    
    Invoke-Expression $cmd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to encrypt file"
        return
    }
    if (-not $AsciiArmor) {
        Get-ChildItem $out
    }
}

function global:Encrypt-FileWithMyKeys {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] $File,
        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $Destination,
        [Parameter(Mandatory = $false)]
        [Switch] $AsciiArmor = $false
    )

    Encrypt-File -File $File -Destination $Destination -Receipents @($AgeEncryptionKeys.Values) -AsciiArmor:$AsciiArmor
}

function global:Encrypt-FileWithMyHSMKeys {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] $File,
        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $Destination,
        [Parameter(Mandatory = $false)]
        [Switch] $AsciiArmor = $false
    )

    if (-Not(Test-Path "C:\ProgramData\AgePluginYubikey")) {
        Write-Error "AgePluginYubikey not installed, install with Install-AgePluginYubikey and set it to your PATH"
    }
    if ($env:Path -notlike "*C:\ProgramData\AgePluginYubikey*") {
        Write-Error "AgePluginYubikey not set to your PATH"
    }

    Encrypt-File -File $File -Destination $Destination -Receipents @($AgeEncryptionHSMKeys.Values) -AsciiArmor:$AsciiArmor
}


<#
.SYNOPSIS
    Decrypt files with age encryption with the private key filepath defiend in $AgeDecryptionKey

.EXAMPLE
    $f = New-TemporaryFile; Set-Content $f "Hello World"; Encrypt-File -File $f | %{Decrypt-File -File $_ | Get-Content}    
#>
function global:Decrypt-File {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] $File,
        [Parameter(Mandatory = $false)]
        [string] $Destination
    )

    Test-AgeCapailities

    $mainkeyFile = $fileList.AgeEncryptedMainKey

    if (-not (Test-Path $AgeDecryptionKey)) {
        Write-Error "Main key file not found at $mainkeyFile"
        return
    }

    # TODO: restore of filename if ending with .age
    [string]$in = Resolve-Path $File
    $out = $in + ".plain"
    if (Test-Path $out) {
        $out = $out + ("_{0:yyyy-MM-dd_HH-mm-ss-fff}.plain" -f (Get-Date))
    }

    $cmd = "age -d -i $AgeDecryptionKey -o $out $in"
    Invoke-Expression $cmd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to decrypt file"
        return
    }
    Get-ChildItem $out
}

function Install-AgePluginYubikey {
    $f = "C:\ProgramData\AgePluginYubikey"
    if (-Not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f
    }
    Get-ChildItem -Path $f -File -Include *.exe -Recurse | Get-FileHash | ForEach-Object { Write-Host "Before: $($_.Hash) $($_.Path | Get-ChildItem | Select-Object name)" }
  
    $url = "https://github.com/str4d/age-plugin-yubikey/releases/download/v0.4.0/age-plugin-yubikey-v0.4.0-x86_64-windows.zip"
    $zip = "$f\age-plugin-yubikey.zip"
    Invoke-WebRequest -Uri $url -OutFile $zip 
    Expand-Archive -Path $zip -DestinationPath $f -Force
    Get-ChildItem -Path $f -File -Include *.exe -Recurse | Move-Item -Destination $f -Force
    Remove-Item $zip
    Get-ChildItem -Path $f -Directory | Remove-Item -Recurse -Force

    Get-ChildItem -Path $f -File -Include *.exe -Recurse | Get-FileHash | ForEach-Object { Write-Host "After:  $($_.Hash) $($_.Path | Get-ChildItem | Select-Object name)" }
}


function Test-AgeCapailities {

    # is aged installed
    if ($null -eq (Get-Command age -ErrorAction SilentlyContinue)) {
        Write-Error "Command age not found, install age with ""workplace-sync -host ws.hdev.io -name age"""
        return
    }

    if ($AgeEncryptionKeys -eq $null) {
        Write-Error 'AgeEncryptionKeys not found, must be set your $PROFILE'
        return
    }

    if ($AgeDecryptionKey -eq $null) {
        Write-Error 'AgeDecryptionKey not found, must be set your $PROFILE'
        return
    }
}

$f = "C:\ProgramData\AgePluginYubikey"
if (Test-Path $f) {
    $env:Path += ";$f"
}

Test-AgeCapailities
