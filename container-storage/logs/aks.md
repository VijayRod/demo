```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s Standard_B2ms -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks nodepool add -g $rg --cluster-name aks -n npmar # --os-sku Mariner
```

- https://learn.microsoft.com/en-us/azure/aks/
- https://learn.microsoft.com/en-us/training/paths/aks-cluster-architecture/
- https://learn.microsoft.com/en-us/azure/architecture/guide/multitenant/service/aks
- https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/create-or-update?tabs=HTTP#examples
- https://github.com/Azure/azure-rest-api-specs/blob/main/specification/containerservice/resource-manager/Microsoft.ContainerService/aks/stable/2023-02-01/managedClusters.json
