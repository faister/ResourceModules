targetScope = 'subscription'

// ================ //
// Input Parameters //
// ================ //

// RG parameters
@description('Optional. The name of the resource group to deploy')
param resourceGroupName string = 'network-rg'

@description('Optional. The location to deploy into')
param location string = deployment().location

// NSG parameters
@description('Optional. The name of the vnet to deploy')
param networkSecurityGroupName string = 'LarryNsg'

// VNET parameters
@description('Optional. The name of the vnet to deploy')
param vnetName string = 'LarryVnet'

@description('Optional. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vNetAddressPrefixes array = [
  '10.0.0.0/16'
]

@description('Optional. An Array of subnets to deploy to the Virual Network.')
param subnets array = [
  {
    name: 'AppTierSubnet'
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroupName: networkSecurityGroupName
  }
  {
    name: 'MidTierSubnet'
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroupName: networkSecurityGroupName
  }
  {
    name: 'DataTierSubnet'
    addressPrefix: '10.0.2.0/24'
    networkSecurityGroupName: networkSecurityGroupName
  }
]

// =========== //
// Deployments //
// =========== //

// Resource Group
module rg '../arm/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: 'network-rg'
  params: {
    name: resourceGroupName
    location: location
  }
}

// Network Security Group
module nsg '../arm/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'larry-nsg'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: networkSecurityGroupName
  }
  dependsOn: [
    rg
  ]
}

// Virtual Network
module vnet '../arm/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  name: 'larry-vnet'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: vnetName
    addressPrefixes: vNetAddressPrefixes
    subnets: subnets
  }
  dependsOn: [
    nsg
    rg
  ]
}
