<#

.SYNOPSIS
Starts PowerShell with evaluated rights without required password input in the UAC prompt

.EXAMPLE
Load-Credential -Name localadmin | %{Start-PowerShellAs -Credential $_ }

.DESCRIPTION

.LINK

#>

param([System.Management.Automation.PSCredential]$Credential)

if ($null -ne $Credential) {
	Start-Process -FilePath powershell.exe -Credential $Credential -Args '-noprofile  -command "&{ Start-Process pwsh.exe -Verb runas }"'
}else{
	Start-Process -FilePath powershell.exe -Verb runas -Args '-noprofile  -command "&{ Start-Process pwsh.exe -Verb runas }"'
}