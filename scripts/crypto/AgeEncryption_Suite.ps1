
function global:Encrypt-File {
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

    [string]$in = Resolve-Path $File
    $out = $in + ".age"
    if (-not [System.String]::IsNullOrWhiteSpace($Destination)) {
        $out = $Destination
    }

    if (Test-Path $out) {
        $out = $out + ("_{0:yyyy-MM-dd_HH-mm-ss-fff}" -f (Get-Date))
    }

    age -e `
        -r $keyList["SoftPrivate"] `
        -r $keyList["SoftWork"] `
        -o $out `
        $in 

    if (-not $?) {
        Write-Error "Failed to encrypt file"
        return
    }
    Get-ChildItem $out
}

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

    $mainkeyFile = $fileList.AgeEncryptedMainKey

    if (-not (Test-Path $mainkeyFile)) {
        Write-Error "Main key file not found at $mainkeyFile"
        return
    }

    # TODO: restore of filename if ending with .age
    [string]$in = Resolve-Path $File
    $out = $in + ".plain"
    if (Test-Path $out) {
        $out = $out + ("_{0:yyyy-MM-dd_HH-mm-ss-fff}.plain" -f (Get-Date))
    }

    age -d `
        -i $mainkeyFile  `
        -o $out `
        $in 
}

# is aged installed
if ($null -eq (Get-Command age -ErrorAction SilentlyContinue)) {
    Write-Error "Command age not found, install age with ""workplace-sync -host ws.hdev.io -name age"""
    return
}