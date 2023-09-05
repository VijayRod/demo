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
