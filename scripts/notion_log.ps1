param(
  [Parameter(Mandatory=$true)][string]$Title,
  [Parameter(Mandatory=$true)][string]$UserSummary,
  [Parameter(Mandatory=$true)][string]$AssistantSummary,
  [string]$Channel = 'webchat',
  [string]$MessageId = ''
)

$ErrorActionPreference = 'Stop'

$apiKeyPath = Join-Path $env:USERPROFILE '.config\notion\api_key'
$NOTION_KEY = (Get-Content -Raw $apiKeyPath).Trim()

$dbIdPath = Join-Path $PSScriptRoot 'notion_db_id.txt'
$DB_ID = (Get-Content -Raw $dbIdPath).Trim()

$nowIso = (Get-Date).ToString('o')

$payload = @{
  parent = @{ database_id = $DB_ID }
  properties = @{
    'Name' = @{ title = @( @{ text = @{ content = $Title } } ) }
    'Date' = @{ date = @{ start = $nowIso } }
    'UserSummary' = @{ rich_text = @( @{ text = @{ content = $UserSummary } } ) }
    'AssistantSummary' = @{ rich_text = @( @{ text = @{ content = $AssistantSummary } } ) }
    'Channel' = @{ rich_text = @( @{ text = @{ content = $Channel } } ) }
    'MessageId' = @{ rich_text = @( @{ text = @{ content = $MessageId } } ) }
  }
}

$body = $payload | ConvertTo-Json -Depth 10

$headers = @{
  Authorization = "Bearer $NOTION_KEY"
  'Notion-Version' = '2025-09-03'
  'Content-Type' = 'application/json'
}

$resp = Invoke-RestMethod -Method Post -Uri 'https://api.notion.com/v1/pages' -Headers $headers -Body $body

Write-Output $resp.id
