```
az lock create -g $rg -n LockGroup --lock-type ReadOnly

lockid=$(az lock show -g $rg -n LockGroup -otsv --query id)
az lock delete --ids $lockid

az lock list -otable
az lock list -g $rg -otable
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources?tabs=json#azure-cli
