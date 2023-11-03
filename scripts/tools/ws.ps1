if($null -eq (Get-Command workplace-sync -ErrorAction SilentlyContinue)) {
    Write-Error "workplace-sync not set as alias"
    return
}

workplace-sync --host ws.hdev.io