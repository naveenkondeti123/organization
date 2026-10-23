using './main.bicep'

param location = 'eastus'
param vmName = 'linux-demovm'
param adminUsername = 'azureuser'
// Set ADMIN_SSH_PUBLIC_KEY in the deployment shell before compiling or deploying.
param adminSshPublicKey = readEnvironmentVariable('ADMIN_SSH_PUBLIC_KEY')
// Replace this documentation-only address with your public IP in CIDR notation.
param adminSourceAddressPrefix = '203.0.113.10/32'
param vmSize = 'Standard_B2s'
param virtualNetworkAddressPrefix = '10.0.0.0/16'
param subnetAddressPrefix = '10.0.1.0/24'
param vmImagePublisher = 'Canonical'
param vmImageOffer = '0001-com-ubuntu-server-jammy'
param vmImageSku = '22_04-lts-gen2'
param vmImageVersion = 'latest'
param osDiskSizeGB = 30
param osDiskStorageAccountType = 'StandardSSD_LRS'
