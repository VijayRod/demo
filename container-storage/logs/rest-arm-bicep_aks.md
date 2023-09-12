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
