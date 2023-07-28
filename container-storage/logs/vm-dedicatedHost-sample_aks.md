```
# Replace the below with appropriate values.
rgname=secureshack2
clustername=akshost
hostgroupname="myHostGroup"
host1name="myHost"
host2name="myHost2"
subId=$(az account show --query id -otsv)
rgresourceId="/subscriptions/$subId/resourceGroups/$rgname"
```

```
# To create the host group
az vm host group create -g $rgname --name $hostgroupname --platform-fault-domain 2 --automatic-placement true

# To create the dedicated hosts
az vm host create -g $rgname --host-group $hostgroupname --name $host1name --sku DSv4-Type2 --platform-fault-domain 0
az vm host create -g $rgname --host-group $hostgroupname --name $host2name --sku DSv4-Type2 --platform-fault-domain 1
```

```
# To create an identity with contributor access to the resource group of the host group
identityPrincipalId=$(az identity create -g $rgname -n myHostIdentity --query principalId -otsv)
az role assignment create --assignee-object-id $identityPrincipalId --role "Contributor" --scope $rgresourceId

# To create a cluster
identityId=$(az identity show -g $rgname -n myHostIdentity --query id -otsv)
hostGroupId=$(az vm host group show -g $rgname --name $hostgroupname --query id -otsv)
az aks create -g $rgname -n $clustername --host-group-id $hostGroupId --node-vm-size Standard_D4s_v4 --enable-managed-identity --assign-identity $identityId
```

```
# az aks show -g $rgname -n $clustername --query agentPoolProfiles[0].hostGroupId
"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/SECURESHACK2/providers/Microsoft.Compute/hostGroups/myHostGroup"

# az vm host get-instance-view -g $rgname --host-group $hostgroupname --name $host1name --query virtualMachines
[
  {
    "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/MC_SECURESHACK2_AKSHOST_SWEDENCENTRAL/providers/Microsoft.Compute/virtualMachineScaleSets/AKS-NODEPOOL1-13309395-VMSS/virtualMachines/0",
    "resourceGroup": "MC_SECURESHACK2_AKSHOST_SWEDENCENTRAL"
  },
  {
    "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/MC_SECURESHACK2_AKSHOST_SWEDENCENTRAL/providers/Microsoft.Compute/virtualMachineScaleSets/AKS-NODEPOOL1-13309395-VMSS/virtualMachines/2",
    "resourceGroup": "MC_SECURESHACK2_AKSHOST_SWEDENCENTRAL"
  }
]
```

```
# To cleanup
az aks delete -g $rgname -n $clustername -y
az identity delete -g $rgname -n myHostIdentity
az vm host delete -g $rgname --host-group $hostgroupname --name $host1name -y --no-wait
az vm host delete -g $rgname --host-group $hostgroupname --name $host2name -y
az vm host group delete -g $rgname --name $hostgroupname -y
```

https://learn.microsoft.com/en-us/azure/aks/use-azure-dedicated-hosts
