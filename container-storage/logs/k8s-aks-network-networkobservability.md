```
rg=rgnet
az group create -n $rg -l $loc # -l eastus, else LocationNotAvailableForResourceType for resource type 'Microsoft.Monitor/accounts
az aks create -g $rg -n aks --enable-network-observability -s $vmsize -c 1
# az aks update -g $rg -n aks --enable-network-observability
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks show -g $rg -n aks --query networkProfile.monitoring
{
  "enabled": true
}
```

```
grafana="grafana$RANDOM$RANDOM"
az resource create -g $rg -n monitor --namespace microsoft.monitor --resource-type accounts --properties '{}'
az grafana create -g $rg -n $grafana
grafanaId=$(az grafana show -g $rg -n grafana --query id --output tsv)
azuremonitorId=$(az resource show -g $rg -n monitor --resource-type "Microsoft.Monitor/accounts" --query id --output tsv)
az aks update -g $rg -n aks --enable-azure-monitor-metrics --azure-monitor-workspace-resource-id $azuremonitorId --grafana-resource-id $grafanaId
```

```
# az aks show -g $rg -n aks # The output does not include the azuremonitorId and grafanaId
kubectl get po -owide -n kube-system | grep ama- # azure-monitor-metrics. Note: There are no pods for Prometheus or Grafana.
```

- https://learn.microsoft.com/en-us/azure/aks/network-observability-managed-cli?tabs=non-cilium
