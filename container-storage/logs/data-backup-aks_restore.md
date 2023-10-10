```
az k8s-extension show --name azure-aks-backup --cluster-type managedClusters -g $rg --cluster-name aks -otable
az role assignment list --all --assignee  $(az k8s-extension show --name azure-aks-backup -g $rg --cluster-name aks --cluster-type managedClusters --query aksAssignedIdentity.principalId --output tsv)
az role assignment create --assignee-object-id $(az k8s-extension show --name azure-aks-backup -g $rg --cluster-name aks --cluster-type managedClusters --query aksAssignedIdentity.principalId --output tsv) --role 'Storage Account Contributor'  --scope /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$storage
# az k8s-extension create --name azure-aks-backup --extension-type microsoft.dataprotection.kubernetes --scope cluster --cluster-type managedClusters -g $rg --cluster-name aks --release-train stable --configuration-settings blobContainer=$blobcontainer storageAccount=$storage storageAccountResourceGroup=$rg storageAccountSubscriptionId=$subId
```

- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-restore-using-cli
