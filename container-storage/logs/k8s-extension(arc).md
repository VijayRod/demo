## k8s-extension

```
az k8s-extension show -g $rg --cluster-name aks2 --name azure-aks-backup --cluster-type managedClusters -otable
az k8s-extension delete -g $rg --cluster-name aks2 -n azure-aks-backup --cluster-type managedClusters -y
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions
- https://learn.microsoft.com/en-us/azure/aks/deploy-extensions-az-cli
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/extensions
- https://learn.microsoft.com/en-us/cli/azure/k8s-extension?view=azure-cli-latest

## k8s-extension.debug

- https://learn.microsoft.com/en-us/azure/architecture/hybrid/arc-hybrid-kubernetes#topology-network-and-routing: dp.kubernetesconfiguration.azure.com
- https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#cluster-extensions: dp.kubernetesconfiguration.azure.com...
