```
az sql db create -g $rg -s $server -n mydb
az sql db create -g $rg -s $server -n mydb --sample-name AdventureWorksLT
az sql db create -g $rg -s $server -n mydb --sample-name AdventureWorksLT --edition GeneralPurpose --compute-model Serverless --family Gen5 --capacity 2
```

```
az sql db show -g $rg -s $server -n mydb --query id -otsv

/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/r4/providers/Microsoft.Sql/servers/azuresql119676114/databases/mydb
```
