param([Parameter(Mandatory=$true)][string]$DataSourceId)
$ErrorActionPreference='Stop'
$k=(Get-Content -Raw (Join-Path $env:USERPROFILE '.config\notion\api_key')).Trim()

$payload = @{
  properties = @{
    'Date' = @{ date = @{} }
    'UserSummary' = @{ rich_text = @{} }
    'AssistantSummary' = @{ rich_text = @{} }
    'Channel' = @{ rich_text = @{} }
    'MessageId' = @{ rich_text = @{} }
  }
}

$headers = @{
  Authorization = "Bearer $k"
  'Notion-Version' = '2025-09-03'
  'Content-Type' = 'application/json'
}

$body = $payload | ConvertTo-Json -Depth 10
$resp = Invoke-RestMethod -Method Patch -Uri ("https://api.notion.com/v1/data_sources/$DataSourceId") -Headers $headers -Body $body
Write-Host 'patched'
$resp.properties.Keys | ForEach-Object { Write-Host $_ }
