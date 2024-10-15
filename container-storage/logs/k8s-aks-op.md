## k8s-aks-op

```
az aks --debug
az aks --no-wait
```

## k8s-aks-op.abort

```
az aks operation-abort -g $rg -n aks
az aks nodepool operation-abort -g $rg --cluster-name aks --nodepool-name nodepool1

# (OperationNotAllowed) Cancel operation is not allowed when the ProvisioningState is Failed
```

- https://azure.microsoft.com/en-us/updates/public-preview-operation-abort/
- https://azure.microsoft.com/en-us/updates/generally-available-operation-abort-in-aks/
- https://learn.microsoft.com/en-us/azure/aks/manage-abort-operations?tabs=azure-cli
- https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/abort-latest-operation
- https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-operation-abort
- https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-operation-abort

## k8s-aks-op.delete.cluster

```
# The node resource group was removed before the cluster deletion was fully completed
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)   
az group delete -n $noderg -y -f # --no-wait
az aks delete -g $rg -n aks -y # --no-wait # success

# Removed the cluster resource group
az group delete -n $rg -y -f # --no-wait # success
```

## k8s-aks-op.reconcile

```
az aks update -g $rg -n aks
az aks nodepool update -g $noderg --cluster-name aks -n nodepool1
az resource update --id /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/$rg/providers/Microsoft.ContainerService/managedClusters/aks
```

## k8s-aks-op.upgrade

```
az aks show -g $rg -n aks --query agentPoolProfiles[0].upgradeSettings
  "drainTimeoutInMinutes": null,
  "maxSurge": "10%",
  "nodeSoakDurationInMinutes": null,
  "undrainableNodeBehavior": null
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade
- https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli
- https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster
- tbd https://www.pjlewis.com/posts/best-practices-for-upgrading-updating-your-aks-clusters/

### k8s-aks-op.upgrade.events

- https://azure.microsoft.com/en-us/updates/generally-available-azure-kubernetes-support-for-upgrade-events/

### k8s-aks-op.upgrade.auto

```
az aks show -g $rg -n aks --query autoUpgradeProfile
  "nodeOsUpgradeChannel": "NodeImage",
  "upgradeChannel": null
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade#automatic-upgrades
- https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster#configure-automatic-upgrades
