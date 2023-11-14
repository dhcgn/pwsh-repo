<#
.DESCRIPTION
Pin a CID to a remote pinning service.
#>

param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$CID
)


if ($null -eq (Get-Command ipfs -ErrorAction Ignore)){
    Write-Error "ipfs command not found. Please install IPFS."
    exit 1
}

$format= ipfs cid format $CID *>&1
if ($format -like "*invalid*") {
    Write-Error "Error CID not valid base32"
    exit 1
}

$cmds = ipfs pin remote service ls | %{$name= $_.Split(" ")[0]; "ipfs pin remote add $CID --service=$name --background"}
foreach($cmd in $cmds) {
    Write-Host $cmd -ForegroundColor Cyan
    Invoke-Expression $cmd
}