# pwsh-repo

This is my personal Powershell repo where a few scripts I often use.

## Some Features

- Encryption with age-encryption.org and with HSM support
- Cloud Uploads with rclone to make files easy accesaable from everywhere
- Create a Powershell with elevalted rights without a password prompt
- Read `Date-Taken` from media files
- Transcribe audio and video files to text with OpenAI API

## Installation

1. Run `profile\init.ps1` this can be run repeatedly.
   1. This will add `shell.ps1` in each Powershell `$PROFILE` to run `Join-Path $env:USERPROFILE "Local\SharedScripting\sharedprofile.ps1"` so there is only one place to edit the profile.
2. `sharedprofile.ps1` starts with every new Powershell session, `*.ps1` files next will be loaded executed in alphabetical order.
   1. So you could have something link `00-vars.ps1` to set variables that are used in other scripts first.

## Powershell Functions

- Publish-FileUnprotected
- Publish-FilePasswortProtected
- Publish-File
- Test-Rclone
- Encrypt-File
- Encrypt-FileWithMyKeys
- Encrypt-FileWithMyHSMKeys
- Decrypt-File
- New-Guid
- audio-to-text
- Get-RandomSecure
- Set-ReSharperExclusion
- Get-DateTaken
- Load-Credential
- Save-Credential
- Start-PowerShellAs
- sync-ssh-from-wndows-to-wsl
- Set-PowerPointExportResolution
- ws
- load-pwsh-repo