@description('Name of the Azure Container Registry')
@minLength(5)
@maxLength(50)
param name string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Resource tags to apply')
param tags object = {}

@description('Enable admin user for the container registry')
param adminUserEnabled bool = true

@description('The SKU of the container registry')
@allowed(['Basic', 'Standard', 'Premium'])
param skuName string = 'Basic'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
