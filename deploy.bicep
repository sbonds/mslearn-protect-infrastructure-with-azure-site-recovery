param virtualMachines_hr_records_name string = 'hr-records'
param networkInterfaces_hr_records71_name string = 'hr-records71'
param virtualMachines_patient_records_name string = 'patient-records'
param publicIPAddresses_hr_records_ip_name string = 'hr-records-ip'
param virtualNetworks_asr_vnet_name string = 'asr-vnet'
param networkInterfaces_patient_records71_name string = 'patient-records71'
param networkSecurityGroups_hr_records_nsg_name string = 'hr-records-nsg'
param publicIPAddresses_patient_records_ip_name string = 'patient-records-ip'
param networkSecurityGroups_patient_records_nsg_name string = 'patient-records-nsg'
param storageAccounts_asrcache_name string
param primaryLocation string = 'westus2'
// Security? Who needs that?
param adminUsername string = 'learn-admin'
param adminPassword string = 'Pa55w0rd!Paasw0rd'

resource networkSecurityGroups_hr_records_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2019-04-01' = {
  name: networkSecurityGroups_hr_records_nsg_name
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

resource networkSecurityGroups_patient_records_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2019-04-01' = {
  name: networkSecurityGroups_patient_records_nsg_name
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

resource publicIPAddresses_hr_records_ip_name_resource 'Microsoft.Network/publicIPAddresses@2019-04-01' = {
  name: publicIPAddresses_hr_records_ip_name
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

resource publicIPAddresses_patient_records_ip_name_resource 'Microsoft.Network/publicIPAddresses@2019-04-01' = {
  name: publicIPAddresses_patient_records_ip_name
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

resource virtualNetworks_asr_vnet_name_resource 'Microsoft.Network/virtualNetworks@2019-04-01' = {
  name: virtualNetworks_asr_vnet_name
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

resource virtualMachines_hr_records_name_resource 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: virtualMachines_hr_records_name
  location: primaryLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2016-Datacenter-Server-Core-smalldisk'
        version: 'latest'
      }
      osDisk: {
        name: '${virtualMachines_hr_records_name}_OsDisk_1_cd343a79c7564d188d5929c6b1dac73a'
        osType: 'Windows'
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
      computerName: virtualMachines_hr_records_name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_hr_records71_name_resource.id
        }
      ]
    }
  }
}

resource virtualMachines_patient_records_name_resource 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: virtualMachines_patient_records_name
  location: primaryLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2016-Datacenter-Server-Core-smalldisk'
        version: 'latest'
      }
      osDisk: {
        name: '${virtualMachines_patient_records_name}_OsDisk_1_23d4d09d3f22424f884dd14635024ebe'
        osType: 'Windows'
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
      computerName: virtualMachines_patient_records_name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_patient_records71_name_resource.id
        }
      ]
    }
  }
}

resource networkSecurityGroups_hr_records_nsg_name_HTTP 'Microsoft.Network/networkSecurityGroups/securityRules@2019-04-01' = {
  parent: networkSecurityGroups_hr_records_nsg_name_resource
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

resource networkSecurityGroups_patient_records_nsg_name_HTTP 'Microsoft.Network/networkSecurityGroups/securityRules@2019-04-01' = {
  parent: networkSecurityGroups_patient_records_nsg_name_resource
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

resource networkSecurityGroups_hr_records_nsg_name_HTTPS 'Microsoft.Network/networkSecurityGroups/securityRules@2019-04-01' = {
  parent: networkSecurityGroups_hr_records_nsg_name_resource
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

resource networkSecurityGroups_patient_records_nsg_name_HTTPS 'Microsoft.Network/networkSecurityGroups/securityRules@2019-04-01' = {
  parent: networkSecurityGroups_patient_records_nsg_name_resource
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

resource networkSecurityGroups_hr_records_nsg_name_SSH 'Microsoft.Network/networkSecurityGroups/securityRules@2019-04-01' = {
  parent: networkSecurityGroups_hr_records_nsg_name_resource
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

resource networkSecurityGroups_patient_records_nsg_name_SSH 'Microsoft.Network/networkSecurityGroups/securityRules@2019-04-01' = {
  parent: networkSecurityGroups_patient_records_nsg_name_resource
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

resource virtualNetworks_asr_vnet_name_default 'Microsoft.Network/virtualNetworks/subnets@2019-04-01' = {
  parent: virtualNetworks_asr_vnet_name_resource
  name: 'default'
  properties: {
    addressPrefix: '10.1.1.0/24'
    delegations: []
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

resource networkInterfaces_hr_records71_name_resource 'Microsoft.Network/networkInterfaces@2019-04-01' = {
  name: networkInterfaces_hr_records71_name
  location: primaryLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_hr_records_ip_name_resource.id
          }
          subnet: {
            id: virtualNetworks_asr_vnet_name_default.id
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
    networkSecurityGroup: {
      id: networkSecurityGroups_hr_records_nsg_name_resource.id
    }
    primary: true
    tapConfigurations: []
  }
}

resource networkInterfaces_patient_records71_name_resource 'Microsoft.Network/networkInterfaces@2019-04-01' = {
  name: networkInterfaces_patient_records71_name
  location: primaryLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_patient_records_ip_name_resource.id
          }
          subnet: {
            id: virtualNetworks_asr_vnet_name_default.id
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
    networkSecurityGroup: {
      id: networkSecurityGroups_patient_records_nsg_name_resource.id
    }
    primary: true
    tapConfigurations: []
  }
}
