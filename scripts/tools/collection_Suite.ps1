<#
.SYNOPSIS
    This function generates a new globally unique identifier (GUID).

.DESCRIPTION
    The New-Guid function generates a new GUID using the System.Guid .NET class's NewGuid method. The generated GUID is a unique 128-bit integer (16 bytes) that can be used across all time and space for all practical purposes.

.EXAMPLE
    New-Guid

    This will generate a new GUID.

#>
function global:New-Guid {
    [System.Guid]::NewGuid()
}

Set-Alias -Name guid -Value New-Guid -Scope Global

<#
.SYNOPSIS
    This function updates a PowerShell repository located at a specific path.

.DESCRIPTION
    The Update-PwshRepo function checks if a directory at the specified path exists. If it does, it executes a git pull command in that directory to update the repository.

.PARAMETER f
    The path to the PowerShell repository. The default path is "C:\dev\pwsh-repo\".

.EXAMPLE
    Update-PwshRepo

    This will update the PowerShell repository located at "C:\dev\pwsh-repo\".

#>
function Update-PwshRepo {
    $f = "C:\dev\pwsh-repo\"
    if (Test-Path $f) {
        Write-Host "Pulling from $f"
        git -C $f pull
    }
}