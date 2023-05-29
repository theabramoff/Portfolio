// =========== main.bicep ===========

// Setting target scope

targetScope = 'subscription'

param location string = 'westeurope'
param resourceGroupName string = 'rg-az01-01-abramov-bicep'
param resourceGroupLocation string = location
param storageName string = 'saaz01bicep'
param storageLocation string = location

// Creating resource group
resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
name: resourceGroupName
location: resourceGroupLocation
tags: {
  OwnedBy: 'Abramov, Andrey'
  OwnerBackupPerson: 'N/A'
  Description: 'Bicep Test 1'
}
}

module stg 'storage.bicep' = {
name: 'StorageDeployment'
scope: resourcegroup    // Deployed in the scope of resource group we created above
  params: {
    storageName: storageName
    storageLocation: storageLocation
  }
}

output resourceGroupName string = resourcegroup.name


// New-AzResourceGroupDeployment -ResourceGroupName rg-az01-01-abramov-bicep -TemplateFile storage.bicep
// New-AzDeployment -location 'westeurope' -TemplateFile main.bicep  


//bicep build "storage.bicep"
