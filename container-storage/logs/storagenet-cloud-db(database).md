## db

## db.sql

- https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-guides: SQL Server internals and architecture guides
- https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/sql-server-in-memory-oltp-internals-for-sql-server-2016
- https://www.freecodecamp.org/news/acid-databases-explained/
- https://www.amazon.com/Gurus-Guide-Server-Architecture-Internals/dp/0201700476

## db.azuresql

```
rg=rg
server="azuresql$(($RANDOM*$RANDOM))"
pass="Pa$$w0rD$(($RANDOM*$RANDOM))"
startIp=0.0.0.0 # For test purpose only.
endIp=0.0.0.0 # For test purpose only.
az group create -n $rg -l swedencentral
az sql server create -g $rg -n $server --admin-user azureuser --admin-password $pass
az sql server firewall-rule create -g $rg -s $server -n AllowYourIp --start-ip-address $startIp --end-ip-address $endIp
az sql db create -g $rg -s $server -n mydb
echo $server $pass
```

```
az sql server show -g $rg -n $server --query id -otsv

/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/r4/providers/Microsoft.Sql/servers/azuresql119676114

az sql server show -g $rg -n $server --query fullyQualifiedDomainName -otsv

azuresql119676114.database.windows.net
```

- https://learn.microsoft.com/en-us/azure/azure-sql/database/single-database-create-quickstart
  
## db.azuresqldb

```
az sql db create -g $rg -s $server -n mydb
az sql db create -g $rg -s $server -n mydb --sample-name AdventureWorksLT
az sql db create -g $rg -s $server -n mydb --sample-name AdventureWorksLT --edition GeneralPurpose --compute-model Serverless --family Gen5 --capacity 2
```

```
az sql db show -g $rg -s $server -n mydb --query id -otsv

/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/r4/providers/Microsoft.Sql/servers/azuresql119676114/databases/mydb
```

## db.cosmosdb

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

## db.mongodb.cosmosdb

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

## db.postgres

```
rg=rg
az group create -n $rg -l $loc

postgresServer=postgres$RANDOM
postgresUser=user$RANDOM
postgresPassword=passP~$RANDOM
az postgres server create -g $rg -n $postgresServer -u $postgresUser -p $postgresPassword # --sku-name B_Gen5_1
az postgres db create -g $rg -s $postgresServer -n postgres
```

- https://learn.microsoft.com/en-us/cli/azure/postgres

## db.postgres.billing
```
```

- https://aka.ms/postgres-pricing

## db.postgres.core.server

```
az postgres server list
az postgres server show -g $rg -n $postgresServer --query id -otsv
```

## db.postgres.core.server.firewall

```
postgresId=$(az postgres server show -g $rg -n $postgresServer --query id -otsv)
az postgres server firewall-rule list --id $postgresId
```

## db.postgres.core.db

```
```

## db.postgres.ResourceProvider

```
postgresId=$(az postgres server show -g $rg -n $postgresServer --query id -otsv)
echo $postgresId
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.DBforPostgreSQL/servers/postgres29
```
