<#
.SYNOPSIS
    Play a text-to-speech message by using the OpenAI API
#>

param(
    [string]
    $Text = "Benutze den Parameter Text um einen Text anzugeben.",
    [string]
    [ValidateSet("alloy", "echo", "fable", "onyx", "nova", "shimmer")]
    $Voice = "alloy",
    [string]
    [ValidateSet("tts-1", "tts-1-hd")]
    $Model = "tts-1",
    [switch]
    $Play
)

# Get the token from environment variable
$token = $env:OPENAITOKEN
if($null -eq $token -or $token -eq "") {
    Write-Error "Environment variable OPENAITOKEN is not set."
    exit 1
}

$url = "https://api.openai.com/v1/audio/speech"
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
$bodyTemplate = @"
{
    "model": "tts-1",
    "input": "Es wurde kein Text angegeben.",
    "voice": "alloy"
}
"@
$customObject = ConvertFrom-Json $bodyTemplate
$customObject.input = ($Text -creplace '\P{IsBasicLatin}')
$customObject.voice = $Voice
$body = $customObject | ConvertTo-Json
$file =  ("{0}_speech.mp3" -f (Get-Date -Format "yyyy-MM-dd-HH_mm_ss"))
Invoke-WebRequest -Uri $url -Method Post -Headers $headers -Body $body -OutFile ("{0}_speech.mp3" -f (Get-Date -Format "yyyy-MM-dd-HH_mm_ss"))

Get-ChildItem $file

# Play mp3
if ($Play) {
    Invoke-Item $file
}
