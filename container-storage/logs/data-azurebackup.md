## azurebackup.aks

```
# azurebackup.aks.manual

TBD
az dataprotection backup-instance list-from-resourcegraph --datasource-type AzureKubernetesService --datasource-id /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.ContainerService/managedClusters/aks --query aksAssignedIdentity.id
az dataprotection backup-instance adhoc-backup --rule-name "BackupDaily" --ids /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.DataProtection/backupVaults/vault/backupInstances/$backupinstanceid
```

- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-backup-using-cli#run-an-on-demand-backup

# azurebackup.aks.k8sextension

- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions#currently-available-extensions: Azure Backup for AKS
- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-manage-backups#install-backup-extension
