param location string
param resourceToken string
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'app-${resourceToken}'
  location: location
  sku: {
    name: 'P1V3'  
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource web 'Microsoft.Web/sites@2022-03-01' = {
  name: 'web-${resourceToken}'
  location: location
  tags: union(tags, { 'azd-service-name': 'web' })
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      ftpsState: 'Disabled'
      appCommandLine: 'python3 -m uvicorn app:app --host 0.0.0.0 --port 8000 --workers 2 --timeout-keep-alive 120'
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource appSettings 'config' = {
    name: 'appsettings'
    properties: {
      SCM_DO_BUILD_DURING_DEPLOYMENT: 'true'
      SIDECAR_PORT: '11434'
      ENDPOINT: 'http://localhost:11434/v1'
      MODEL: 'bitnet-b1.58-2b-4t-gguf'
    }
  }

  resource logs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: {
        fileSystem: {
          level: 'Verbose'
        }
      }
      detailedErrorMessages: {
        enabled: true
      }
      failedRequestsTracing: {
        enabled: true
      }
      httpLogs: {
        fileSystem: {
          enabled: true
          retentionInDays: 1
          retentionInMb: 35
        }
      }
    }
  }
}

resource bitnetSidecar 'Microsoft.Web/sites/sitecontainers@2024-04-01' = {
  parent: web
  name: 'bitnet-sidecar'
  properties: {
    image: 'mcr.microsoft.com/appsvc/docs/sidecars/sample-experiment:bitnet-b1.58-2b-4t-gguf'
    isMain: false
    authType: 'Anonymous'
    targetPort: '11434'
  }
}

output WEB_URI string = 'https://${web.properties.defaultHostName}'
