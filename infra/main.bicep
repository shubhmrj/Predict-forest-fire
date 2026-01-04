param location string = resourceGroup().location
param environmentName string
param principalId string = ''

// Generate a unique suffix for resources
var resourceToken = uniqueString(resourceGroup().id, environmentName, location)
var tags = {
  'azd-env-name': environmentName
  'azd-resource-token': resourceToken
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'asp-${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: 'B1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// App Service
resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: 'app-${resourceToken}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.9'
      appSettings: [
        {
          name: 'FLASK_ENV'
          value: 'production'
        }
        {
          name: 'FLASK_APP'
          value: 'application.py'
        }
        {
          name: 'WEBSITES_PORT'
          value: '8000'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
      alwaysOn: true
      http20Enabled: true
    }
    httpsOnly: true
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${resourceToken}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'log-${resourceToken}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Outputs
output AZURE_APP_SERVICE_URL string = 'https://${appService.properties.defaultHostName}'
output AZURE_APP_SERVICE_NAME string = appService.name
output AZURE_APP_SERVICE_RESOURCE_ID string = appService.id
