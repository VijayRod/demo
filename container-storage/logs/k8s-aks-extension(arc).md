## k8s-aks-extension

```
az k8s-extension show -g $rg --cluster-name aks2 --name azure-aks-backup --cluster-type managedClusters -otable
az k8s-extension delete -g $rg --cluster-name aks2 -n azure-aks-backup --cluster-type managedClusters -y
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions
- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions#currently-available-extensions
- https://learn.microsoft.com/en-us/azure/aks/deploy-extensions-az-cli
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/extensions
- https://learn.microsoft.com/en-us/cli/azure/k8s-extension?view=azure-cli-latest

### k8s-aks-extension.debug

- https://learn.microsoft.com/en-us/azure/architecture/hybrid/arc-hybrid-kubernetes#topology-network-and-routing: dp.kubernetesconfiguration.azure.com
- https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#cluster-extensions: dp.kubernetesconfiguration.azure.com...

## k8s-aks-extension.app.dapr

```
k describe po
Name:           dapr-monitoring-metrics-664f8745bf
Namespace:      dapr-system
Selector:       app=dapr-monitoring-metrics,pod-template-hash=664f8745bf
Labels:         app=dapr-monitoring-metrics
                app.kubernetes.io/component=monitoring
                app.kubernetes.io/managed-by=helm
                app.kubernetes.io/name=dapr
                app.kubernetes.io/part-of=dapr
                app.kubernetes.io/version=1.14.4-msft.5
                kubernetes.azure.com/managedby=aks
    Image:      mcr.microsoft.com/daprio/
```
    
- https://learn.microsoft.com/en-us/azure/aks/dapr?tabs=cli
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-dapr-extension-installation-errors
- https://docs.dapr.io/operations/troubleshooting/common_issues/

## k8s-aks-extension.app.dapr.OSS

- https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-deploy/#install-dapr-from-an-official-dapr-helm-chart
