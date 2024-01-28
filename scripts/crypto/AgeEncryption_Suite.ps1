<#
.SYNOPSIS
    Encrypt a file

.EXAMPLE
    $f = New-TemporaryFile; Set-Content $f "Hello World"; Encrypt-File -File $f -Receipents age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p -AsciiArmor  
#>
function global:Encrypt-File {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] 
        [ValidateScript({Test-Path $_}, ErrorMessage = "File '{0}' not found")]
        $File,
        
        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $Destination,
        
        [Parameter(Mandatory = $false)]
        [String[]] $Receipents,
        
        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $ReceipentsFile,

        [Parameter(Mandatory = $false)]
        [Switch] $AsciiArmor = $false
    )

    Test-AgeCapailities

    if (-not (Test-Path $File)) {
        Write-Error "File not found at $File"
        return
    }

    if ($null -eq $Receipents -and $null -eq $ReceipentsFile ) {
        Write-Error "Receipents or ReceipentsFile must be set"
        return
    }

    if ($null -ne $ReceipentsFile){
        if (-not (Test-Path $ReceipentsFile)) {
            Write-Error "ReceipentsFile not found at $ReceipentsFile"
            return
        }
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
    if ($ReceipentsFile -ne $null) {
        $cmd += " -R ""$($ReceipentsFile.FullName)"" "
    }
    if ($AsciiArmor) {
        $cmd += " -a  "
    }
    else {
        $cmd += " -o ""$out""  "
    }
    $cmd += " $in "
    
    Write-Host $cmd -ForegroundColor Cyan
    Invoke-Expression $cmd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to encrypt file"
        return
    }
    if (-not $AsciiArmor) {
        Get-ChildItem $out
    }
}

<#
.SYNOPSIS
    Encrypt files with age encryption with multiple keys defiend in $AgeEncryptionKeys

.EXAMPLE
    $f = New-TemporaryFile; Set-Content $f "Hello World"; Encrypt-FileWithMyKeys -File $f | %{Decrypt-File -File $_ | Get-Content}     
#>
function global:Encrypt-FileWithMyKeys {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] 
        [ValidateScript({Test-Path $_}, ErrorMessage = "File '{0}' not found")]
        $File,
        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $Destination,
        [Parameter(Mandatory = $false)]
        [Switch] $AsciiArmor = $false
    )

    $receipentsFile = Join-Path $env:USERPROFILE ".age\receipients_soft.txt"
    Encrypt-File -File $File -Destination $Destination -ReceipentsFile $receipentsFile -AsciiArmor:$AsciiArmor
}

function global:Encrypt-FileWithMyHSMKeys {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] 
        [ValidateScript({Test-Path $_}, ErrorMessage = "File '{0}' not found")]
        $File,
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

    $receipentsFile = Join-Path $env:USERPROFILE ".age\receipients_hsm.txt"
    Encrypt-File -File $File -Destination $Destination -ReceipentsFile $receipentsFile -AsciiArmor:$AsciiArmor
}

<#
.SYNOPSIS
    Decrypt files with age encryption with the private key filepath defiend in $AgeDecryptionKeyFilePath

.EXAMPLE
    $f = New-TemporaryFile; Set-Content $f "Hello World"; Encrypt-FileWithMyKeys -File $f | %{Decrypt-File -File $_ | Get-Content}  
#>
function global:Decrypt-FileWithHSMKeys {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] 
        [ValidateScript({Test-Path $_}, ErrorMessage = "File '{0}' not found")]
        $File,
        [Parameter(Mandatory = $false)]
        [string] $Destination,
        [Parameter(Mandatory = $false)]
        [switch] $PrintDecryptedContent
    )

    Test-AgeCapailities

    if (-Not(Test-Path "C:\ProgramData\AgePluginYubikey")) {
        Write-Error "AgePluginYubikey not installed, install with Install-AgePluginYubikey and set it to your PATH"
    }
    if ($env:Path -notlike "*C:\ProgramData\AgePluginYubikey*") {
        Write-Error "AgePluginYubikey not set to your PATH"
    }

    $receipentsFile = Join-Path $env:USERPROFILE ".age\identites_hsm.txt"

    if (-not (Test-Path $receipentsFile)) {
        Write-Error "HSM identiy file not found at $receipentsFile"
        return
    }

    # TODO: restore of filename if ending with .age
    [string]$in = Resolve-Path $File
    $out = $in + ".plain"
    if (Test-Path $out) {
        $out = $out + ("_{0:yyyy-MM-dd_HH-mm-ss-fff}.plain" -f (Get-Date))
    }

    $cmd = "age -d -i ""$receipentsFile"" "
    if (-not $PrintDecryptedContent) {
        $cmd += " -o ""$out"" "
    }
    $cmd += " ""$in"""

    Write-Host $cmd -ForegroundColor Cyan
    Write-Host "!!! PRESS YUBIKEY BUTTON AFTER PIN !!!" -ForegroundColor Yellow
    Invoke-Expression $cmd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to decrypt file"
        return
    }
    if (-not $PrintDecryptedContent) {
        Get-ChildItem $out
    }    
}

<#
.SYNOPSIS
    Decrypt files with age encryption with the private key filepath defiend in $AgeDecryptionKeyFilePath

.EXAMPLE
    $f = New-TemporaryFile; Set-Content $f "Hello World"; Encrypt-FileWithMyKeys -File $f | %{Decrypt-File -File $_ | Get-Content}  
#>
function global:Decrypt-File {
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.IO.FileInfo] 
        [ValidateScript({Test-Path $_}, ErrorMessage = "File '{0}' not found")]
        $File,
        [Parameter(Mandatory = $false)]
        [string] $Destination,
        [Parameter(Mandatory = $false)]
        [switch] $PrintDecryptedContent
    )

    Test-AgeCapailities

    if (-not (Test-Path $AgeDecryptionKeyFilePath)) {
        Write-Error "Main key file not found at $AgeDecryptionKeyFilePath"
        return
    }

    # TODO: restore of filename if ending with .age
    [string]$in = Resolve-Path $File
    $out = $in + ".plain"
    if (Test-Path $out) {
        $out = $out + ("_{0:yyyy-MM-dd_HH-mm-ss-fff}.plain" -f (Get-Date))
    }

    $cmd = "age -d -i ""$AgeDecryptionKeyFilePath"" "
    if (-not $PrintDecryptedContent) {
        $cmd += " -o ""$out"" "
    }
    $cmd += " ""$in"""

    Invoke-Expression $cmd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to decrypt file"
        return
    }
    if (-not $PrintDecryptedContent) {
        Get-ChildItem $out
    }  
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

    $file = (Join-Path $env:USERPROFILE ".age\receipients_soft.txt")
    if (-not (Test-Path $file)) {
        Write-Error "Receipents file not found, must be set your $file"
        return
    }
    $file = (Join-Path $env:USERPROFILE ".age\receipients_hsm.txt")
    if (-not (Test-Path $file)) {
        Write-Error "Receipents file not found, must be set your $file"
        return
    }

    if ($null -eq $AgeDecryptionKeyFilePath -or (-not (Test-Path $AgeDecryptionKeyFilePath))) {
        Write-Error 'AgeDecryptionKeyFilePath not found, must be set your $PROFILE'
        return
    }
}

$f = "C:\ProgramData\AgePluginYubikey"
if (Test-Path $f) {
    $env:Path += ";$f"
}
