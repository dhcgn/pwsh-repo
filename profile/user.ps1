#BEGIN generated personal profile

$exes = Get-ChildItem C:\ws\* -File -Include *.exe
$exes | ForEach-Object {
    Set-Alias -Name $_.BaseName -Value $_.FullName -Scope Global
}

#END generated personal profile
