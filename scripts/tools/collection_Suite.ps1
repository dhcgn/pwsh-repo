function global:New-Guid {
    [System.Guid]::NewGuid()
}

Set-Alias -Name guid -Value New-Guid -Scope Global

function Update-PwshRepo {
    $f = "C:\dev\pwsh-repo\"
    if (Test-Path $f) {
        Write-Host "Pulling from $f"
        git -C $f pull
    }
}