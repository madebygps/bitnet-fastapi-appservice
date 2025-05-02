targetScope = 'resourceGroup'

@description('The Azure region for resource deployment')
param location string

@description('Resource tags that should be applied to all resources')
param tags object

@description('Name of the container registry')
param containerRegistryName string

@description('Name of the app service')
param appServiceName string

@description('Name of the app service plan')
param appServicePlanName string

@description('Name of the application insights instance')
param applicationInsightsName string

@description('Name of the log analytics workspace')
param logAnalyticsName string

module containerRegistry 'core/host/container-registry.bicep' = {
  name: 'acr'
  params: {
    name: containerRegistryName
    location: location
    tags: tags
  }
}

module appServicePlan 'core/host/appservice-plan.bicep' = {
  name: 'appservice-plan'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: {
      name: 'F1'
    }
  }
}
module logAnalytics 'core/monitor/log-analytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

module applicationInsights 'core/monitor/application-insights.bicep' = {
  name: 'applicationInsights'
  params: {
    name: applicationInsightsName
    workspaceResourceId: logAnalytics.outputs.id
    location: location
    tags: tags
  }
}

module api 'core/host/appservice.bicep' = {
  name: 'api'
  params: {
    name: appServiceName
    location: location
    tags: union(tags, {
      'azd-service-name': 'api'
    })
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryName: containerRegistry.outputs.name
    containerRegistryImageName: 'fastapi'
    containerRegistryImageTag: 'latest'
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString 
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey 
  }
}

output acrName string = containerRegistry.outputs.name
output acrLoginServer string = containerRegistry.outputs.loginServer
output apiUri string = api.outputs.uri
