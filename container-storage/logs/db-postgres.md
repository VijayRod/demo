## postgres

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

## postgres.billing
```
```

- https://aka.ms/postgres-pricing

## postgres.core.server

```
az postgres server list
az postgres server show -g $rg -n $postgresServer --query id -otsv
```

## postgres.core.server.firewall

```
postgresId=$(az postgres server show -g $rg -n $postgresServer --query id -otsv)
az postgres server firewall-rule list --id $postgresId
```

## postgres.core.db

```
```

## postgres.ResourceProvider

```
postgresId=$(az postgres server show -g $rg -n $postgresServer --query id -otsv)
echo $postgresId
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.DBforPostgreSQL/servers/postgres29
```
