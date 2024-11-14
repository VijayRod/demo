```
# See the section on az graph query

az resource list -l $loc -otable | grep rgredis
Name                                                                                    ResourceGroup                                         Location       Type                                              Status
--------------------------------------------------------------------------------------  -------------------------------------------------------------------  -------------  ------------------------------------------------  --------
redis3942                                                                               rgredis                                         swedencentral  Microsoft.Cache/Redis
```

- https://learn.microsoft.com/en-us/cli/azure/resource
