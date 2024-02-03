<#
.SYNOPSIS
    This script generates a secure random string.

.DESCRIPTION
    The Get-RandomSecure.ps1 script generates a secure random string using the RNGCryptoServiceProvider class from the System.Security.Cryptography namespace. The strength of the generated string can be specified as a parameter. If no strength is provided or if the provided strength is less than 1, the default strength of 32 characters (256 bits) is used. The generated string is base64 encoded and safe for URL use, as '+' and '/' characters are replaced with '-' and '_', respectively, and trailing '=' characters are removed.

.PARAMETER Strength
    The strength of the random string to be generated. This is the length of the string in bytes. If not provided or if less than 1, a default strength of 32 characters (256 bits) is used.

.EXAMPLE
    .\Get-RandomSecure.ps1 -Strength 16

    This will generate a secure random string of 16 bytes in length.

#>
param (
    [int]
    $Strength
)

if ($Strength -lt 1) {
    $Strength = 256 / 8
}

$rnd = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
$bytes = New-Object byte[] $Strength
$rnd.GetBytes($bytes)
$base64 = [System.Convert]::ToBase64String($bytes)
$base64.Replace("+", "-").Replace("/", "_").Replace("=", "")