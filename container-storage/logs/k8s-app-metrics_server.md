
```
kubectl logs -n kube-system k8s-app=metrics-server
kubectl -n kube-system delete po -l k8s-app=metrics-server
```

```
# kubectl top po -n kube-system | grep metr
NAME                                  CPU(cores)   MEMORY(bytes)
metrics-server-5dd7f7965f-6srpn       3m           43Mi
metrics-server-5dd7f7965f-ng5hr       3m           47Mi
```

The metrics-server implements the Metrics API as indicated in https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/#metrics-api.
```
kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/default/pods/nginx

{"kind":"PodMetrics","apiVersion":"metrics.k8s.io/v1beta1","metadata":{"name":"nginx","namespace":"default","creationTimestamp":"2023-07-18T14:30:20Z","labels":{"run":"nginx"}},"timestamp":"2023-07-18T14:30:13Z","window":"26.279434112s","containers":[{"name":"nginx","usage":{"cpu":"1267873n","memory":"3136Ki"}}]}
```

```
kubectl get --raw /metrics
```

- https://learn.microsoft.com/en-us/azure/aks/use-metrics-server-vertical-pod-autoscaler
- https://kubernetes.io/docs/reference/instrumentation/metrics/#list-of-stable-kubernetes-metrics
- https://github.com/kubernetes-sigs/metrics-server

Here are some related links for AKS:
- [Container Insights metrics](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-analyze#view-container-metrics-in-metrics-explorer) - List of container metrics in Metrics Explorer
- [Essential metrics](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported#microsoftcontainerservicemanagedclusters) - Metrics supported for Microsoft Container Service Managed Clusters
