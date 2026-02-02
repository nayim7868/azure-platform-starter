Azure Platform Starter (FastAPI + Bicep + CI/CD + Application Insights)
This repo is a small backend API deployed to Microsoft Azure using Infrastructure-as-Code (Bicep), CI/CD (GitHub Actions), and monitoring (Application Insights).
It’s built as a platform/DevOps portfolio project to demonstrate how to provision, deploy, and operate a cloud service.

What I built
I created a simple FastAPI service and then built the “platform” around it:

Azure App Service hosts the API publicly
Bicep (IaC) provisions Azure resources repeatably
GitHub Actions runs tests and deploys automatically on push to main
Application Insights collects request/failure telemetry for monitoring and troubleshooting
Live endpoints
Base URL:
https://app-azure-platform-starter-am-482.azurewebsites.net

GET /health
Returns {"status":"ok"} (liveness check / monitoring validation)

GET /crash
Intentionally triggers a server error (HTTP 500) to demonstrate incident investigation in telemetry
⚠️ Demo endpoint only.

Architecture
Resource Group: rg-azure-platform-starter-neu (North Europe)

Resources:

App Service Plan: asp-azure-platform-starter-uks (compute)
Web App: app-azure-platform-starter-am-482 (hosts the API)
Application Insights: appi-azure-platform-starter-uks (monitoring)
Telemetry flow:

Client calls the Web App (/health, /crash)
FastAPI handles the request
OpenTelemetry instrumentation records request telemetry
Telemetry is exported to Application Insights via APPLICATIONINSIGHTS_CONNECTION_STRING
Repo structure
app/ — FastAPI application
tests/ — pytest tests
infra/ — Bicep template + parameters
.github/workflows/ — GitHub Actions CI/CD pipeline
Run locally (Windows PowerShell)
1) Create venv + install deps
python -m venv .venv
. .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
2) Start the API
uvicorn app.main:app --host 0.0.0.0 --port 8000
3) Test it
Open:
http://localhost:8000/health

4) Run tests
pytest -q
Deploy infrastructure (Bicep)
Prereqs
Azure CLI installed

Logged in:

az login
Create resource group (if needed)
az group create -n rg-azure-platform-starter-neu -l northeurope
Deploy IaC
az deployment group create `
  -g rg-azure-platform-starter-neu `
  -f infra/main.bicep `
  -p "@infra/params.dev.json"
CI/CD (GitHub Actions)
On push to main, the pipeline:

Installs dependencies

Runs tests (pytest)

Packages the app

Deploys to Azure Web App

Auth uses an Azure publish profile stored as a GitHub repository secret.

Monitoring verification (Application Insights)
Generate traffic
for ($i=0; $i -lt 20; $i++) { Invoke-WebRequest -Uri "https://app-azure-platform-starter-am-482.azurewebsites.net/health" -UseBasicParsing | Out-Null }
Query latest requests (CLI)
az monitor app-insights query `
  -g rg-azure-platform-starter-neu `
  --app appi-azure-platform-starter-uks `
  --analytics-query "requests | where timestamp > ago(1h) | order by timestamp desc | take 20"
Trigger a failure and confirm it appears
Open:
https://app-azure-platform-starter-am-482.azurewebsites.net/crash

Then run:

az monitor app-insights query `
  -g rg-azure-platform-starter-neu `
  --app appi-azure-platform-starter-uks `
  --analytics-query "requests | where timestamp > ago(1h) and success == 'False'