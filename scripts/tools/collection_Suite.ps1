function global:New-Guid {
    [System.Guid]::NewGuid()
}

Set-Alias -Name guid -Value New-Guid -Scope Global