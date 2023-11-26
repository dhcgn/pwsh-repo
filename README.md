# pwsh-repo

This is my personal Powershell repo where a few scripts I often use.

:warning: No warranties in any kind :warning:

## Some Features

- Encryption with age-encryption.org and with HSM support
- Cloud Uploads with rclone to make files easy accesaable from everywhere
- Create a Powershell with elevalted rights without a password prompt
- Read `Date-Taken` from media files
- Transcribe audio and video files to text with OpenAI API
- Encode images to and from JpegXL/JXL

## Installation

1. Run `profile\init.ps1` this can be run repeatedly.
   1. This will add `shell.ps1` in each Powershell `$PROFILE` to run `Join-Path $env:USERPROFILE ".sharedScripting\sharedprofile.ps1"` so there is only one place to edit the profile.
2. This repo should be cloned to `C:\dev\pwsh-repo` so it works out of the box.
3. `sharedprofile.ps1` starts with every new Powershell session, `*.ps1` files next will be loaded executed in alphabetical order.
   1. There are sample scripts `*.sample` which can be rennamed.

## Installation from web

```powershell
Invoke-WebRequest 'https://raw.githubusercontent.com/dhcgn/pwsh-repo/main/profile/init.ps1' | Invoke-Expression
```

## Powershell Functions

Publish-FileUnprotected
Publish-FilePasswortProtected
Publish-File
Test-Rclone
Encrypt-File
Encrypt-FileWithMyKeys
Encrypt-FileWithMyHSMKeys
Decrypt-File
ConvertTo-JpegXl
ConvertTo-PngFromJpegXl
New-Guid
Get-SummarizeTextWithGPT
Get-TextFromAudioWithWhisper
Get-TTSWithOpenAI
Get-RandomSecure
Set-ReSharperExclusion
Invoke-IpfsUpload
Invoke-RemotePinning
Extract-AudioFromVideo
Get-DateTaken
Move-MediaToDateFolder
Load-Credential
Save-Credential
Start-PowerShellAs
sync-ssh-from-wndows-to-wsl
Set-PowerPointExportResolution
Update-Syncthing
ws
load-pwsh-repo