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
