```
az aks create -g $rg -n aks2 -s $vmsize -c 1
az aks get-credentials -g $rg -n aks2 --overwrite-existing

# TBD (Restore to aks2 using the portal, optionally after the steps outlined below)
subId=$(az account show --query id -otsv)
az k8s-extension create -g $rg --cluster-name aks2 -n azure-aks-backup --extension-type microsoft.dataprotection.kubernetes --scope cluster --cluster-type managedClusters --release-train stable --configuration-settings blobContainer=backups storageAccount=$storage storageAccountResourceGroup=$rg storageAccountSubscriptionId=$subId
az k8s-extension show -g $rg --cluster-name aks2 --name azure-aks-backup --cluster-type managedClusters -otable
```
