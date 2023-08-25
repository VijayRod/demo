```
az aks maintenanceconfiguration add -g $rgname --cluster-name $clustername -n default --weekday Monday --start-hour 1 --duration 5
```

```
az aks maintenanceconfiguration update -g $rgname --cluster-name $clustername -n default --weekday Monday --start-hour 2 --duration 5
az aks maintenanceconfiguration show -g $rgname --cluster-name $clustername -n default
az aks maintenanceconfiguration delete -g $rgname --cluster-name $clustername -n default

az aks maintenanceconfiguration list -g $rgname --cluster-name $clustername
az aks show -g $rgname -n $clustername --query autoUpgradeProfile # No rows
```

- https://azure.microsoft.com/id-id/updates/public-preview-planned-maintenance-windows-in-aks/
- https://learn.microsoft.com/en-us/azure/aks/planned-maintenance
