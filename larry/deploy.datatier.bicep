targetScope = 'subscription'

// ================ //
// Input Parameters //
// ================ //

// RG parameters
@description('Optional. The name of the resource group to deploy')
param parDataTierRgName string = 'datatier-rg'

@description('Optional. The location to deploy into')
param location string = deployment().location

param parSqlName string = ''
param parSubnetResourceId string = ''

param parSqlAdministratorLogin string = ''
param parSqlAdministratorLoginPassword string = ''

param parKeys array = []

// =========== //
// Deployments //
// =========== //

// Resource Group
module datatierRg '../arm/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: 'deploy-datatier-rg'
  params: {
    name: parDataTierRgName
    location: location
  }
}

module azuresql '../arm/Microsoft.Sql/managedInstances/deploy.bicep' = {
  name: 'deploy-azure-sql'
  scope: resourceGroup(parDataTierRgName)
  params: {
    name: parSqlName
    location: location
    subnetId: parSubnetResourceId
    administratorLogin: parSqlAdministratorLogin
    administratorLoginPassword: parSqlAdministratorLoginPassword
    keys: parKeys
  }
}
