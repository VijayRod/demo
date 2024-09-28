```
rg=rgbatch
storage="batchstorage$RANDOM$RANDOM"
az group create -n $rg -l $loc
az storage account create -g $rg -n $storage # --sku Standard_LRS
az batch account create -g $rg -n batch --storage-account $storage -l $loc
az batch account login -g $rg -n batch # --shared-key-auth
```

```
az batch account create -g $rg -n batchaccount --storage-account $storage -l $loc # First run
Resource provider 'Microsoft.Batch' used by this operation is not registered. We are registering for you.
Registration succeeded.

az batch account list -otable

az batch account show -g $rg -n batch
#   "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Batch/batchAccounts/batch",
# "nodeManagementEndpoint": "redactid-1111-1111-1111-111111111111.swedencentral.service.batch.azure.com",
```

- https://learn.microsoft.com/en-us/azure/batch/batch-cli-get-started#sign-in-to-batch-account
