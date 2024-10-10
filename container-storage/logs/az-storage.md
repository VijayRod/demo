## az-storage

```
rg=rg
az group create -g $rg -l $loc

storage="storage$RANDOM"
az storage account create -g $rg -n $storage

az storage account list -g $rg
```

## az-storage.isHnsEnabled aka hns aka StorageV2

```
az storage account # --kind Default: StorageV2 # --enable-hierarchical-namespace --hns only when storage account kind is StorageV2
```

- https://learn.microsoft.com/en-us/azure/storage/blobs/upgrade-to-data-lake-storage-gen2-how-to?tabs=azure-cli: az storage account hns-migration start
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: isHnsEnabled: enable Hierarchical namespace for Azure DataLake storage account

## az-storage.kind

```
az storage account create -g $rgname -n $storageAccountName --kind StorageV2 --sku Premium_LRS --enable-large-file-share --output none
```
- https://aka.ms/storageaccounttypes
  - https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview#types-of-storage-accounts: Type of storage account (az storage account create --kind), Redundancy options (az storage account create --sku)

## az-storage.networkRuleSet.defaultAction

```
az storage account list -g MC_rg_aks_swedencentral 
    "networkRuleSet": {
      "bypass": "AzureServices",
      "defaultAction": "Allow", # Public network access = Enabled from all networks
      
az storage account list -g MC_rg_aks_swedencentral 
    "networkRuleSet": {
      "bypass": "AzureServices",
      "defaultAction": "Deny", # Public network access = Enabled from selected virtual networks and IP addresses / Disabled
```

## az-storage.networkRuleSet.defaultAction.firewall
- https://learn.microsoft.com/en-us/answers/questions/1166011/getting-a-403-error-when-connecting-to-a-blob-cont: "Check Allow Access From (All Networks / Selected Networks)" "Selected Networks" - It means the storage account is firewall enabled.

## az-storage.scale.throttling

- https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview#types-of-storage-accounts
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-storage-limits
- https://aka.ms/srpthrottlinglimits

## az-storage.sku

- https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview#types-of-storage-accounts: Type of storage account (az storage account create --kind), Redundancy options (az storage account create --sku)
