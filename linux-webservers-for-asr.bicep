// Example use:
// https://docs.microsoft.com/en-us/learn/modules/protect-infrastructure-with-site-recovery/
// az group create --name east-coast-rg --location eastus2
// az group create --name west-coast-rg --location westus2
// az deployment group what-if --name asrViaBicep --template-file linux-webservers-for-asr.bicep --resource-group west-coast-rg
// az deployment group create --name asrViaBicep --template-file linux-webservers-for-asr.bicep --resource-group west-coast-rg
param webserver01_name string = 'webserver01'
param webserver01_NIC_name string = 'webserver01-NIC'
param publicIP_webserver01_name string = 'webserver01-ip'
param webserver02_name string = 'webserver02'
param webserver02_NIC_name string = 'webserver02-nic'
param publicIP_webserver02_name string = 'webserver02-ip'

param vnet_name string = 'webserver-vnet-primary'
param nsg_name string = 'vnet-primary-default-nsg'
param storageAccounts_asrcache_name string = 'asrcache${uniqueString(resourceGroup().id)}'
param storageAccounts_diag_name string = 'diags${uniqueString(resourceGroup().id)}'
param primaryLocation string = resourceGroup().location
// Security? Who needs that? A more secure and higher-effort approach would be to create a key vault and autogenerate
// a password, then put the password in the key vault.
param adminUsername string = 'learn-admin' // note there is a hardcoded /home/learn-admin in the associated cloud-init
param adminPassword string = 'Pa55w0rd!Paasw0rd'

var cloudInit = loadFileAsBase64('linux-webservers-for-asr-cloud-config.yml')

resource nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2019-04-01' = {
  name: nsg_name
  location: primaryLocation
  properties: {
    securityRules: [
      {
        name: 'HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'HTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 320
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'SSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 340
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource publicIP_webserver01_name_resource 'Microsoft.Network/publicIPAddresses@2019-04-01' = {
  name: publicIP_webserver01_name
  location: primaryLocation
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource publicIP_webserver02_name_resource 'Microsoft.Network/publicIPAddresses@2019-04-01' = {
  name: publicIP_webserver02_name
  location: primaryLocation
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource vnet_name_resource 'Microsoft.Network/virtualNetworks@2019-04-01' = {
  name: vnet_name
  location: primaryLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.1.0/24'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.1.1.0/24'
          delegations: []
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource storageAccounts_asrcache_name_resource 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: storageAccounts_asrcache_name
  location: primaryLocation
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: false
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource storageAccounts_diag_name_resource 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: storageAccounts_diag_name
  location: primaryLocation
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource webserver01_name_resource 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: webserver01_name
  location: primaryLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccounts_diag_name_resource.properties.primaryEndpoints.blob
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${webserver01_name}_OS'
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 64
      }
      dataDisks: []
    }
    osProfile: {
      computerName: webserver01_name
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: cloudInit
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: webserver01_NIC_name_resource.id
        }
      ]
    }
  }
}

resource webserver02_name_resource 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: webserver02_name
  location: primaryLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccounts_diag_name_resource.properties.primaryEndpoints.blob
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${webserver02_name}_OS'
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 64
      }
      dataDisks: []
    }
    osProfile: {
      computerName: webserver02_name
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: cloudInit
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: webserver02_NIC_name_resource.id
        }
      ]
    }
  }
}

resource subnet_name_default 'Microsoft.Network/virtualNetworks/subnets@2019-04-01' = {
  parent: vnet_name_resource
  name: 'default'
  properties: {
    addressPrefix: '10.1.1.0/24'
    delegations: []
    networkSecurityGroup: {
      id: nsg_name_resource.id
    }
  }
}

resource storageAccounts_asrcache_name_default 'Microsoft.Storage/storageAccounts/blobServices@2019-04-01' = {
  parent: storageAccounts_asrcache_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource storageAccounts_diag_name_default 'Microsoft.Storage/storageAccounts/blobServices@2019-04-01' = {
  parent: storageAccounts_diag_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource webserver01_NIC_name_resource 'Microsoft.Network/networkInterfaces@2019-04-01' = {
  name: webserver01_NIC_name
  location: primaryLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP_webserver01_name_resource.id
          }
          subnet: {
            id: subnet_name_default.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
      appliedDnsServers: []
      internalDomainNameSuffix: 'mslearn-asr-usw2.internal.cloudapp.net'
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    primary: true
    tapConfigurations: []
  }
}

resource webserver02_NIC_name_resource 'Microsoft.Network/networkInterfaces@2019-04-01' = {
  name: webserver02_NIC_name
  location: primaryLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP_webserver02_name_resource.id
          }
          subnet: {
            id: subnet_name_default.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
      appliedDnsServers: []
      internalDomainNameSuffix: 'mslearn-asr-usw2.internal.cloudapp.net'
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    primary: true
    tapConfigurations: []
  }
}
