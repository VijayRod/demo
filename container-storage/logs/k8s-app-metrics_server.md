
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

```
id=$(az aks show -n $rg -g aks --query id -otsv)
az monitor metrics list-definitions --resource $id -otable
Display Name                                              Metric Name                                   Unit        Type     Dimension Required    Dimensions
--------------------------------------------------------  --------------------------------------------  ----------  -------  --------------------  --------------------------------
Inflight Requests                                         apiserver_current_inflight_requests           Count       Average  False                 requestKind
Cluster Health                                            cluster_autoscaler_cluster_safe_to_autoscale  Count       Average  False
Scale Down Cooldown                                       cluster_autoscaler_scale_down_in_cooldown     Count       Average  False
Unneeded Nodes                                            cluster_autoscaler_unneeded_nodes_count       Count       Average  False
Unschedulable Pods                                        cluster_autoscaler_unschedulable_pods_count   Count       Average  False
Total number of available cpu cores in a managed cluster  kube_node_status_allocatable_cpu_cores        Count       Average  False
Total amount of available memory in a managed cluster     kube_node_status_allocatable_memory_bytes     Bytes       Average  False
Number of pods in Ready state                             kube_pod_status_ready                         Count       Average  False                 namespace, pod, condition
Statuses for various node conditions                      kube_node_status_condition                    Count       Average  False                 condition, status, status2, node
Number of pods by phase                                   kube_pod_status_phase                         Count       Average  False                 phase, namespace, pod
CPU Usage Millicores                                      node_cpu_usage_millicores                     MilliCores  Average  False                 node, nodepool
CPU Usage Percentage                                      node_cpu_usage_percentage                     Percent     Average  False                 node, nodepool
Memory RSS Bytes                                          node_memory_rss_bytes                         Bytes       Average  False                 node, nodepool
Memory RSS Percentage                                     node_memory_rss_percentage                    Percent     Average  False                 node, nodepool
Memory Working Set Bytes                                  node_memory_working_set_bytes                 Bytes       Average  False                 node, nodepool
Memory Working Set Percentage                             node_memory_working_set_percentage            Percent     Average  False                 node, nodepool
Disk Used Bytes                                           node_disk_usage_bytes                         Bytes       Average  False                 node, nodepool, device
Disk Used Percentage                                      node_disk_usage_percentage                    Percent     Average  False                 node, nodepool, device
Network In Bytes                                          node_network_in_bytes                         Bytes       Average  False                 node, nodepool
Network Out Bytes                                         node_network_out_bytes                        Bytes       Average  False                 node, nodepool
# az monitor metrics list --resource $id --metric 'apiserver_current_inflight_requests' --aggregation Total --interval PT1M --start-time 2023-09-18T10:00:00Z --end-time 2023-09-18T12:00:00Z -otable
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
