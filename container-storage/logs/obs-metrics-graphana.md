```
grafana="grafana$RANDOM$RANDOM"
az grafana create -g $rg -n $grafana
```

```
grafanaId=$(az grafana show -g $rg -n grafana --query id --output tsv); echo $grafanaId
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Dashboard/grafana/grafana1026

az grafana list -otable # -g $rg
```

- https://learn.microsoft.com/en-us/azure/managed-grafana/quickstart-managed-grafana-cli
