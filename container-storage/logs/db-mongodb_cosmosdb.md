```
rg=rg
dbaccount="dbacct$RANDOM"
az group create -g $rg -l swedencentral
az cosmosdb create -g $rg -n $dbaccount --kind MongoDB
az cosmosdb mongodb database create -g $rg -n mongo -a $dbaccount
```

```
az cosmosdb mongodb database show -g $rg -n mongo -a $dbaccount --query id -otsv

/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.DocumentDB/databaseAccounts/dbacct25226/mongodbDatabases/mongo
```

- https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/introduction
- https://learn.microsoft.com/en-us/cli/azure/cosmosdb/mongodb
