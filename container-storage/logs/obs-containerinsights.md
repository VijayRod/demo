```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksloganalytics -a monitoring -s $vmsize -c 1
az aks get-credentials -g $rg -n aksloganalytics --overwrite-existing

az aks enable-addons -a monitoring -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks show -g $rg -n aks --query addonProfiles.omsagent
{
  "config": {
    "logAnalyticsWorkspaceResourceID": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/defaultresourcegroup-sec/providers/Microsoft.OperationalInsights/workspaces/defaultworkspace-redacts-1111-1111-1111-111111111111-sec",
    "useAADAuth": "true"
  },
  "enabled": true,
  "identity": null
}

kubectl get ds -n kube-system | grep ama
ama-logs                     1         1         1       1            1           <none>          3m5s
ama-logs-windows             0         0         0       0            0           <none>          3m5s

kubectl get deploy -n kube-system | grep ama
ama-logs-rs                       1/1     1            1           3m17s

kubectl get po -n kube-system -l component=ama-logs-agent
```

- https://learn.microsoft.com/en-Us/azure/azure-monitor/containers/container-insights-enable-aks?tabs=azure-cli
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable: Container insights for log collection
