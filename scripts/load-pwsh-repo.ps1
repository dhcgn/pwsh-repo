$scripts = Get-ChildItem $PSScriptRoot -File -Recurse -Include *.ps1 -Exclude *_Suite.ps1
$scripts | ForEach-Object {
    Set-Alias -Name $_.BaseName -Value $_.FullName -Scope Global
}

$suites = Get-ChildItem $PSScriptRoot -File -Recurse -Include *_Suite.ps1
$suites | ForEach-Object {
    . $_.FullName
}
