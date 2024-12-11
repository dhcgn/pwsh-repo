<#
.SYNOPSIS
    This script pins a CID to a remote pinning service using IPFS.

.DESCRIPTION
    The Invoke-RemotePinning.ps1 script pins a CID (Content Identifier) to a remote pinning service using IPFS (InterPlanetary File System). The script first checks if the IPFS command is available. If not, it throws an error. It then validates the CID. If the CID is not valid, it throws an error. Finally, it retrieves the list of remote pinning services and pins the CID to each service.

.PARAMETER CID
    The CID to pin to the remote pinning service. This parameter is mandatory and can be piped to the script.

.EXAMPLE
    Invoke-RemotePinning -CID QmY7Yh4UquoXHLPFo2XbhXkhBvFoPwmQUSa92pxnxjQuPU

    This will pin the CID "QmY7Yh4UquoXHLPFo2XbhXkhBvFoPwmQUSa92pxnxjQuPU" to all remote pinning services.

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