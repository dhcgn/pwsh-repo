<#
.SYNOPSIS
Backup-Scripts based on restic (https://restic.net/)

#>

function Invoke-RestoreRestic {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Name,
        [System.IO.DirectoryInfo]
        $TargetDirectory
    )

    if (-not (Test-ResticRepo -Name $Name)) {
        return
    }

    $repo = $env:RESTIC_CUSTOM_REPOSITORY_WITHOUT_NAME + $Name
    $cmd = "restic -r $repo restore latest --target $($TargetDirectory.FullName)"
    Write-Host $cmd -ForegroundColor Cyan
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Backup failed" -Category InvalidResult
        return
    }

    Get-ChildItem $TargetDirectory
}

function Test-ResticRepo {
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Name
    )

    if ($null -eq (Get-Command restic -ErrorAction SilentlyContinue)) {
        Write-Error "restic is not available" -Category NotInstalled
        return $false
    }

    if ($null -eq $env:RESTIC_CUSTOM_REPOSITORY_WITHOUT_NAME) {
        Write-Error 'Enviroment variable $env:RESTIC_CUSTOM_REPOSITORY_WITHOUT_NAME does not exist' -Category ObjectNotFound
        return $false
    }

    if ($null -eq $env:RESTIC_PASSWORD_FILE) {
        Write-Error 'Enviroment variable $env:RESTIC_PASSWORD_FILE does not exist' -Category ObjectNotFound
        return $false
    }

    if (-not (Test-Path $env:RESTIC_PASSWORD_FILE)) {
        Write-Error 'Password file $env:RESTIC_PASSWORD_FILE does not exist' -Category ObjectNotFound
        return $false
    }

    $repo = $env:RESTIC_CUSTOM_REPOSITORY_WITHOUT_NAME + $Name
    $cmd = "restic -r $repo check --no-cache"
    Write-Host $cmd -ForegroundColor Cyan
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Check failed, maybe not init" -Category InvalidResult
        return $false
    }
    return $true
}

function Invoke-BackupRestic {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Name,
        [ValidateScript({ Test-Path $_ })]
        [System.IO.FileInfo[]]
        $Files,
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [System.IO.DirectoryInfo[]]
        $Directories
    )

    if (-not (Test-ResticRepo -Name $Name)) {
        return
    }

    $backupSources = ""
    if ($null -ne $Files) {
        $backupSources += $Files | % { $_.FullName } | % { "`"$_`"" } | % { $_ -join " " }
    }
    if ($null -ne $Directories) {
        $backupSources += " "
        $backupSources += $Directories | % { $_.FullName } | % { "`"$_`"" } | % { $_ -join " " }
    }

    $repo = $env:RESTIC_CUSTOM_REPOSITORY_WITHOUT_NAME + $Name
    $cmd = "restic -r $repo backup $backupSources"
    Write-Host $cmd -ForegroundColor Cyan
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Backup failed" -Category InvalidResult
        return
    }
}
