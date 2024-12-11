<#
.DESCRIPTION
Summarize text using the OpenAI API
#>

param(
  [string[]]
  $Text,
  [string[]]
  $Prompt,
  [System.IO.FileInfo]
  [ValidateScript({ Test-Path $_ })]
  $File,
  [string]
  $Language = "english",
  [string]
  [ValidateSet("gpt-4-turbo-preview", "gpt-4", "gpt-3.5-turbo-1106", "gpt-4o-mini")]
  $Model = "gpt-4-turbo-preview",
  [switch]
  $ShowInBrowser
)
# Get the token from environment variable
$token = $env:OPENAITOKEN
if ($null -eq $token -or $token -eq "") {
  Write-Error "Environment variable OPENAITOKEN is not set."
  exit 1
}

# Text or File must be present
if ($null -eq $Text -and $null -eq $File) {
  Write-Error "Either Text or File must be present."
  exit 1
}
# Test and File are not allowed at the same time
if ($null -ne $Text -and $null -ne $File) {
  Write-Error "Either Text or File must be present."
  exit 1
}

$content = ""
if ($null -ne $Text) {
  $content = $Text -join """", [System.Environment]::NewLine
}
else {
  $content = (Get-Content -Path $File -Encoding utf8) -join """", [System.Environment]::NewLine
}
$content = $content -creplace '\P{IsBasicLatin}'

$url = "https://api.openai.com/v1/chat/completions"
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
$bodyTemplate = @"
{
    "model": "$Model",
    "messages": [
      {
        "role": "user",
        "content": ""
      }
    ]
  }
"@

$customObject = ConvertFrom-Json $bodyTemplate
# $customObject.messages[0].content = "Summarise  and explain this text in the language $Language in a structured  manner." + [System.Environment]::NewLine

$customObject.messages[0].content = $Prompt + [System.Environment]::NewLine + [System.Environment]::NewLine
if ($null -ne $File) {
  $customObject.messages[0].content += "The file name is: $($File.Name)" + [System.Environment]::NewLine
}
$customObject.messages[0].content += "$content"
$body = $customObject | ConvertTo-Json 

$r = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
$r | Out-String | Write-Host -ForegroundColor DarkGray
$r.choices[0].message.content
if ($ShowInBrowser) {
  $r.choices[0].message.content | Show-Markdown -UseBrowser
}