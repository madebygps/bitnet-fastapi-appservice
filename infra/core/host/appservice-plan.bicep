@description('Name of the App Service Plan')
@minLength(1)
@maxLength(40)
param name string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Resource tags to apply')
param tags object = {}

@description('The SKU of the App Service Plan')
param sku object = {
  name: 'B1'
}

@description('The kind of App Service Plan to deploy')
@allowed(['linux', 'windows'])
param kind string = 'linux'

@description('Whether to reserve the App Service Plan for Linux workloads')
param reserved bool = true

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
