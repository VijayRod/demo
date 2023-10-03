Azure Log Analytics can be enabled by configuring monitoring either in the Insights section or the Logs section in the portal, or by using the following CLI command.

```
# Replace the below with appropriate values.
rgname=
clustername=akslogs
```

```
# To create a cluster
az aks enable-addons -a monitoring -g $rgname -n $clustername
```

```
# az aks show -g $rgname -n $clustername --query addonProfiles.omsagent
{
  "config": {
    "logAnalyticsWorkspaceResourceID": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/defaultresourcegroup-sec/providers/Microsoft.OperationalInsights/workspaces/defaultworkspace-dummys-1111-1111-1111-111111111111-sec",
    "useAADAuth": "true"
  },
  "enabled": true,
  "identity": null
}

clusterUri=$(az aks show -g $rg -n aks --query id -otsv)
az monitor diagnostic-settings list --resource $clusterUri
# az monitor diagnostic-settings list --resource-type Microsoft.ContainerService/managedClusters --resource a --resource-group $rg
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview
  - https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-onboard
    - https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-enable-aks?tabs=azure-cli
- https://learn.microsoft.com/en-us/azure/aks/monitor-aks-reference
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/monitor-kubernetes
