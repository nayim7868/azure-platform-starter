@description('Azure region for all resources')
param location string = 'northeurope'

@description('Globally unique name for the Web App (must be unique), e.g. app-azure-platform-starter-nh-482')
param appName string

@description('App version exposed by the /version endpoint')
param appVersion string = '0.1.0'

var appServicePlanName = 'asp-azure-platform-starter-uks'
var appInsightsName = 'appi-azure-platform-starter-uks'

resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
sku: {
  name: 'B1'
  tier: 'Basic'
  capacity: 1
}
  properties: {
    reserved: true // Linux
  }
}

resource appi 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource web 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      appCommandLine: 'gunicorn -k uvicorn.workers.UvicornWorker -w 2 -b 0.0.0.0:8000 app.main:app'
    }
  }
}

resource webAppSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: web
  properties: {
    APP_VERSION: appVersion
    SCM_DO_BUILD_DURING_DEPLOYMENT: 'true'
    WEBSITES_PORT: '8000'
    APPLICATIONINSIGHTS_CONNECTION_STRING: reference(appi.id, '2020-02-02').ConnectionString
  }
}

output appHostName string = web.properties.defaultHostName
output appUrl string = 'https://${web.properties.defaultHostName}'

