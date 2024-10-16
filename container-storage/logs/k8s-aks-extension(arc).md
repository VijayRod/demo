## k8s-aks-extension

```
az k8s-extension show -g $rg --cluster-name aks2 --name azure-aks-backup --cluster-type managedClusters -otable
az k8s-extension delete -g $rg --cluster-name aks2 -n azure-aks-backup --cluster-type managedClusters -y

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

### k8s-aks-extension.debug.provisioningState

```
# creating
az k8s-extension show -t managedClusters -g $rg -c aksdapr -n dapr
  "provisioningState": "Creating",
```

```
# failed
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

## k8s-aks-extension.app.backup

- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions#currently-available-extensions: Azure Backup for AKS
- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-manage-backups#install-backup-extension

## k8s-aks-extension.app.dapr

```
az group create -n $rg -l $loc
az aks create -g $rg -n aksdapr -s $vmsize -c 1
az aks get-credentials -g $rg -n aksdapr --overwrite-existing
az extension update --name k8s-extension
az k8s-extension create -t managedClusters -g $rg -c aksdapr -n dapr --extension-type Microsoft.Dapr --auto-upgrade-minor-version false

az k8s-extension show -t managedClusters -g $rg -c aksdapr -n dapr
{
  "aksAssignedIdentity": {
    "principalId": "4275cea9-c49c-4a04-85d7-a0e13051343d",
    "tenantId": null,
    "type": null
  },
  "autoUpgradeMinorVersion": false,
  "configurationProtectedSettings": {},
  "configurationSettings": {
    "global.clusterType": "managedclusters"
  },
  "currentVersion": "1.14.4-msft.5",
  "customLocationSettings": null,
  "errorInfo": null,
  "extensionType": "microsoft.dapr",
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerService/managedClusters/aksdapr/providers/Microsoft.KubernetesConfiguration/extensions/dapr",
  "identity": null,
  "isSystemExtension": false,
  "name": "dapr",
  "packageUri": null,
  "plan": null,
  "provisioningState": "Creating",
  "releaseTrain": "stable",
  "resourceGroup": "rg",
  "scope": {
    "cluster": {
      "releaseNamespace": "dapr-system"
    },
    "namespace": null
  },
  "statuses": [],
  "systemData": {
    "createdAt": "2024-10-15T21:33:32.273413+00:00",
    "createdBy": null,
    "createdByType": null,
    "lastModifiedAt": "2024-10-15T21:33:32.273413+00:00",
    "lastModifiedBy": null,
    "lastModifiedByType": null
  },
  "type": "Microsoft.KubernetesConfiguration/extensions",
  "version": "1.14.4-msft.5"
}
```
    
- https://learn.microsoft.com/en-us/azure/aks/dapr?tabs=cli
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-dapr-extension-installation-errors
- https://docs.dapr.io/operations/troubleshooting/common_issues/

### k8s-aks-extension.app.dapr.OSS

- https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-deploy/#install-dapr-from-an-official-dapr-helm-chart

## k8s-aks-extension.app.dapr.pods

```
k get po -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
dapr-system   dapr-monitoring-8j977                      3/3     Running   0          3m57s
dapr-system   dapr-monitoring-metrics-85f6df7d47-25g62   4/4     Running   0          3m57s
dapr-system   dapr-operator-855b94b888-dqztf             1/1     Running   0          3m57s
dapr-system   dapr-operator-855b94b888-vcgdl             1/1     Running   0          3m57s
dapr-system   dapr-operator-855b94b888-xzdkb             1/1     Running   0          3m57s
dapr-system   dapr-placement-server-0                    1/1     Running   0          3m56s
dapr-system   dapr-placement-server-1                    0/1     Pending   0          3m56s
dapr-system   dapr-placement-server-2                    0/1     Pending   0          3m56s
dapr-system   dapr-scheduler-server-0                    1/1     Running   0          3m56s
dapr-system   dapr-scheduler-server-1                    1/1     Running   0          3m56s
dapr-system   dapr-scheduler-server-2                    1/1     Running   0          3m56s
dapr-system   dapr-sentry-58bb88c8bb-bvpzc               1/1     Running   0          3m57s
dapr-system   dapr-sentry-58bb88c8bb-jz75f               1/1     Running   0          3m57s
dapr-system   dapr-sentry-58bb88c8bb-lfp9r               1/1     Running   0          3m57s
dapr-system   dapr-sidecar-injector-586558c8cb-4j2qn     1/1     Running   0          3m57s
dapr-system   dapr-sidecar-injector-586558c8cb-9zzsl     1/1     Running   0          3m57s
dapr-system   dapr-sidecar-injector-586558c8cb-ws56l     1/1     Running   0          3m57s
kube-system   extension-agent-7bc85fbfc5-qmbvt           2/2     Running   0          21m
kube-system   extension-operator-f5bdcf9d7-kddgc         2/2     Running   0          21m

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

```
k get all -n dapr-system --show-labels
NAME                                           READY   STATUS    RESTARTS   AGE     LABELS
pod/dapr-monitoring-8j977                      3/3     Running   0          8m54s   app.kubernetes.io/component=monitoring,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-monitoring,controller-revision-hash=5ddcb4dbc9,kubernetes.azure.com/managedby=aks,pod-template-generation=1
pod/dapr-monitoring-metrics-85f6df7d47-25g62   4/4     Running   0          8m54s   app.kubernetes.io/component=monitoring,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-monitoring-metrics,kubernetes.azure.com/managedby=aks,pod-template-hash=85f6df7d47
pod/dapr-operator-855b94b888-dqztf             1/1     Running   0          8m54s   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=855b94b888
pod/dapr-operator-855b94b888-vcgdl             1/1     Running   0          8m54s   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=855b94b888
pod/dapr-operator-855b94b888-xzdkb             1/1     Running   0          8m54s   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=855b94b888
pod/dapr-placement-server-0                    1/1     Running   0          8m53s   app.kubernetes.io/component=placement,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-placement-server,apps.kubernetes.io/pod-index=0,controller-revision-hash=dapr-placement-server-7976444757,kubernetes.azure.com/managedby=aks,statefulset.kubernetes.io/pod-name=dapr-placement-server-0
pod/dapr-placement-server-1                    0/1     Pending   0          8m53s   app.kubernetes.io/component=placement,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-placement-server,apps.kubernetes.io/pod-index=1,controller-revision-hash=dapr-placement-server-7976444757,kubernetes.azure.com/managedby=aks,statefulset.kubernetes.io/pod-name=dapr-placement-server-1
pod/dapr-placement-server-2                    0/1     Pending   0          8m53s   app.kubernetes.io/component=placement,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-placement-server,apps.kubernetes.io/pod-index=2,controller-revision-hash=dapr-placement-server-7976444757,kubernetes.azure.com/managedby=aks,statefulset.kubernetes.io/pod-name=dapr-placement-server-2
pod/dapr-scheduler-server-0                    1/1     Running   0          8m53s   app.kubernetes.io/component=scheduler,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-scheduler-server,apps.kubernetes.io/pod-index=0,controller-revision-hash=dapr-scheduler-server-5654b7d97b,kubernetes.azure.com/managedby=aks,statefulset.kubernetes.io/pod-name=dapr-scheduler-server-0
pod/dapr-scheduler-server-1                    1/1     Running   0          8m53s   app.kubernetes.io/component=scheduler,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-scheduler-server,apps.kubernetes.io/pod-index=1,controller-revision-hash=dapr-scheduler-server-5654b7d97b,kubernetes.azure.com/managedby=aks,statefulset.kubernetes.io/pod-name=dapr-scheduler-server-1
pod/dapr-scheduler-server-2                    1/1     Running   0          8m53s   app.kubernetes.io/component=scheduler,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-scheduler-server,apps.kubernetes.io/pod-index=2,controller-revision-hash=dapr-scheduler-server-5654b7d97b,kubernetes.azure.com/managedby=aks,statefulset.kubernetes.io/pod-name=dapr-scheduler-server-2
pod/dapr-sentry-58bb88c8bb-bvpzc               1/1     Running   0          8m54s   app.kubernetes.io/component=sentry,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sentry,kubernetes.azure.com/managedby=aks,pod-template-hash=58bb88c8bb
pod/dapr-sentry-58bb88c8bb-jz75f               1/1     Running   0          8m54s   app.kubernetes.io/component=sentry,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sentry,kubernetes.azure.com/managedby=aks,pod-template-hash=58bb88c8bb
pod/dapr-sentry-58bb88c8bb-lfp9r               1/1     Running   0          8m54s   app.kubernetes.io/component=sentry,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sentry,kubernetes.azure.com/managedby=aks,pod-template-hash=58bb88c8bb
pod/dapr-sidecar-injector-586558c8cb-4j2qn     1/1     Running   0          8m54s   app.kubernetes.io/component=sidecar-injector,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sidecar-injector,kubernetes.azure.com/managedby=aks,pod-template-hash=586558c8cb
pod/dapr-sidecar-injector-586558c8cb-9zzsl     1/1     Running   0          8m54s   app.kubernetes.io/component=sidecar-injector,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sidecar-injector,kubernetes.azure.com/managedby=aks,pod-template-hash=586558c8cb
pod/dapr-sidecar-injector-586558c8cb-ws56l     1/1     Running   0          8m54s   app.kubernetes.io/component=sidecar-injector,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sidecar-injector,kubernetes.azure.com/managedby=aks,pod-template-hash=586558c8cb

NAME                            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)
     AGE     LABELS
service/dapr-api                ClusterIP   10.0.57.71     <none>        443/TCP,80/TCP,9090/TCP
     8m55s   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,kubernetes.azure.com/managedby=aks
service/dapr-monitoring         ClusterIP   10.0.103.192   <none>        8130/TCP
     8m55s   app.kubernetes.io/managed-by=Helm,app=dapr-monitoring
service/dapr-placement-server   ClusterIP   None           <none>        50005/TCP,8201/TCP,9090/TCP
     8m55s   app.kubernetes.io/component=placement,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-placement-server,kubernetes.azure.com/managedby=aks
service/dapr-scheduler-server   ClusterIP   None           <none>        50006/TCP,2379/TCP,2330/TCP,2380/TCP,9090/TCP   8m55s   app.kubernetes.io/component=scheduler,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-scheduler-server,kubernetes.azure.com/managedby=aks
service/dapr-sentry             ClusterIP   10.0.204.89    <none>        443/TCP,9090/TCP
     8m55s   app.kubernetes.io/component=sentry,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,kubernetes.azure.com/managedby=aks
service/dapr-sidecar-injector   ClusterIP   10.0.127.60    <none>        443/TCP,9090/TCP
     8m55s   app.kubernetes.io/component=sidecar-injector,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,kubernetes.azure.com/managedby=aks
service/dapr-webhook            ClusterIP   10.0.241.56    <none>        443/TCP
     8m55s   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,kubernetes.azure.com/managedby=aks

NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE     LABELS
daemonset.apps/dapr-monitoring   1         1         1       1            1           <none>          8m55s   app.kubernetes.io/component=monitoring,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,kubernetes.azure.com/managedby=aks

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/dapr-monitoring-metrics   1/1     1            1           8m55s   app.kubernetes.io/component=monitoring,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-monitoring-metrics,kubernetes.azure.com/managedby=aks
deployment.apps/dapr-operator             3/3     3            3           8m55s   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-operator,kubernetes.azure.com/managedby=aks
deployment.apps/dapr-sentry               3/3     3            3           8m55s   app.kubernetes.io/component=sentry,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sentry,kubernetes.azure.com/managedby=aks
deployment.apps/dapr-sidecar-injector     3/3     3            3           8m55s   app.kubernetes.io/component=sidecar-injector,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sidecar-injector,kubernetes.azure.com/managedby=aks

NAME                                                 DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/dapr-monitoring-metrics-85f6df7d47   1         1         1       8m55s   app.kubernetes.io/component=monitoring,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-monitoring-metrics,kubernetes.azure.com/managedby=aks,pod-template-hash=85f6df7d47
replicaset.apps/dapr-operator-855b94b888             3         3         3       8m55s   app.kubernetes.io/component=operator,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=855b94b888
replicaset.apps/dapr-sentry-58bb88c8bb               3         3         3       8m55s   app.kubernetes.io/component=sentry,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sentry,kubernetes.azure.com/managedby=aks,pod-template-hash=58bb88c8bb
replicaset.apps/dapr-sidecar-injector-586558c8cb     3         3         3       8m55s   app.kubernetes.io/component=sidecar-injector,app.kubernetes.io/managed-by=helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-sidecar-injector,kubernetes.azure.com/managedby=aks,pod-template-hash=586558c8cb

NAME                                     READY   AGE     LABELS
statefulset.apps/dapr-placement-server   1/3     8m55s   app.kubernetes.io/component=placement,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-placement-server,kubernetes.azure.com/managedby=aks
statefulset.apps/dapr-scheduler-server   3/3     8m55s   app.kubernetes.io/component=scheduler,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dapr,app.kubernetes.io/part-of=dapr,app.kubernetes.io/version=1.14.4-msft.5,app=dapr-scheduler-server,kubernetes.azure.com/managedby=aks
```
