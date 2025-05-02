@description('The name of the Log Analytics workspace')
param name string

@description('The location where the resource will be created')
param location string

@description('Tags to apply to the resource')
param tags object = {}

@description('The number of days to retain logs')
param retentionInDays int = 30

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output id string = logAnalytics.id
output name string = logAnalytics.name
