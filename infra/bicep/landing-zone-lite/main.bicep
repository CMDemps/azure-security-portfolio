@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the core virtual network')
param vnetName string = 'vnet-sec-lz-core'

@description('Virtual network address space')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Management subnet name')
param mgmtSubnetName string = 'snet-sec-lz-mgmt'

@description('Management subnet address prefix')
param mgmtSubnetPrefix string = '10.10.1.0/24'

@description('Application subnet name')
param appSubnetName string = 'snet-sec-lz-app'

@description('Application subnet address prefix')
param appSubnetPrefix string = '10.10.2.0/24'

@description('Logging subnet name')
param loggingSubnetName string = 'snet-sec-lz-logging'

@description('Logging subnet address prefix')
param loggingSubnetPrefix string = '10.10.3.0/24'

@description('Management subnet NSG name')
param mgmtNsgName string = 'nsg-sec-lz-mgmt'

@description('Application subnet NSG name')
param appNsgName string = 'nsg-sec-lz-app'

@description('Logging subnet NSG name')
param loggingNsgName string = 'nsg-sec-lz-logging'

@description('Tags to apply to all resources')
param tags object = {
  Environment: 'Lab'
  ManagedBy: 'Bicep'
}

// NSGs (defined first to ensure dependencies are clear)
resource mgmtNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: mgmtNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: appNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource loggingNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: loggingNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

// Subnets as child resources
resource mgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: mgmtSubnetName
  properties: {
    addressPrefix: mgmtSubnetPrefix
    networkSecurityGroup: {
      id: mgmtNsg.id
    }
  }
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: appSubnetName
  properties: {
    addressPrefix: appSubnetPrefix
    networkSecurityGroup: {
      id: appNsg.id
    }
  }
}

resource loggingSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: loggingSubnetName
  properties: {
    addressPrefix: loggingSubnetPrefix
    networkSecurityGroup: {
      id: loggingNsg.id
    }
  }
}

// Outputs (using resourceId function for reliability)
output vnetName string = vnet.name
output vnetId string = vnet.id
output mgmtSubnetId string = mgmtSubnet.id
output appSubnetId string = appSubnet.id
output loggingSubnetId string = loggingSubnet.id
