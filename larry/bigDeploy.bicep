targetScope = 'subscription'

// ================ //
// Input Parameters //
// ================ //

// RG parameters
@description('Optional. The name of the resource group to deploy')
param resourceGroupName string = 'curly-rg'
@description('Optional. The location to deploy into')
param location string = deployment().location

// AKS parameters
param primaryAgentPoolProfile array = [
  {
    name: 'systempool'
    osDiskSizeGB: 0
    count: 1
    enableAutoScaling: true
    minCount: 1
    maxCount: 3
    vmSize: 'Standard_DS2_v2'
    osType: 'Linux'
    storageProfile: 'ManagedDisks'
    type: 'VirtualMachineScaleSets'
    mode: 'System'
    vnetSubnetID: '/subscriptions/82ac0bb1-dc93-4740-bc06-dad2c80d8c43/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/LarryVnet/subnets/AppTierSubnet'
    serviceCidr: '10.0.0.0/24'
    maxPods: 30
  }
]

param parAdministrator object = {
  azureADOnlyAuthentication: true
  login: 'att-arm-spn'
  sid: 'ab7cff5c-4fca-42e8-9e65-4be5e53125f2'
  principalType: 'Application'
  tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
}

param databases array = [
  {
    name: 'curly-database'
    serverName: 'Curly-SQL'
    skuName: 'GP_Gen5_2'
    maxSizeBytes: 34359738368
  }
]

// Resource Group
module rg '../arm/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: 'curly-rg'
  params: {
    name: resourceGroupName
    location: location
  }
}

module acr '../arm/Microsoft.ContainerRegistry/registries/deploy.bicep' = {
  name: 'curly'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    name: 'curly2acr'
  }
  dependsOn: [
    rg
  ]
}

// AKS deploy
module AKS '../arm/Microsoft.ContainerService/managedClusters/deploy.bicep' = {
  name: 'curly-aks'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'curly-AKS'
    location: location
    primaryAgentPoolProfile: primaryAgentPoolProfile
    systemAssignedIdentity: true
  }
}

//SQL Server Deploy
// narrator, it was not that easy.....
module CreateSQL '../arm/Microsoft.Sql/servers/deploy.bicep' = {
  name: 'curly-SQL'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'curly-SQL'
    location: location
    databases: databases
    administrators: parAdministrator
  }
}
