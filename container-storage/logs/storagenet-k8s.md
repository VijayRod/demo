```
# See the section on k8s-pv, k8s-csi and k8s-pod_state_ExitCode
```

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
