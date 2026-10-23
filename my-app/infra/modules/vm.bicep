@description('Azure region for the virtual machine and networking resources.')
param location string

@description('Virtual machine name.')
@minLength(1)
@maxLength(64)
param vmName string

@description('Administrator account name for the Linux virtual machine.')
param adminUsername string

@description('SSH public key for administrator access.')
@secure()
param adminSshPublicKey string

@description('CIDR range allowed to connect to SSH (port 22).')
param adminSourceAddressPrefix string

@description('Azure VM size.')
param vmSize string

@description('Virtual network address space.')
param virtualNetworkAddressPrefix string

@description('Subnet address space.')
param subnetAddressPrefix string

@description('OS image publisher.')
param vmImagePublisher string

@description('OS image offer.')
param vmImageOffer string

@description('OS image SKU.')
param vmImageSku string

@description('OS image version.')
param vmImageVersion string

@description('OS disk size in GB.')
@minValue(30)
@maxValue(4095)
param osDiskSizeGB int

@description('Managed disk storage account type.')
param osDiskStorageAccountType string

var networkSecurityGroupName = '${vmName}-nsg'
var virtualNetworkName = '${vmName}-vnet'
var subnetName = '${vmName}-subnet'
var networkInterfaceName = '${vmName}-nic'
var publicIpName = '${vmName}-pip'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSshFromAdminSource'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: adminSourceAddressPrefix
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: vmImagePublisher
        offer: vmImageOffer
        sku: vmImageSku
        version: vmImageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskStorageAccountType
        }
        diskSizeGB: osDiskSizeGB
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshPublicKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

output vmName string = virtualMachine.name
output publicIpAddress string = publicIp.properties.ipAddress
