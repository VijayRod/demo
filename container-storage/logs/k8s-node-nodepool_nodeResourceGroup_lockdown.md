```
rg=rglock
az group create -n $rg -l $loc
az aks create -g $rg -n aks --nrg-lockdown-restriction-level ReadOnly -s Standard_B2ms -c 1
```

```
az aks update -g $rg -n aks --nrg-lockdown-restriction-level ReadOnly
az aks update -g $rg -n aks --nrg-lockdown-restriction-level Unrestricted

az aks show -g $rg -n aks --query nodeResourceGroupProfile
{
  "restrictionLevel": "ReadOnly"
}
```

```
nodeResourceGroup=$(az aks show -g $rg -n aks --query nodeResourceGroup -otsv)
az disk create -g $nodeResourceGroup -n myAKSDisk --size-gb 20
(DenyAssignmentAuthorizationFailed) The client 'user@email.com' with object id 'dummyo-1add-464e-a41f-5ea8ef4e4c49' has permission to perform action 'Microsoft.Compute/disks/write' on scope '/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/MC_rglock_aks_swedencentral/providers/Microsoft.Compute/disks/myAKSDisk'; however, the access is denied because of the deny assignment with name 'kubernetes.azure.com/dummy-485a-4e2e-acc8-c01f53c241ae/dummy-0ce9-5642-acaf-15775e7f2b80: node resource group deny assignment created by Azure Kubernetes Services for nrg-lockdown, see: https://aka.ms/aks/nrg_lockdown' and Id '11111f740ce95642acaf15775e7f2b80' at scope '/subscriptions/dummys-1111-1111-1111-111111111111/resourcegroups/MC_rglock_aks_swedencentral'.
Code: DenyAssignmentAuthorizationFailed
Message: The client 'user@email.com' with object id 'dummyo-1add-464e-a41f-5ea8ef4e4c49' has permission to perform action 'Microsoft.Compute/disks/write' on scope '/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/MC_rglock_aks_swedencentral/providers/Microsoft.Compute/disks/myAKSDisk'; however, the access is denied because of the deny assignment with name 'kubernetes.azure.com/dummy-485a-4e2e-acc8-c01f53c241ae/dummy-0ce9-5642-acaf-15775e7f2b80: node resource group deny assignment created by Azure Kubernetes Services for nrg-lockdown, see: https://aka.ms/aks/nrg_lockdown' and Id '11111f740ce95642acaf15775e7f2b80' at scope '/subscriptions/dummys-1111-1111-1111-111111111111/resourcegroups/MC_rglock_aks_swedencentral'.
```

- https://azure.microsoft.com/en-us/updates/public-preview-node-resource-group-nrg-lockdown/
- https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#fully-managed-resource-group
