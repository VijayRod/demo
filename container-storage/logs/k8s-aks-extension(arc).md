## k8s-aks-extension

```
az k8s-extension list -g $rg -c aks-dapr --cluster-type managedClusters
az k8s-extension show -g $rg --cluster-name aks2 --name azure-aks-backup --cluster-type managedClusters -otable

k get po -n kube-system --show-labels | grep ext
kube-system   extension-agent-7bc85fbfc5-qmbvt           2/2     Running   0          24m     app.kubernetes.io/component=extension-agent,app.kubernetes.io/name=extension-manager,control-plane=extension-agent,kubernetes.azure.com/managedby=aks,pod-template-hash=7bc85fbfc5
kube-system   extension-operator-f5bdcf9d7-kddgc         2/2     Running   0          24m     app.kubernetes.io/component=extension-operator,app.kubernetes.io/name=extension-manager,control-plane=extension-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=f5bdcf9d7

k describe po -n kube-system -l app.kubernetes.io/component=extension-agent
    Image:          mcr.microsoft.com/azurearck8s/aks/stable/config-agent:1.20.1
    Image:          mcr.microsoft.com/azurearck8s/aks/stable/fluent-bit-collector:1.20.1
    
k describe po -n kube-system -l app.kubernetes.io/component=extension-operator
    Image:          mcr.microsoft.com/azurearck8s/aks/stable/extensionoperator:1.20.1
    Image:          mcr.microsoft.com/azurearck8s/aks/stable/fluent-bit-collector:1.20.1
```

```
k get all -n kube-system --show-labels | grep ext
pod/extension-agent-5f58b9c69d-swjmr      2/2     Running   0          46s     app.kubernetes.io/component=extension-agent,app.kubernetes.io/name=extension-manager,control-plane=extension-agent,kubernetes.azure.com/managedby=aks,pod-template-hash=5f58b9c69d
pod/extension-operator-64b9bdd474-gvrpm   2/2     Running   0          46s     app.kubernetes.io/component=extension-operator,app.kubernetes.io/name=extension-manager,control-plane=extension-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=64b9bdd474
service/extension-agent-metrics-service      ClusterIP   10.0.104.142   <none>        8443/TCP        52s     addonmanager.kubernetes.io/mode=Reconcile,app.kubernetes.io/component=extension-agent,app.kubernetes.io/name=extension-manager
service/extension-operator-metrics-service   ClusterIP   10.0.33.222    <none>        8443/TCP        52s     addonmanager.kubernetes.io/mode=Reconcile,app.kubernetes.io/component=extension-operator,app.kubernetes.io/name=extension-manager
deployment.apps/extension-agent      1/1     1            1           52s     addonmanager.kubernetes.io/mode=Reconcile,app.kubernetes.io/name=extension-agent,kubernetes.azure.com/managedby=aks
deployment.apps/extension-operator   1/1     1            1           52s     addonmanager.kubernetes.io/mode=Reconcile,app.kubernetes.io/component=extension-operator,app.kubernetes.io/name=extension-manager,kubernetes.azure.com/managedby=aks
replicaset.apps/extension-agent-5f58b9c69d      1         1         1       47s     app.kubernetes.io/component=extension-agent,app.kubernetes.io/name=extension-manager,control-plane=extension-agent,kubernetes.azure.com/managedby=aks,pod-template-hash=5f58b9c69d
replicaset.apps/extension-operator-64b9bdd474   1         1         1       47s     app.kubernetes.io/component=extension-operator,app.kubernetes.io/name=extension-manager,control-plane=extension-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=64b9bdd474
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions
- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions#currently-available-extensions
- https://learn.microsoft.com/en-us/azure/aks/deploy-extensions-az-cli
- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/extensions
- https://learn.microsoft.com/en-us/cli/azure/k8s-extension?view=azure-cli-latest

### k8s-aks-extension.debug

- https://learn.microsoft.com/en-us/azure/architecture/hybrid/arc-hybrid-kubernetes#topology-network-and-routing: dp.kubernetesconfiguration.azure.com
- https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#cluster-extensions: dp.kubernetesconfiguration.azure.com...
- https://aka.ms/k8s-extensions-TSG
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/cluster-extension-deployment-errors
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/extension-resource-types#microsoftkubernetesconfiguration

```
# op.delete
az k8s-extension delete -g $rg --cluster-name aks2 -n azure-aks-backup --cluster-type managedClusters -y

# force delete
# az k8s-configuration flux delete -g $rg -c aks-dapr -t managedClusters -n cluster --force
az k8s-extension delete -g $rg -c aks-dapr --cluster-type managedClusters --name myextension --force
```

- https://learn.microsoft.com/en-us/cli/azure/k8s-extension?view=azure-cli-latest#az-k8s-extension-delete

```
# op.reconcile

k patch deploy -n kube-system extension-operator --type=json -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/memory", "value": "500Mi"}]'
# k edit deploy -n kube-system extension-operator
k describe deploy -n kube-system extension-operator | grep Limits -C 5 # the value reverts within a a minute as expected
# az aks update -g $rg -n aks # reconcile
```

```
# k8s-aks-extension.debug.provisioningState.creating

az k8s-extension show -t managedClusters -g $rg -c aksdapr -n dapr
  "provisioningState": "Creating",
```

```
# k8s-aks-extension.debug.provisioningState.failed

az k8s-extension list -g $rg -c aks-dapr --cluster-type managedClusters # shows failures etc. for all arc extensions
az k8s-extension show -t managedClusters -g $rg -c aksdapr -n dapr
  "provisioningState": "Failed",
  "statuses": [
    {
      "code": "InstallationFailed",
      "displayStatus": null,
      "level": null,
      "message": "Error: [ InnerError: [Helm installation failed :  : InnerError [release dapr failed, and has been uninstalled due to atomic being set: context deadline exceeded]]] occurred while doing the operation : [Create] on the config, For general troubleshooting visit: https://aka.ms/k8s-extensions-TSG, For more application specific troubleshooting visit: For additional troubleshooting information, please see https://aka.ms/dapr-aks",
      "time": null
    }
  ],
  "systemData": {
    "createdAt": "2024-10-15T21:33:32.273413+00:00",
    "createdBy": null,
    "createdByType": null,
    "lastModifiedAt": "2024-10-15T21:33:32.273413+00:00",

k logs -n kube-system extension-operator-f5bdcf9d7-kddgc
{"Message":"StatefulSet is not ready: dapr-system/dapr-scheduler-server. 0 out of 3 expected pods are ready","LogType":"ConfigAgentTrace","LogLevel":"Information","Environment":"prod","Role":"ClusterConfigAgent","Location":"swedencentral","ArmId":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerService/managedclusters/aksdapr/providers/Microsoft.KubernetesConfiguration/extensions/dapr","CorrelationId":"b4fd574e-f47f-48d6-8706-de2b367a75f3","AgentName":"ExtensionController microsoft.dapr:1.14.4-msft.5","AgentVersion":"1.20.1","AgentTimestamp":"2024/10/15 22:11:33.848"}
```

## k8s-aks-extension.app

```
# See the section on azurebackup, azureml, 
```
