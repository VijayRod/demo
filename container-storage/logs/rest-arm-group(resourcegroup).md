```
rg=testshack2
loc=swedencentral
az group create -n $rg -l $loc
# az group delete -n $rg -y --no-wait
```

```
az resource list -l $loc -otable | grep rgredis
Name                                                                                    ResourceGroup                                         Location       Type                                              Status
--------------------------------------------------------------------------------------  -------------------------------------------------------------------  -------------  ------------------------------------------------  --------
redis3942                                                                               rgredis                                         swedencentral  Microsoft.Cache/Redis
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#what-is-a-resource-group
