```
rg=rgmetrics
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-azure-monitor-metrics -s $vmsize -c 1
# az aks update -g $rg -n aks --enable-azure-monitor-metrics
az aks get-credentials -g $rg -n aks --overwrite-existing
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
ama-logs-67x56                        3/3     Running   0          29m   10.244.0.11   aks-nodepool1-24057285-vmss000000   <none>           <none>            component=ama-logs-agent,controller-revision-hash=6c47677c5b,kubernetes.azure.com/managedby=aks,pod-template-generation=1,tier=node
ama-logs-rs-7fdd98d6dc-xl85n          2/2     Running   0          29m   10.244.0.12   aks-nodepool1-24057285-vmss000000   <none>           <none>            kubernetes.azure.com/managedby=aks,pod-template-hash=7fdd98d6dc,rsName=ama-logs-rs
ama-metrics-5c8b5569bb-2fw72          2/2     Running   0          26m   10.244.0.14   aks-nodepool1-24057285-vmss000000   <none>           <none>            kubernetes.azure.com/managedby=aks,pod-template-hash=5c8b5569bb,rsName=ama-metrics
ama-metrics-ksm-9fcd9bbf4-6bl6p       1/1     Running   0          26m   10.244.0.15   aks-nodepool1-24057285-vmss000000   <none>           <none>            app.kubernetes.io/component=ama-metrics,app.kubernetes.io/name=ama-metrics-ksm,app.kubernetes.io/part-of=ama-metrics-ksm,app.kubernetes.io/version=2.9.2,helm.sh/chart=azure-monitor-metrics-addon-0.1.0,pod-template-hash=9fcd9bbf4
ama-metrics-node-m8t5p                2/2     Running   0          26m   10.244.0.13   aks-nodepool1-24057285-vmss000000   <none>           <none>            controller-revision-hash=7cc8f96456,dsName=ama-metrics-node,kubernetes.azure.com/managedby=aks,pod-template-generation=1

kubectl get po -owide -n kube-system --show-labels | grep kappie
kappie-agent-79xs9                    1/1     Running   0          830m   10.224.0.4    aks-nodepool1-99125487-vmss000000   <none>           <none>            controller-revision-hash=79f6d8ccc5,k8s-app=kappie,pod-template-generation=1

kubectl get all -n kube-system -l component=ama-logs-agent
NAME                 READY   STATUS    RESTARTS   AGE
pod/ama-logs-26vns   3/3     Running   0          82m

NAME                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/ama-logs   1         1         1       1            1           <none>          82m

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ama-logs-rs   1/1     1            1           82m

kubectl get all -n kube-system -l rsName=ama-logs-rs
NAME                               READY   STATUS    RESTARTS   AGE
pod/ama-logs-rs-5cdd468cf4-nwgcw   2/2     Running   0          82m

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/ama-logs-rs-5cdd468cf4   1         1         1       82m

kubectl get all -n kube-system -l rsName=ama-metrics
NAME                               READY   STATUS    RESTARTS   AGE
pod/ama-metrics-5d5976ffc8-fjtrv   2/2     Running   0          79m

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/ama-metrics-5d5976ffc8   1         1         1       79m

kubectl get all -n kube-system -l app.kubernetes.io/component=ama-metrics
NAME                                  READY   STATUS    RESTARTS   AGE
pod/ama-metrics-ksm-9fcd9bbf4-vwjsw   1/1     Running   0          80m

NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/ama-metrics-ksm   ClusterIP   10.0.135.169   <none>        8080/TCP   80m

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ama-metrics-ksm   1/1     1            1           80m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/ama-metrics-ksm-9fcd9bbf4   1         1         1       80m

kubectl get all -n kube-system -l dsName=ama-metrics-node
NAME                         READY   STATUS    RESTARTS   AGE
pod/ama-metrics-node-8pktk   2/2     Running   0          80m

kubectl get all -n kube-system -l k8s-app=kappie
NAME                     READY   STATUS    RESTARTS   AGE
pod/kappie-agent-79xs9   1/1     Running   0          87m

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)     AGE
service/kappie-svc   ClusterIP   10.0.122.54   <none>        10093/TCP   87m

NAME                          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/kappie-agent   1         1         1       1            1           <none>          87m

az aks update -g $rg -n aks --disable-azure-monitor-metrics
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

- https://learn.microsoft.com/en-Us/azure/azure-monitor/containers/prometheus-metrics-enable?tabs=azure-portal
