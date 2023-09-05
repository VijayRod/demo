```
rg=rg
dbaccount="dbacct$RANDOM"
az group create -g $rg -l swedencentral
az cosmosdb create -g $rg -n $dbaccount
```

```
az cosmosdb show -g $rg -n $dbaccount | grep -E 'documentEndpoint|id'
  "documentEndpoint": "https://dbacct25226.documents.azure.com:443/",
  "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.DocumentDB/databaseAccounts/dbacct25226",
```

```  
TBD az cosmosdb update -g $rg -n $dbaccount
```

- https://learn.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az-cosmosdb-create
