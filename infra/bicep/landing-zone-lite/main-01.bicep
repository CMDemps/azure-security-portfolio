@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the core virtual network')
param vnetName string = 'vnet-sec-lz-core'

@description('Virtual network address space')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Management subnet name')
param mgmtSubnetName string = 'snet-sec-lz-mgmt'

@description('Management subnet address prefix')
param mgmtSubnetPrefix string = '10.10.2.0/24'

@description('Application subnet name')
param appSubnetName string = 'snet-sec-lz-app'

@description('Application subnet address prefix')
param appSubnetPrefix string = '10.10.1.0/24'

@description('Logging subnet name')
param loggingSubnetName string = 'snet-sec-lz-logging'

@description('Logging subnet address prefix')
param loggingSubnetPrefix string = '10.10.3.0/24'

@description('Azure Bastion subnet name')
param bastionSubnetName string = 'AzureBastionSubnet'

@description('Azure Bastion subnet address prefix')
param bastionSubnetPrefix string = '10.10.4.0/26'

@description('Management subnet NSG name')
param mgmtNsgName string = 'nsg-sec-lz-mgmt'

@description('Application subnet NSG name')
param appNsgName string = 'nsg-sec-lz-app'

@description('Logging subnet NSG name')
param loggingNsgName string = 'nsg-sec-lz-logging'

@description('NAT Gateway name')
param natGatewayName string = 'nat-sec-lz-core'

@description('Home IP address for RDP/SSH access')
param homeIpAddress string = 'YOUR_HOME_IP_ADDRESS/32'

@description('Office IP address for RDP/SSH access')
param officeIpAddress string = 'YOUR_OFFICE_IP_ADDRESS/32'

@description('Tags to apply to all resources')
param tags object = {
  Environment: 'Lab'
  ManagedBy: 'Bicep'
}

// Reference existing NAT Gateway
resource natGateway 'Microsoft.Network/natGateways@2023-09-01' existing = {
  name: natGatewayName
}

// NSGs with existing security rules
resource mgmtNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: mgmtNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'allow-rdp-office'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: officeIpAddress
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'allow-ssh-office'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: officeIpAddress
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'allow-rdp-home'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: homeIpAddress
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'allow-ssh-home'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: homeIpAddress
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-Internet-Out'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 4000
          direction: 'Outbound'
        }
      }
    ]
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

// Virtual Network with inline subnets (prevents deletion attempts)
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
    subnets: [
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetPrefix
          networkSecurityGroup: {
            id: appNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: loggingSubnetName
        properties: {
          addressPrefix: loggingSubnetPrefix
          networkSecurityGroup: {
            id: loggingNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: mgmtSubnetName
        properties: {
          addressPrefix: mgmtSubnetPrefix
          networkSecurityGroup: {
            id: mgmtNsg.id
          }
          natGateway: {
            id: natGateway.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// Outputs
output vnetName string = vnet.name
output vnetId string = vnet.id
output bastionSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, bastionSubnetName)
output mgmtSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, mgmtSubnetName)
output appSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, appSubnetName)
output loggingSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, loggingSubnetName)
output mgmtNsgId string = mgmtNsg.id
output appNsgId string = appNsg.id
output loggingNsgId string = loggingNsg.id
