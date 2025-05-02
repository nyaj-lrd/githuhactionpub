@description('Names of the storage accounts to create')
var storageAccountNames = [
  'mystorageacct1lrdup3'
  'mystorageacct2lrdup3'
]

@description('Location for the storage accounts')
param location string = resourceGroup().location

resource storageAccounts 'Microsoft.Storage/storageAccounts@2022-09-01' = [for name in storageAccountNames: {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}]
