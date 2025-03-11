```
az lock create -g $rg -n LockGroup --lock-type ReadOnly

lockid=$(az lock show -g $rg -n LockGroup -otsv --query id)
az lock delete --ids $lockid

az lock list -otable
az lock list -g $rg -otable
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources?tabs=json#azure-cli
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#lock-resource-groups

```
# lock.delete
```

- https://stackoverflow.com/questions/69615910/what-permission-is-required-to-remove-or-add-resource-lock-for-azure-sql-with-te: it's either the built-in Owner or User Access Administrator roles or custom roles with the right action, that are allowed to manipulate locks.
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources?tabs=json#who-can-create-or-delete-locks: To create or delete management locks, you need access to Microsoft.Authorization/* or Microsoft.Authorization/locks/* actions. Users assigned to the Owner and the User Access Administrator roles have the required access. Some specialized built-in roles also grant this access. You can create a custom role with the required permissions.

```
# lock.delete.rg
rg=rglock
az group create -n $rg -l $loc
az lock create -g $rg -n lockrg --lock-type CanNotDelete
az group delete -n $rg -y
# (ScopeLocked) The scope '/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rglock' cannot perform delete operation because following scope(s) are locked: '/subscriptions/redacts-1111-1111-1111-111111111111/rglock'. Please remove the lock and try again.

## all resources within that (e.g., resource group) scope inherit the same lock
storage="mycoolstorage$RANDOM$RANDOM"
az storage account create -g $rg -n $storage
az storage account delete -g $rg -n $storage -y
# (ScopeLocked) The scope '/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rglock/providers/Microsoft.Storage/storageAccounts/mycoolstorage1696423148' cannot perform delete operation because following scope(s) are locked: '/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rglock'. Please remove the lock and try again.
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources?tabs=json#lock-inheritance: When you apply a lock at a parent scope, all resources within that scope inherit the same lock. Even resources you add later inherit the same parent lock.
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources?tabs=json#understand-scope-of-locks: Locks only apply to control plane Azure operations and not to data plane operations. Azure control plane operations go to https://management.azure.com. Azure data plane operations go to your service instance, such as https://myaccount.blob.core.windows.net/.
