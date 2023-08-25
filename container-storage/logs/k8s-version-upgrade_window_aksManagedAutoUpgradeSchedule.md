```
az aks maintenanceconfiguration add -g $rgname --cluster-name $clustername -n aksManagedAutoUpgradeSchedule --schedule-type Weekly --interval-weeks 1 --day-of-week Monday --start-time 01:00
--duration 5
```

```
az aks maintenanceconfiguration update -g $rgname --cluster-name $clustername -n aksManagedAutoUpgradeSchedule --schedule-type Weekly --interval-weeks 1 --day-of-week Monday --start-time 02:00 --duration 5
az aks maintenanceconfiguration show -g $rgname --cluster-name $clustername -n aksManagedAutoUpgradeSchedule
az aks maintenanceconfiguration delete -g $rgname --cluster-name $clustername -n aksManagedAutoUpgradeSchedule

az aks maintenanceconfiguration list -g $rgname --cluster-name $clustername
az aks show -g $rgname -n $clustername --query autoUpgradeProfile # No rows
```
