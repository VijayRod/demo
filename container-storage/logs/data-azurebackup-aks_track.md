```
az dataprotection job list-from-resourcegraph --datasource-type AzureKubernetesService --datasource-id /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.ContainerService/managedClusters/aks --operation OnDemandBackup -otable
DatasourceId
            Kind    Location       ManagedBy    Name                                  Operation       ResourceGroup    Status     SubscriptionId                        TenantId                              VaultName
------------------------------------------------------------------------------------------------------------------------------  ------  -------------  -----------  ------------------------------------  --------------  ---------------  ---------  ------------------------------------  ------------------------------------  -----------
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerService/managedclusters/aks          swedencentral               28af6d67-64f4-4300-8369-18f9f9ac0ca7  OnDemandBackup  rg
   Completed  redacts-1111-1111-1111-111111111111  redactt-1111-1111-1111-111111111111  vault

az dataprotection job list-from-resourcegraph --datasource-type AzureKubernetesService --datasource-id /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.ContainerService/managedClusters/aks --operation ScheduledBackup -otable
```

- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-backup-using-cli#tracking-jobs
