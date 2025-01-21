```
# See the section on k8s-pv, k8s-csi and k8s-pod_state_ExitCode
```

## k8s.etcd

- https://kubernetes.io/docs/concepts/overview/components/#control-plane-components
- https://kubernetes.io/docs/concepts/architecture/#etcd
- https://etcd.io/docs/v3.3/learning/

## k8s.etcd.space

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-apiserver-etcd?tabs=resource-specific#cause-2-an-offending-client-leaks-etcd-objects-and-results-in-a-slowdown-of-etcd
- https://github.com/Azure/aks-engine/blob/master/examples/largeclusters/README.md: The current recommended maximum for etcd's storage size limit is 8GB
- https://etcd.io/docs/v3.3/dev-guide/limit/#storage-size-limit: The default storage size limit is 2GB, configurable with --quota-backend-bytes flag. 8GB is a suggested maximum size for normal environments and etcd warns at startup if the configured value exceeds it.
- https://aws.amazon.com/blogs/containers/managing-etcd-database-size-on-amazon-eks-clusters/

## k8s.etcd.space.kyverno

- https://kyverno.io/docs/troubleshooting/#admission-reports-are-stacking-up
- https://github.com/kyverno/kyverno/blob/main/docs/dev/troubleshooting/reports.md
- https://github.com/kyverno/KDP/pull/51
