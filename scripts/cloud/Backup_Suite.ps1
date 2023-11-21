<#
.SYNOPSIS
Backup-Scripts based on restic (https://restic.net/)

#>

function Check-BackupRestic {
    [OutputType([System.Boolean])]
    param()

    if ($null -eq (Get-Command restic -ErrorAction SilentlyContinue)) {
        Write-Error "restic is not available" -Category NotInstalled
        return $false
    }
    return $true
}

function New-BackupRestic {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $RepositoryFile ,
        [Parameter(Mandatory = $true)]
        [string]
        $Path,
        [Parameter(Mandatory = $true)]
        [string]
        $Repository,
        [Parameter(Mandatory = $true)]
        [string]
        $Password
    
    )

}

function Get-BackupRestic {
    
}