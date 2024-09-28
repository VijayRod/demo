```
# Replace the below with appropriate values.
rgname=secureshack2
clustername=akspodsubnet
vnet=myvnet
subId=$(az account show --query id -otsv)
```

```
# To create the two network subnets
az network vnet create -g $rgname --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rgname --vnet-name $vnet --name nodesubnet --address-prefixes 10.240.0.0/16 -o none 
az network vnet subnet create -g $rgname --vnet-name $vnet --name podsubnet --address-prefixes 10.241.0.0/16 -o none

# To create the cluster
az aks create -g $rgname -n $clustername --network-plugin azure \
    --vnet-subnet-id /subscriptions/$subId/resourceGroups/$rgname/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/nodesubnet \
    --pod-subnet-id /subscriptions/$subId/resourceGroups/$rgname/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/podsubnet
```

```
# To query the values
az aks show -g $rgname -n $clustername --query id
az aks show -g $rgname -n $clustername --query agentPoolProfiles[0].podSubnetId
az aks show -g $rgname -n $clustername --query agentPoolProfiles[0].vnetSubnetId

# Here is a sample output below.
"/subscriptions/dummys-1111-1111-1111-111111111111/resourcegroups/resourceGroupName/providers/Microsoft.ContainerService/managedClusters/akspodsubnet"
"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/resourceGroupName/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/podsubnet"
"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/resourceGroupName/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/nodesubnet"
```

```
# To cleanup
az aks delete -g $rgname -n $clustername -y --no-wait
az network vnet delete -g $rgname -n $vnet --no-wait
```

- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni-dynamic-ip-allocation
