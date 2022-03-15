targetScope = 'resourceGroup'

// ================ //
// Input Parameters //
// ================ //

@description('Optional. The location to deploy into')
param location string = resourceGroup().location

// param roleAssignments array = []

// NSG parameters
@description('Parameter for Windows VM')
param imageReference object
param osDisk object
param osType string
param adminUsername string
param adminPassword string
param nicConfigurations array

// =========== //
// Deployments //
// =========== //

// VM
module CreateVMs '../arm/Microsoft.Compute/virtualMachines/deploy.bicep' = {
  name: 'MidTierVM'
  params: {
    location: location
    imageReference: imageReference
    osDisk: osDisk
    osType: osType
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicConfigurations: nicConfigurations
  }
}
