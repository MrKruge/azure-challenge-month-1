@description('Location for all resources')
param location string = resourceGroup().location

@description('Admin username for the VM')
param adminUsername string = 'azureuser'

@description('Admin password for the VM')
@secure()
param adminPassword string

@description('Unique suffix for storage account')
param storageSuffix string = uniqueString(resourceGroup().id)

var vnetName = 'cloudclub-vnet'
var subnetName = 'private-subnet'
var vmName = 'cloudclub-vm'
var storageAccountName = 'ccst${storageSuffix}'
var nicName = 'cloudclub-vm-nic'
var nsgName = 'cloudclub-nsg'
var storageNsgName = 'cloudclub-storage-nsg'

/* =====================
   VNET + SUBNET
===================== */

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

/* =====================
   NETWORK SECURITY GROUP
===================== */

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource storageNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: storageNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowVNetInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

/* =====================
   STORAGE ACCOUNT
===================== */

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

/* =====================
   TABLE STORAGE
===================== */

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: storage
  name: 'default'
}

resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  name: '${storage.name}/default/appdata'
}

/* =====================
   PRIVATE ENDPOINTS
===================== */

resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pe-blob'
  location: location
  properties: {
    subnet: {
      id: vnet.properties.subnets[0].id
    }
    privateLinkServiceConnections: [
      {
        name: 'blobConnection'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'pe-blob-nic'
  }
}

resource blobPrivateEndpointNic 'Microsoft.Network/networkInterfaces@2023-05-01' existing = {
  name: 'pe-blob-nic'
  dependsOn: [blobPrivateEndpoint]
}

resource blobNsgAssociation 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'pe-blob-nsg'
  location: location
  dependsOn: [blobPrivateEndpoint]
  properties: {
    ipConfigurations: blobPrivateEndpointNic.properties.ipConfigurations
    networkSecurityGroup: {
      id: storageNsg.id
    }
  }
}

resource tablePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pe-table'
  location: location
  properties: {
    subnet: {
      id: vnet.properties.subnets[0].id
    }
    privateLinkServiceConnections: [
      {
        name: 'tableConnection'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'table'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'pe-table-nic'
  }
}

resource tablePrivateEndpointNic 'Microsoft.Network/networkInterfaces@2023-05-01' existing = {
  name: 'pe-table-nic'
  dependsOn: [tablePrivateEndpoint]
}

resource tableNsgAssociation 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'pe-table-nsg'
  location: location
  dependsOn: [tablePrivateEndpoint]
  properties: {
    ipConfigurations: tablePrivateEndpointNic.properties.ipConfigurations
    networkSecurityGroup: {
      id: storageNsg.id
    }
  }
}

/* =====================
   NETWORK INTERFACE
===================== */

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

/* =====================
   VIRTUAL MACHINE
===================== */

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
