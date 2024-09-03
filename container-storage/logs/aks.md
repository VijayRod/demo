```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks nodepool add -g $rg --cluster-name aks -n npmar -s $vmsize # --os-sku Mariner
az aks nodepool delete -g $rg --cluster-name aks -n np2 --no-wait
```

```
az aks create -g $rg -n akseph -s $vmsize -c 1 --node-osdisk-type Ephemeral -s Standard_DS3_v2
az aks create -g $rg -n aksgen -s $vmsize -c 1 -s Standard_D4s_v5 # Also non-ephemeral
```

- https://github.com/Azure/azure-rest-api-specs/blob/main/specification/containerservice/resource-manager/Microsoft.ContainerService/aks/stable/2023-02-01/managedClusters.json
- https://github.com/andyzhangx/demo/blob/master/debug/README.md
- https://github.com/feiskyer/kubernetes-handbook/blob/master/README.md
- https://learn.microsoft.com/en-us/azure/aks/
- https://learn.microsoft.com/en-us/azure/architecture/guide/multitenant/service/aks
- https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/create-or-update?tabs=HTTP#examples
- https://learn.microsoft.com/en-us/training/paths/aks-cluster-architecture/
- https://cloudacademy.com/course/introduction-to-aks-954/course-introduction/
- https://github.com/Azure/AKS/
- https://issuetracker.google.com/savedsearches/559746: Open Kubernetes Engine Issues
