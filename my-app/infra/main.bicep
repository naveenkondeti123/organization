targetScope = 'subscription'
@minLength(1)
@maxLength(64)
param vmName string
param adminUsername string

@secure()
param adminSshPublicKey string

param adminSourceAddressPrefix string
param vmSize string
param virtualNetworkAddressPrefix string
param subnetAddressPrefix string
param vmImagePublisher string
param vmImageOffer string
param vmImageSku string
param vmImageVersion string

@description('OS disk size in GB.')
@minValue(30)
@maxValue(4095)
param osDiskSizeGB int

@description('Managed disk storage account type.')
param osDiskStorageAccountType string
param storageAccountName string
param location string = 'eastus'
param skuName string = 'Standard_LRS'

var resourceGroupName = 'demo-rg'

resource demoResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-03-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

module vm 'modules/vm.bicep' = {
  name: 'vm-deployment'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    vmName: vmName
    adminUsername: adminUsername
    adminSshPublicKey: adminSshPublicKey
    adminSourceAddressPrefix: adminSourceAddressPrefix
    vmSize: vmSize
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
    subnetAddressPrefix: subnetAddressPrefix
    vmImagePublisher: vmImagePublisher
    vmImageOffer: vmImageOffer
    vmImageSku: vmImageSku
    vmImageVersion: vmImageVersion
    osDiskSizeGB: osDiskSizeGB
    osDiskStorageAccountType: osDiskStorageAccountType
  }
  dependsOn: [
    demoResourceGroup
  ]
}

output vmName string = vm.outputs.vmName
output publicIpAddress string = vm.outputs.publicIpAddress
output sshCommand string = 'ssh ${adminUsername}@${vm.outputs.publicIpAddress}'
