> See the section on k8s-pv, k8s-csi and k8s-pod_state_ExitCode

## k8s.apiserver

> Refer to apiserver

> ## k8s.apiserver.memory.cache

> See the section on etcd

- https://kubernetes.io/blog/2016/03/1000-nodes-and-beyond-updates-to-kubernetes-performance-and-scalability-in-12/: the API server’s clients can read data from an in-memory cache in the API server instead of reading it from etcd. The cache is updated directly from etcd via watch in the background. Those clients that can tolerate latency in retrieving data (usually the lag of cache is on the order of tens of milliseconds) can be served entirely from cache, reducing the load on etcd and increasing the throughput of the server.
- https://learn.microsoft.com/en-us/azure/aks/best-practices-performance-scale-large#aks-and-kubernetes-control-plane-scalability: While AKS optimizes the Kubernetes control plane and its components for scalability and performance, it's still bound by the upstream project limits.
- https://learn.microsoft.com/en-us/azure/aks/best-practices-performance-scale-large#kubernetes-clients: The load on etcd and API server primarily relies on the number of objects that exist...
- https://learn.microsoft.com/en-us/azure/aks/control-plane-metrics-monitor#query-control-plane-metrics: https://grafana.com/grafana/dashboards/20330-kubernetes-etcd/. 
- https://learn.microsoft.com/en-us/azure/aks/control-plane-metrics-monitor#customize-control-plane-metrics: default controlplane-etcd = true
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-apiserver-etcd?tabs=resource-specific
- https://kubernetes.io/blog/2024/12/17/kube-apiserver-api-streaming/: A significant challenge with large clusters is the memory overhead caused by list requests. This situation poses a genuine risk, potentially overwhelming and crashing any kube-apiserver within seconds due to out-of-memory (OOM) conditions.
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/aks-at-scale-troubleshoot-guide

> ## k8s.apiserver.burst

- https://kubernetes.io/docs/concepts/cluster-administration/flow-control/: Within a priority level, a fair-queuing algorithm prevents requests from different flows from starving each other, and allows for requests to be queued to prevent bursty traffic from causing failed requests when the average load is acceptably low.
- https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/: --kube-api-burst int32     Default: 100. Burst to use while talking with kubernetes API server. --kube-api-qps int32     Default: 50

> ## k8s.apiserver.burst.ACI

- https://learn.microsoft.com/en-us/azure/aks/concepts-scale#burst-to-azure-container-instances-aci
- https://www.linkedin.com/pulse/power-burst-scaling-azure-kubernetes-services-rohan-vekaria: scale with Virtual Nodes and Azure Container Instances.
- https://azure.github.io/aks-advanced-autoscaling/modules/Module3/: Module 3 - Rapid Burst Scaling with ACI and Azure Load Testing

## k8s.etcd

```
# See the section on apiserver
```

- https://kubernetes.io/docs/concepts/overview/components/#control-plane-components
- https://kubernetes.io/docs/concepts/architecture/#etcd
- https://etcd.io/docs/v3.3/learning/
- https://etcd.io/docs/v3.4/op-guide/clustering/: Starting an etcd cluster statically requires that each member knows another in the cluster.
- https://etcd.io/docs/v3.4/faq/#do-clients-have-to-send-requests-to-the-etcd-leader: Raft is leader-based; the leader handles all client requests which need cluster consensus. However, the client does not need to know which node is the leader. Any request that requires consensus sent to a follower is automatically forwarded to the leader. Requests that do not require consensus (e.g., serialized reads) can be processed by any cluster member.
- https://learn.microsoft.com/en-us/azure/aks/best-practices-performance-scale-large#kubernetes-clients: etcd
- https://learn.microsoft.com/en-us/azure/aks/control-plane-metrics-monitor#query-control-plane-metrics: etcd
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-apiserver-etcd?tabs=resource-specific
- https://etcd.io/docs/v3.4/op-guide/maintenance/

```
# etcd.perf
```

- https://etcd.io/docs/v3.4/faq/#system-requirements
- https://etcd.io/docs/v3.4/faq/#how-should-i-benchmark-etcd
- https://etcd.io/docs/v3.4/op-guide/performance/
- https://openai.com/index/scaling-kubernetes-to-2500-nodes/: etcd

```
# etcd.perf.error.etcdserver: apply entries took too long
# W | etcdserver: apply entries took too long [223.489001ms for 2 entries]
# See the section on "etcdserver: too many requests"
```

- https://etcd.io/docs/v3.4/faq/#what-does-the-etcd-warning-apply-entries-took-too-long-mean
  
```
# etcd.perf.error.etcdserver: too many requests
```

- https://github.com/etcd-io/etcd/issues/8576: etcdserver: too many requests. Probably you need to figure out what the expensive operators are by querying metrics.
 
```
# k8s.etcd.space
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-apiserver-etcd?tabs=resource-specific#cause-2-an-offending-client-leaks-etcd-objects-and-results-in-a-slowdown-of-etcd
- https://github.com/Azure/aks-engine/blob/master/examples/largeclusters/README.md: The current recommended maximum for etcd's storage size limit is 8GB
- https://etcd.io/docs/v3.3/dev-guide/limit/#storage-size-limit: The default storage size limit is 2GB, configurable with --quota-backend-bytes flag. 8GB is a suggested maximum size for normal environments and etcd warns at startup if the configured value exceeds it.
- https://aws.amazon.com/blogs/containers/managing-etcd-database-size-on-amazon-eks-clusters/

```
# k8s.etcd.space.error.mvcc: database space exceeded
```

- https://etcd.io/docs/v3.4/faq/#what-does-mvcc-database-space-exceeded-mean-and-how-do-i-fix-it

## k8s.etcd.space.kyverno

- https://kyverno.io/docs/troubleshooting/#admission-reports-are-stacking-up
- https://github.com/kyverno/kyverno/blob/main/docs/dev/troubleshooting/reports.md
- https://github.com/kyverno/KDP/pull/51
