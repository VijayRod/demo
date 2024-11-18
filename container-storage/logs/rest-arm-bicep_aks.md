## bicep.aks

```
# aks
param location string = resourceGroup().location
param keyData string ='ssh-rsa ...' //  cat ~/.ssh/id_rsa.pub 

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-07-01' = {
  name: 'aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'dnsprefix'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_B2ms' // Standard_DS2_v2
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: 'adminUserName'
      ssh: {
        publicKeys: [
          {
            keyData: keyData
          }
        ]
      }
    }
  }
}
```

```
# aks.vnet.custom

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'aks-custom-vnet'  
  location: resourceGroup().location  
  properties: {    
    addressSpace: {      
      addressPrefixes: ['172.19.0.0/16']    
    }  
  }
}
resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {  
  parent: vnet  
  name: 'aks-subnet'  
  properties: {    
    addressPrefix: '172.19.1.0/24'  
  }
}
resource aks 'Microsoft.ContainerService/managedClusters@2024-03-02-preview' = {  
  name: 'aks-sami-byo-vnet'  
  location: resourceGroup().location    
  sku: {    
    name: 'Base'    
    tier: 'Standard'  
  }  
  properties: {    
    dnsPrefix: 'aks-sami-byo-vnet'    
    networkProfile: {      
      networkPlugin: 'azure'      
      networkPluginMode: 'overlay'      
      networkDataplane: 'cilium'    
    }    
    agentPoolProfiles: [  
      { 
        name: 'systempool'        
        mode: 'System'        
        osType: 'Linux'        
        vmSize: 'Standard_B2ms'        // Standard_DS2_v3
        count: 1        
        vnetSubnetID: aksSubnet.id      
      }  
    ]  
  }  
  identity: {    
    type: 'SystemAssigned'  
  }
}
```

- https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep?tabs=azure-cli
- https://learn.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters?pivots=deployment-language-bicep
