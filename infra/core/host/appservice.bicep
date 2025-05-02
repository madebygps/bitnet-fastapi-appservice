@description('Name of the App Service')
@minLength(2)
@maxLength(60)
param name string

@description('Azure region for resource deployment')
param location string

@description('Resource tags to apply')
param tags object = {}

@description('ID of the App Service Plan to host the app')
param appServicePlanId string

@description('Name of the Azure Container Registry')
param containerRegistryName string

@description('Name of the container image')
param containerRegistryImageName string

@description('Tag of the container image')
param containerRegistryImageTag string

@description('The Application Insights connection string')
param applicationInsightsConnectionString string

@description('The Application Insights instrumentation key')
param applicationInsightsInstrumentationKey string


// Get reference to ACR
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: union(tags, {
    'azd-service-name': 'api'
  })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      acrUseManagedIdentityCreds: true
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/${containerRegistryImageName}:${containerRegistryImageTag}'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'APPLICATIONINSIGHTS_INSTRUMENTATION_KEY'
          value: applicationInsightsInstrumentationKey
        }
      ]
    }
  }
}

// Now use the registry-access module for RBAC
module registryAccess '../security/registry-access.bicep' = {
  name: 'registry-access'
  params: {
    containerRegistryName: containerRegistryName
    principalId: appService.identity.principalId
  }
}

output name string = appService.name
output principalId string = appService.identity.principalId
output uri string = 'https://${appService.properties.defaultHostName}'
