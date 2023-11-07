<#
.DESCRIPTION
Summarize text using the OpenAI API
#>

param(
    [Parameter(Mandatory = $true)]
    [string]
    $Text,
    [string]
    $Language = "english",
    [string]
    [ValidateSet("gpt-4-1106-preview", "gpt-4", "gpt-3.5-turbo-1106")]
    $Model = "gpt-4-1106-preview"
)

# Get the token from environment variable
$token = $env:OPENAITOKEN
if ($null -eq $token -or $token -eq "") {
    Write-Error "Environment variable OPENAITOKEN is not set."
    exit 1
}

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
    ],
    "temperature": 1,
    "max_tokens": 4095,
    "top_p": 1,
    "frequency_penalty": 0,
    "presence_penalty": 0
  }
"@

$customObject = ConvertFrom-Json $bodyTemplate
$customObject.messages[0].content = "Summarize text in the language $Language. The text is: $($Text -join """",[System.Environment]::NewLine)"
$body = $customObject | ConvertTo-Json

$r = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
$r | Out-String | Write-Host -ForegroundColor DarkGray
$r.choices[0].message | Format-List