<#
.SYNOPSIS
    This script summarizes text using the OpenAI API.

.DESCRIPTION
    The Get-SummarizeTextWithGPT.ps1 script uses the OpenAI API to summarize text. The text can be provided as a string array or as a file. The language of the text and the model to use for summarization can be specified. The maximum number of characters to read from the text can also be specified. The summarized text can be displayed in the console or in a web browser.

.PARAMETER Text
    The text to summarize. This parameter can accept multiple strings.

.PARAMETER File
    The file containing the text to summarize. The file must exist.

.PARAMETER Language
    The language of the text. The default language is English.

.PARAMETER Model
    The model to use for summarization. The default model is "gpt-4-0125-preview". Other options are "gpt-4" and "gpt-3.5-turbo".

.PARAMETER MaxChars
    The maximum number of characters to read from the text. The default is 10240 characters.

.PARAMETER ShowInBrowser
    If this switch is present, the summarized text will be displayed in a web browser.

.EXAMPLE
    Get-SummarizeTextWithGPT -Text "This is a long text that needs to be summarized." -Model "gpt-4"

    This will summarize the text "This is a long text that needs to be summarized." using the "gpt-4" model.

#>

param(
  [string[]]
  $Text,
  [System.IO.FileInfo]
  [ValidateScript({ Test-Path $_ })]
  $File,
  [string]
  $Language = "english",
  [string]
  [ValidateSet("gpt-4-0125-preview", "gpt-4", "gpt-3.5-turbo")]
  $Model = "gpt-4-0125-preview",
  [int]
  $MaxChars = 1024*10,
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
  $content = (Get-Content -Path $File -Encoding utf8 -TotalCount $MaxChars) -join """", [System.Environment]::NewLine
}
$content = $content -creplace '\P{IsBasicLatin}'


# reduce content to max $MaxChars
$contentIsReduced = $false
if ($content.Length -gt $MaxChars) {
  $contentIsReduced = $true
  $contentLength = $content.Length
  $content = $content.Substring(0, $MaxChars)
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
# $customObject.messages[0].content = "Summarise  and explain this text in the language $Language in a structured  manner." + [System.Environment]::NewLine
$prompt = @"
Given the following text, please perform the following tasks:

1. Generate a structured summary of the text, organized into clear sections for easy understanding.
2. Provide a concise summary and explanation in continuous text at the end.

If the text is related to software development or IT topics, also:

3. Evaluate the use of design patterns in the context provided.
4. Identify any potential security issues.
5. Rate the quality of any source code mentioned in the text on a scale from 1 (poor) to 5 (excellent).

The summary and feedback should be provided in $Language.

"@

if($contentIsReduced) {
  $prompt +=  "The text was reduced from $contentLength to $MaxChars characters." + [System.Environment]::NewLine
}

$customObject.messages[0].content = $prompt + [System.Environment]::NewLine
if ($null -ne $File) {
  $customObject.messages[0].content += "The file name is: $($File.Name)" + [System.Environment]::NewLine
}
$customObject.messages[0].content += "The text is: $content"
$body = $customObject | ConvertTo-Json

$r = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
$r | Out-String | Write-Host -ForegroundColor DarkGray
$r.choices[0].message.content
if ($ShowInBrowser) {
  $r.choices[0].message.content | Show-Markdown -UseBrowser
}