targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var prefix = '${name}-${resourceToken}'
var tags = { 'azd-env-name': name }

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${name}-rg'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  scope: rg
  name: 'resources'
  params: {
    location: location
    tags: tags
    containerRegistryName: '${replace(prefix, '-', '')}registry'
    appServiceName: replace('${take(prefix,19)}-app', '--', '-')
    appServicePlanName: replace('${take(prefix,19)}-plan', '--', '-')
    applicationInsightsName: replace('${take(prefix,19)}-ai', '--', '-')
    logAnalyticsName: replace('${take(prefix,19)}-la', '--', '-')

  }
}

output AZURE_CONTAINER_REGISTRY_NAME string = resources.outputs.acrName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.acrLoginServer
output API_URI string = resources.outputs.apiUri
