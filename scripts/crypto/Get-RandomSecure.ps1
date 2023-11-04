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
$base64.Replace("+", "").Replace("/", "").Replace("=", "")