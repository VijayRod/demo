- https://learn.microsoft.com/en-Us/azure/azure-monitor/containers/prometheus-metrics-enable?tabs=azure-portal
- https://github.com/Azure/AKS/issues/4508: Retina-agent will be installed on clusters with ama-metrics and k8s versions >= 1.29
- https://learn.microsoft.com/en-us/azure/aks/container-network-observability-guide#retina-oss
- https://retina.sh/
- https://github.com/microsoft/retina
- https://github.com/microsoft/retina/discussions
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview: See Enable monitoring for Kubernetes clusters to enable Managed Prometheus and Container Insights on your cluster.
- https://learn.microsoft.com/en-us/azure/aks/monitor-aks: Enable monitoring for Kubernetes clusters - Azure Monitor
- https://github.com/Azure/prometheus-collector/blob/main/otelcollector/configmaps/ama-metrics-settings-configmap.yaml:   default-scrape-settings-enabled: |-    networkobservabilityRetina = true
- https://github.com/Azure/prometheus-collector/blob/main/otelcollector/deploy/retina/custom-files/network-observability-service.yaml

```
rg=rgmetrics
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-azure-monitor-metrics -s $vmsize
# az aks update -g $rg -n aks --enable-azure-monitor-metrics
az aks get-credentials -g $rg -n aks --overwrite-existing

# az aks update -g $rg -n aksretinatest --disable-azure-monitor-metrics
  "azureMonitorProfile": {
    "appMonitoring": null,
    "containerInsights": null,
    "metrics": {
      "enabled": false,
      "kubeStateMetrics": null
    }
  },
```

```
az aks show -g $rg -n aks --query azureMonitorProfile # Earlier value "azureMonitorProfile": null,
{
  "logs": null,
  "metrics": {
    "appMonitoringOpenTelemetryMetrics": null,
    "enabled": true,
    "kubeStateMetrics": {
      "metricAnnotationsAllowList": "",
      "metricLabelsAllowlist": ""
    }
  }
}

kubectl get po -owide -n kube-system --show-labels | grep ama-
ama-metrics-74c6b986c6-6z5nx                   2/2     Running   0               4m58s   10.244.1.10   aks-nodepool1-15264917-vmss000002   <none>           <none>            kubernetes.azure.com/managedby=aks,pod-template-hash=74c6b986c6,rsName=ama-metrics
ama-metrics-74c6b986c6-xl79q                   2/2     Running   0               4m58s   10.244.2.4    aks-nodepool1-15264917-vmss000000   <none>           <none>            kubernetes.azure.com/managedby=aks,pod-template-hash=74c6b986c6,rsName=ama-metrics
ama-metrics-ksm-b699d5cfc-8nfgx                1/1     Running   0               4m58s   10.244.2.3    aks-nodepool1-15264917-vmss000000   <none>           <none>            app.kubernetes.io/component=ama-metrics,app.kubernetes.io/name=ama-metrics-ksm,app.kubernetes.io/part-of=ama-metrics-ksm,app.kubernetes.io/version=2.12.0,helm.sh/chart=azure-monitor-metrics-addon-0.1.0,kubernetes.azure.com/managedby=aks,pod-template-hash=b699d5cfc
ama-metrics-node-gs9q4                         2/2     Running   0               4m59s   10.244.0.5    aks-nodepool1-15264917-vmss000001   <none>           <none>            controller-revision-hash=c4f5858b8,dsName=ama-metrics-node,kubernetes.azure.com/managedby=aks,pod-template-generation=1
ama-metrics-node-v4dcq                         2/2     Running   0               4m59s   10.244.2.2    aks-nodepool1-15264917-vmss000000   <none>           <none>            controller-revision-hash=c4f5858b8,dsName=ama-metrics-node,kubernetes.azure.com/managedby=aks,pod-template-generation=1
ama-metrics-node-vzg6s                         2/2     Running   0               4m59s   10.244.1.8    aks-nodepool1-15264917-vmss000002   <none>           <none>            controller-revision-hash=c4f5858b8,dsName=ama-metrics-node,kubernetes.azure.com/managedby=aks,pod-template-generation=1
ama-metrics-operator-targets-cc79466d5-vprng   2/2     Running   2 (4m42s ago)   4m58s   10.244.1.9    aks-nodepool1-15264917-vmss000002   <none>           <none>            kubernetes.azure.com/managedby=aks,pod-template-hash=cc79466d5,rsName=ama-metrics-operator-targets

kubectl get po -owide -n kube-system --show-labels | grep retina
retina-agent-7nhjt                             1/1     Running   0              5m27s   10.224.0.5    aks-nodepool1-15264917-vmss000002   <none>           <none>            controller-revision-hash=5cc484797f,k8s-app=retina,kubernetes.azure.com/managedby=aks,pod-template-generation=1
retina-agent-cmtfp                             1/1     Running   0              5m27s   10.224.0.6    aks-nodepool1-15264917-vmss000001   <none>           <none>            controller-revision-hash=5cc484797f,k8s-app=retina,kubernetes.azure.com/managedby=aks,pod-template-generation=1
retina-agent-vjjvx                             1/1     Running   0              5m27s   10.224.0.4    aks-nodepool1-15264917-vmss000000   <none>           <none>            controller-revision-hash=5cc484797f,k8s-app=retina,kubernetes.azure.com/managedby=aks,pod-template-generation=1

kubectl describe po -n kube-system -l rsName=ama-metrics | grep Image
kubectl describe po -n kube-system -l dsName=ama-metrics-node | grep Image
    Image:          mcr.microsoft.com/azuremonitor/containerinsights/ciprod/prometheus-collector/images:6.9.0-main-07-22-2024-2e3dfb56
    Image:         mcr.microsoft.com/aks/msi/addon-token-adapter:master.240510.2
    Image:          mcr.microsoft.com/azuremonitor/containerinsights/ciprod/prometheus-collector/images:6.9.0-main-07-22-2024-2e3dfb56

    Image:          mcr.microsoft.com/azuremonitor/containerinsights/ciprod/prometheus-collector/images:6.9.0-main-07-22-2024-2e3dfb56
    Image:         mcr.microsoft.com/aks/msi/addon-token-adapter:master.240510.2

# Previously (updated to k8s-app=retina)
kubectl get all -n kube-system -l k8s-app=kappie
NAME                     READY   STATUS    RESTARTS   AGE
pod/kappie-agent-79xs9   1/1     Running   0          87m
NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)     AGE
service/kappie-svc   ClusterIP   10.0.122.54   <none>        10093/TCP   87m
NAME                          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/kappie-agent   1         1         1       1            1           <none>          87m

kubectl get all -n kube-system -l k8s-app=retina
kubectl describe po -n kube-system -l k8s-app=retina | grep Image
NAME                     READY   STATUS    RESTARTS   AGE
pod/retina-agent-zhr6d   1/1     Running   0          8m7s
NAME                          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/retina-agent   1         1         1       1            1           <none>          8m8s
    Image:          mcr.microsoft.com/containernetworking/kappie-init:v0.1.4
    Image:         mcr.microsoft.com/containernetworking/kappie-agent:v0.1.4
```

```
k describe cm -n kube-system retina-config
Name:         retina-config
Namespace:    kube-system
Labels:       app.kubernetes.io/managed-by=Helm
              helm.toolkit.fluxcd.io/name=kappie-adapter-helmrelease
              helm.toolkit.fluxcd.io/namespace=6899dce2794f950001146d7a
Annotations:  meta.helm.sh/release-name: aks-managed-kappie
              meta.helm.sh/release-namespace: kube-system
Data
====
config.yaml:
----
apiServer:
  host: "0.0.0.0"
  port: 10093
logLevel: info
enabledPlugin: ["dropreason","packetforward","linuxutil"]
metricsInterval: 10
enableTelemetry: true
enablePodLevel: false
enableAnnotations: false
bypassLookupIPOfInterest: true
dataAggregationLevel: "high"
BinaryData
====
Events:  <none>


k describe cm -n kube-system retina-config-win
Name:         retina-config-win
Namespace:    kube-system
Labels:       app.kubernetes.io/managed-by=Helm
              helm.toolkit.fluxcd.io/name=kappie-adapter-helmrelease
              helm.toolkit.fluxcd.io/namespace=6899dce2794f950001146d7a
Annotations:  meta.helm.sh/release-name: aks-managed-kappie
              meta.helm.sh/release-namespace: kube-system
Data
====
config.yaml:
----
apiServer:
  host: "0.0.0.0"
  port: 10093
logLevel: info
enabledPlugin: ["hnsstats"]
metricsInterval: 10
enableAnnotations: false
enablePodLevel: false
enableTelemetry: true
bypassLookupIPOfInterest: true
BinaryData
====
Events:  <none>

k describe cm -n kube-system ama-metrics-settings-configmap
Error from server (NotFound): configmaps "ama-metrics-settings-configmap" not found

k describe svc -n kube-system network-observability
Name:                     network-observability
Namespace:                kube-system
Labels:                   app.kubernetes.io/managed-by=Helm
                          helm.toolkit.fluxcd.io/name=kappie-adapter-helmrelease
                          helm.toolkit.fluxcd.io/namespace=6899dce2794f950001146d7a
Annotations:              meta.helm.sh/release-name: aks-managed-kappie
                          meta.helm.sh/release-namespace: kube-system
Selector:                 <none>
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.0.241.189
IPs:                      10.0.241.189
Port:                     retina  10093/TCP
TargetPort:               10093/TCP
Endpoints:                <none>
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
```

```
# https://learn.microsoft.com/en-us/azure/aks/network-observability-managed-cli?tabs=cilium
kubectl port-forward -n kube-system $(kubectl get po -n kube-system -l rsName=ama-metrics -oname | head -n 1) 9090:9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
# The webpage http://127.0.0.1:9090/targets has an endpoint status UP and provides information about the Last Scrape, Scrape Duration, Error if present.
```

```
kubectl run nginx --image=nginx
kubectl exec -it nginx -- curl curl http://ama-metrics-ksm.kube-system.svc.cluster.local:8080/metrics
curl: (6) Could not resolve host: curl
# HELP kube_certificatesigningrequest_annotations Kubernetes annotations converted to Prometheus labels.
# TYPE kube_certificatesigningrequest_annotations gauge
# HELP kube_certificatesigningrequest_labels [STABLE] Kubernetes labels converted to Prometheus labels.
# TYPE kube_certificatesigningrequest_labels gauge
# HELP kube_certificatesigningrequest_created [STABLE] Unix creation timestamp
# TYPE kube_certificatesigningrequest_created gauge
# HELP kube_certificatesigningrequest_condition [STABLE] The number of each certificatesigningrequest condition
# TYPE kube_certificatesigningrequest_condition gauge
# HELP kube_certificatesigningrequest_cert_length [STABLE] Length of the issued cert
# TYPE kube_certificatesigningrequest_cert_length gauge
# HELP kube_configmap_annotations Kubernetes annotations converted to Prometheus labels.
# TYPE kube_configmap_annotations gauge
kube_configmap_annotations{namespace="default",configmap="kube-root-ca.crt"} 1
...
```


