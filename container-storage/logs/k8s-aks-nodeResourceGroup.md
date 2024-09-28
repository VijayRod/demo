Directly modifying resources in the node resource group can cause your cluster to become unstable or unresponsive. Unless otherwise documented, we do not recommend changes to the node resource group and such changes can result in the cluster being unsupported.

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)

kubectl describe no | grep /cluster
Name:               aks-nodepool1-16663898-vmss000001
Labels:             agentpool=nodepool1
                    kubernetes.azure.com/cluster=MC_rg_aks_centralus
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#custom-resource-group-name
- https://learn.microsoft.com/en-us/azure/aks/concepts-clusters-workloads#node-resource-group
- https://learn.microsoft.com/en-us/azure/aks/faq#why-are-two-resource-groups-created-with-aks
