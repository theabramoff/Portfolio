
// =========== storage.bicep ===========

// targetScope = 'resourceGroup' - not needed since it is the default value

param storageName string = 'saaz01bicep'
param storageLocation string = resourceGroup().location

resource storageAcct 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageName
  location: storageLocation
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
}

output storageName string = storageAcct.name
