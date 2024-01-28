<#

.SYNOPSIS
    Tests if a file is printable.

#>
[OutputType([bool])]
param(
    [System.IO.FileInfo]$File,
    [long]$MaxSize = 1024
)

# Get the content of the file as a byte stream, convert each byte to a char, 
# and check if it's a control character. Group the results and count the number of control characters.
$controlCharCount = Get-Content $File -AsByteStream -TotalCount $MaxSize | 
                    ForEach-Object { [System.Char]::IsControl([System.Convert]::ToChar($_)) } | 
                    Group-Object -NoElement | 
                    Where-Object { $_.Name -eq "True" } | 
                    ForEach-Object { $_.Count }

# If there are no control characters, the file is printable
if ($controlCharCount -eq $null -or $controlCharCount -eq 0) {
    return $true
}

return $false