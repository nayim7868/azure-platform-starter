param(
  [string]$rg = "rg-azure-platform-starter-neu",
  [string]$appInsights = "appi-azure-platform-starter-uks"
)

az monitor app-insights query `
  -g $rg `
  --app $appInsights `
  --analytics-query "requests | where timestamp > ago(1h) | order by timestamp desc | take 20"
