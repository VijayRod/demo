```
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

- https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep?tabs=azure-cli
- https://learn.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters?pivots=deployment-language-bicep
