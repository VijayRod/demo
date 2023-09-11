```
rg=rg
server="azuresql$(($RANDOM*$RANDOM))"
pass="Pa$$w0rD$(($RANDOM*$RANDOM))"
startIp=0.0.0.0 # For test purpose only.
endIp=0.0.0.0 # For test purpose only.
az group create -n $rg -l $loc
az sql server create -g $rg -n $server --admin-user azureuser --admin-password $pass
az sql server firewall-rule create -g $rg -s $server -n AllowYourIp --start-ip-address $startIp --end-ip-address $endIp
az sql elastic-pool create -g $rg -s $server -n hspool --edition Hyperscale --capacity 4 --family Gen5 --ha-replicas 2
```

```
az sql elastic-pool show -g $rg -s $server -n hspool --query id -otsv

/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/rg2/providers/Microsoft.Sql/servers/azuresql1861273/elasticPools/hspool

az sql elastic-pool update -g $rg -s $server -n hspool --capacity 8 --db-min-capacity 0 --db-max-capacity 2
```

- TBD https://learn.microsoft.com/en-us/azure/azure-sql/database/elastic-pool-overview
- https://learn.microsoft.com/en-us/azure/azure-sql/database/hyperscale-elastic-pool-overview
- https://learn.microsoft.com/en-us/azure/azure-sql/database/hyperscale-elastic-pool-command-line?view=azuresql-db&tabs=azure-cli
