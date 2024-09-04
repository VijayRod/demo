```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksretina -s $vmsize

az resource create -g $rg --namespace microsoft.monitor --resource-type accounts --name myAzureMonitor --properties '{}'
azuremonitorId=$(az resource show -g $rg -n myAzureMonitor --resource-type "Microsoft.Monitor/accounts" --query id --output tsv)
grafana="myGrafana$RANDOM"
az grafana create -g $rg -n $grafana
grafanaId=$(az grafana show -g $rg -n $grafana --query id --output tsv)
az aks update -g $rg -n aksretina --enable-azure-monitor-metrics --azure-monitor-workspace-resource-id $azuremonitorId --grafana-resource-id $grafanaId

az aks get-credentials -g $rg -n aksretina --overwrite-existing
```

```
az aks show -g $rg -n aksretina --query azureMonitorProfile
{
  "appMonitoring": null,
  "containerInsights": null,
  "metrics": {
    "enabled": true,
    "kubeStateMetrics": {
      "metricAnnotationsAllowList": "",
      "metricLabelsAllowlist": ""
    }
  }
}
```

- https://learn.microsoft.com/en-us/azure/aks/network-observability-managed-cli?#azure-managed-prometheus-and-grafana
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable: Managed Prometheus for metric collection. Managed Grafana for visualization.
