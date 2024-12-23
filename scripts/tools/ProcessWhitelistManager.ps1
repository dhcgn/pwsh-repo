<#
.SYNOPSIS
    Manages a process whitelist and terminates non-whitelisted processes.

.DESCRIPTION
    This script provides functionality to create a whitelist of running processes
    and to terminate processes that are not in the whitelist. It's useful for
    system maintenance, security purposes and of course gaming.

.NOTES
    File Name      : process_whitelist_killer.ps1
    Prerequisite   : PowerShell 5.1 or later
    Warning        : Use with caution as terminating processes can lead to data loss
#>

function Save-CurrentProcessesToWhitelist {
    <#
    .SYNOPSIS
        Saves currently running processes to a whitelist file.
    
    .DESCRIPTION
        Creates a JSON file containing names of all currently running processes.
        The file is saved in the user's home directory as 'whitelist.json'.
    
    .OUTPUTS
        System.IO.FileInfo - Information about the created whitelist file
    #>
    
    # Define the path for the whitelist file in user's home directory
    $whitelistPath = Join-Path $env:HOMEDRIVE $env:HOMEPATH "whitelist.json"
    
    # Get unique process names and save them to the whitelist file
    Get-Process | Select-Object Name -Unique | ConvertTo-Json | Set-Content -Path $whitelistPath
    
    # Return the file information of the created whitelist
    Get-ChildItem $whitelistPath
}

function Stop-NonWhitelistedProcesses {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Url
    )
    <#
    .SYNOPSIS
        Stops processes that are not in the whitelist.
    
    .DESCRIPTION
        Reads the whitelist from either a URL or local JSON file and compares it with currently
        running processes. Attempts to stop any process not found in the whitelist.
    
    .PARAMETER Url
        Optional URL to download the whitelist from. If not provided, uses local whitelist.json.
    
    .NOTES
        The actual Stop-Process command is commented out by default for safety.
    #>
    
    if ($Url) {
        try {
            $whitelist = Invoke-RestMethod -Uri $Url -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to download whitelist from URL: $Url. Error: $_"
            return
        }
    }
    else {
        # Load the whitelist from the JSON file
        $whitelistPath = Join-Path $env:HOMEDRIVE $env:HOMEPATH "whitelist.json"
        if (-not (Test-Path -Path $whitelistPath)) {
            Write-Error "Whitelist file '$whitelistPath' not found. Please create a whitelist first."
            return
        }
        $whitelist = Get-Content -Path $whitelistPath | ConvertFrom-Json
    }
    
    # if list is null or has no elements 
    if ($whitelist -eq $null -or $whitelist.Count -eq 0) {
        Write-Error "Whitelist is empty. Please create a whitelist first."
        return
    }
    
    # Get current processes
    $processes = Get-Process | Select-Object Name -Unique
    
    # Compare current processes against whitelist and stop non-whitelisted ones
    $processesToStop = $processes | Where-Object { $whitelist.Name -notcontains $_.Name }

    if ($processesToStop.Count -eq 0) {
        Write-Host "No non-whitelisted processes found."
        return
    }

    # Display the processes to stop
    $processNames = $processesToStop.Name -join ', '
    Write-Host "Stopping $($processesToStop.Count) process(es): $processNames"

    # Ask user for confirmation
    # [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
    $processesToStop | Stop-Process -Confirm
}