```
az dataprotection backup-vault create --resource-group $rg --vault-name vault --type SystemAssigned --storage-settings datastore-type="VaultStore" type="LocallyRedundant"
az dataprotection backup-policy get-default-policy-template --datasource-type AzureKubernetesService > /tmp/akspolicy.json
# cat /tmp/akspolicy.json
az dataprotection backup-policy create -g $rg --vault-name vault -n mypolicy --policy /tmp/akspolicy.json

storage="backups$RANDOM$RANDOM"
az storage account create -g $rg --name $storage --sku Standard_LRS
az storage container create --name backups --account-name $storage --auth-mode login

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

subId=$(az account show --query id -otsv)
az k8s-extension create -g $rg --cluster-name aks -n azure-aks-backup --extension-type microsoft.dataprotection.kubernetes --scope cluster --cluster-type managedClusters --release-train stable --configuration-settings blobContainer=backups storageAccount=$storage storageAccountResourceGroup=$rg storageAccountSubscriptionId=$subId
az k8s-extension show -g $rg --cluster-name aks --name azure-aks-backup --cluster-type managedClusters -otable
```

```
Name              ExtensionType                        ProvisioningState    LastModifiedAt                    Plan_name                    Plan_product    IsSystemExtension
----------------  -----------------------------------  -------------------  --------------------------------  -----------  --------------  --------------  -------------------
azure-aks-backup  microsoft.dataprotection.kubernetes  Succeeded            2023-10-09T20:24:26.936275+00:00               plan_publisher                  False

kubectl get po -n kube-system --show-labels -l app.kubernetes.io/name=extension-manager
NAME                                 READY   STATUS    RESTARTS   AGE     LABELS
extension-agent-79f88c7d65-j6knq     2/2     Running   0          8m46s   app.kubernetes.io/component=extension-agent,app.kubernetes.io/name=extension-manager,control-plane=extension-agent,kubernetes.azure.com/managedby=aks,pod-template-hash=79f88c7d65
extension-operator-8fc67cf49-lkvtx   2/2     Running   0          8m46s   app.kubernetes.io/component=extension-operator,app.kubernetes.io/name=extension-manager,control-plane=extension-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=8fc67cf49

kubectl get po -n dataprotection-microsoft --show-labels
NAME                                                         READY   STATUS    RESTARTS   AGE    LABELS
dataprotection-microsoft-controller-5bb4f6d877-9b4g9         2/2     Running   0          5m3s   app.kubernetes.io/instance=azure-aks-backup,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dataprotection-microsoft-kubernetes,control-plane=dataprotection-microsoft-controller,helm.sh/chart=dataprotection-microsoft-kubernetes-0.0.2462-146,pod-template-hash=5bb4f6d877
dataprotection-microsoft-geneva-service-59996894b9-2dh5n     2/2     Running   0          5m3s   app.kubernetes.io/component=geneva-service,app.kubernetes.io/name=azure-arc-k8s,pod-template-hash=59996894b9
dataprotection-microsoft-kubernetes-agent-8446d5458b-2fcr8   2/2     Running   0          5m3s   app.kubernetes.io/instance=azure-aks-backup,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dataprotection-microsoft-kubernetes,helm.sh/chart=dataprotection-microsoft-kubernetes-0.0.2462-146,name=velero,pod-template-hash=8446d5458b
```

```
TBD

az role assignment create --assignee-object-id $(az k8s-extension show --name azure-aks-backup -g $rg --cluster-name aks --cluster-type managedClusters --query aksAssignedIdentity.principalId --output tsv) --role 'Storage Account Contributor' --scope /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$storage
az aks trustedaccess rolebinding create -g $rg --cluster-name aks --name backuprolebinding --roles Microsoft.DataProtection/backupVaults/backup-operator --source-resource-id /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.DataProtection/BackupVaults/vault

# az dataprotection backup-instance initialize-backupconfig --datasource-type AzureKubernetesService > /tmp/aksbackupconfig.json
# cat /tmp/aksbackupconfig.json
{
 "excluded_namespaces": null,
 "excluded_resource_types": null,
 "include_cluster_scope_resources": true,
 "included_namespaces": null, 
 "included_resource_types": null,
 "label_selectors": null,
 "snapshot_volumes": true
}
az dataprotection backup-instance initialize --datasource-id /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.ContainerService/managedClusters/aks --datasource-location $loc --datasource-type AzureKubernetesService --policy-id /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.DataProtection/backupVaults/vault/backupPolicies/backuppolicy --backup-configuration /tmp/aksbackupconfig.json --friendly-name ecommercebackup --snapshot-resource-group-name $rg > /tmp/backupinstance.json
# cat /tmp/backupinstance.json

az dataprotection backup-instance validate-for-backup --backup-instance /tmp/backupinstance.json --ids /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.DataProtection/backupVaults/vault

# az dataprotection backup-instance update-msi-permissions command.
# az dataprotection backup-instance update-msi-permissions --datasource-type AzureKubernetesService --operation Backup --permissions-scope ResourceGroup --vault-name vault --resource-group $rg --backup-instance /tmp/backupinstance.json

az dataprotection backup-instance create --backup-instance  /tmp/backupinstance.json --resource-group $rg --vault-name vault
```

- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-backup
- https://learn.microsoft.com/en-us/azure/aks/hybrid/backup-workload-cluster
- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-backup-support-matrix#limitations
- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-backup-concept#aks-cluster: prerequisites
