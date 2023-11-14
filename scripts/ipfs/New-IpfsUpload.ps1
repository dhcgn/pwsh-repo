<#
.DESCRIPTION

Uploads a file to IPFS with the PINATA API and returns the hash with different urls to popular gateways.
A $env:PINATAAPIJWT must be present, this script will use these settings: {"cidVersion":1, "wrapWithDirectory": true}

#>

param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [System.IO.FileInfo]$File
)

# Get the token from environment variable
$token = $env:PINATAAPIJWT
if($null -eq $token -or $token -eq "") {
    Write-Error "Environment variable PINATAAPIJWT is not set."
    exit 1
}

# Check if file exists
if (!($File.Exists)) {
    Write-Error "File $File does not exist."
    exit 1
}

$form = @{
    pinataOptions = '{"cidVersion":1, "wrapWithDirectory": true}'
    pinataMetadata = '{"name":"not-set"}' | ConvertFrom-Json | %{$_.name = $File.Name; $_} | ConvertTo-Json
    file = Get-Item $File
}

$securetoken = ConvertTo-SecureString $token -AsPlainText -Force

$r = Invoke-WebRequest -Uri "https://api.pinata.cloud/pinning/pinFileToIPFS" -Method Post -Form $form -Authentication Bearer -Token $securetoken 
if ($r.StatusCode -ne 200) {
    Write-Error "Error uploading file to IPFS: $($r.StatusCode) - $($r.StatusDescription)"
    exit 1
}
$ipfsResult = $r.Content | ConvertFrom-Json

Write-Host "$($ipfsResult | ConvertTo-Json)"

$urls = @(
    "https://cloudflare-ipfs.com/ipfs/",
    "https://gateway.pinata.cloud/ipfs/",
    "https://ipfs.io/ipfs/"
)

Write-Host ""
Write-Host "Gateway URLs:"
foreach($url in $urls) {
    Write-Host "$url$($ipfsResult.IpfsHash)"
}
Write-Host "https://$($ipfsResult.IpfsHash).ipfs.dweb.link/"

Write-Host ""
Write-Host "ipfs commands:"
Write-Host "ipfs ls $($ipfsResult.IpfsHash)"
Write-Host "ipfs get $($ipfsResult.IpfsHash) -o $($File.Name)"

Write-Host ""
Write-Host "ipfs expert"
Write-Host "https://cid.ipfs.tech/#$($ipfsResult.IpfsHash)"