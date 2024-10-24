```
rgname=testshack2
loc=swedencentral

az group create -n $rgname --location $loc
```

```
az group delete -n $rgname -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#what-is-a-resource-group
