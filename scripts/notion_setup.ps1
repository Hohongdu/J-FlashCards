$ErrorActionPreference = 'Stop'

$apiKeyPath = Join-Path $env:USERPROFILE '.config\notion\api_key'
$NOTION_KEY = (Get-Content -Raw $apiKeyPath).Trim()

$parentPage = '310ed37018868090b376c6f1ec7ea3b5'

$payload = @{
  parent = @{ type = 'page_id'; page_id = $parentPage }
  title = @(
    @{ type = 'text'; text = @{ content = 'Cosette Conversation Logs' } }
  )
  properties = @{
    'Name' = @{ title = @{} }
    'Date' = @{ date = @{} }
    'User (핵심)' = @{ rich_text = @{} }
    'Assistant (핵심+이유)' = @{ rich_text = @{} }
    'Channel' = @{ rich_text = @{} }
    'MessageId' = @{ rich_text = @{} }
  }
}

$body = $payload | ConvertTo-Json -Depth 10

$headers = @{
  Authorization = "Bearer $NOTION_KEY"
  'Notion-Version' = '2025-09-03'
  'Content-Type' = 'application/json'
}

$resp = Invoke-RestMethod -Method Post -Uri 'https://api.notion.com/v1/data_sources' -Headers $headers -Body $body

Write-Output $resp.id
