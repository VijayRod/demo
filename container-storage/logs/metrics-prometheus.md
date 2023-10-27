```
az resource create -g $rg -n myAzureMonitor --namespace microsoft.monitor --resource-type accounts --properties '{}'
```

```
azuremonitorId=$(az resource show -g $rg -n myAzureMonitor --resource-type "Microsoft.Monitor/accounts" --query id --output tsv)
/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rg/providers/microsoft.monitor/accounts/myazuremonitor

az resource show -g $rg -n myAzureMonitor --resource-type "Microsoft.Monitor/accounts" --query properties.metrics.prometheusQueryEndpoint --output tsv
https://myazuremonitor-d3dp.eastus.prometheus.monitor.azure.com
```

- https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/: Kubernetes components emit metrics in Prometheus format
- https://learn.microsoft.com/en-Us/azure/azure-monitor/essentials/prometheus-metrics-overview
- https://prometheus.io/docs/introduction/overview/
