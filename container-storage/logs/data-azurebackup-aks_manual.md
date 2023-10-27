```
TBD
az dataprotection backup-instance list-from-resourcegraph --datasource-type AzureKubernetesService --datasource-id /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.ContainerService/managedClusters/aks --query aksAssignedIdentity.id
az dataprotection backup-instance adhoc-backup --rule-name "BackupDaily" --ids /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.DataProtection/backupVaults/vault/backupInstances/$backupinstanceid
```

- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-backup-using-cli#run-an-on-demand-backup
