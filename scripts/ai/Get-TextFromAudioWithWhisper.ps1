<#
.SYNOPSIS
    This script transcribes audio to text using the OpenAI API.

.DESCRIPTION
    The script takes an audio file as input and sends it to the OpenAI API for transcription. 
    It requires an OpenAI token, which should be set as an environment variable (OPENAITOKEN). 
    The script also accepts optional parameters for a prompt and language. 
    It checks if the file exists and if its size is less than 25 MB before sending it to the API.

.PARAMETER File
    The audio file to be transcribed. This parameter is mandatory.

.PARAMETER prompt
    An optional prompt that can be used to guide the transcription.

.PARAMETER language
    An optional parameter to specify the language of the audio file.

.EXAMPLE
    .\audio-to-text.ps1 -File "path\to\audiofile.wav" -prompt "This is a lecture about math" -language "en"

.NOTES
    Make sure to set your OpenAI token as an environment variable (OPENAITOKEN) before running the script.
#>
param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [System.IO.FileInfo]$File,
    [string]$prompt,
    [string]$language
    )

# Get the token from environment variable
$token = $env:OPENAITOKEN
if($null -eq $token -or $token -eq "") {
    Write-Error "Environment variable OPENAITOKEN is not set."
    exit 1
}

# Check if file exists
if (!($File.Exists)) {
    Write-Error "File $File does not exist."
    exit 1
}

# Check if file size is larger than 25 MB
$fileSizeMB = $File.Length / 1MB
if ($fileSizeMB -gt 25) {
    Write-Error "File $File is larger than 25 MB."
    exit 1
}
# API:  https://platform.openai.com/docs/api-reference/audio/create#audio/create-prompt
$url = "https://api.openai.com/v1/audio/transcriptions"
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "multipart/form-data" }
$body = @{ file = $File; model = "whisper-1" }
if ($null -ne $prompt) {
    $body.Add("prompt", $prompt)
}
if ($null -ne $language) {
    $body.Add("language", $language)
}
$r = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Form $body
$r | Format-List