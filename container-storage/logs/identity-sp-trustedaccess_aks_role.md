```
az aks trustedaccess role list -l $loc -otable
Name                         SourceResourceType
---------------------------  --------------------------------------------
backup-operator              Microsoft.DataProtection/backupVaults
mlworkload                   Microsoft.MachineLearningServices/workspaces
inference-v1                 Microsoft.MachineLearningServices/workspaces
microsoft-defender-operator  Microsoft.Security/pricings
```

```
# After configuring Azure Backup for a cluster
az aks trustedaccess rolebinding list -g $rg --cluster-name aks
[
  {
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerService/managedClusters/aks/trustedAccessRoleBindings/16987634996993c51c18b-7",
    "name": "16987634996993c51c18b-7",
    "provisioningState": "Succeeded",
    "resourceGroup": "rg",
    "roles": [
      "Microsoft.DataProtection/backupVaults/backup-operator"
    ],
    "sourceResourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.DataProtection/backupVaults/vault",
    "systemData": null,
    "type": "Microsoft.ContainerService/managedClusters/trustedAccessRoleBindings"
  }
]
```

- https://learn.microsoft.com/en-us/cli/azure/aks/trustedaccess/role?view=azure-cli-latest
