## process-cgroup (control group)

```
stat -fc %T /sys/fs/cgroup/ # Returns 'tmpfs' if cgroupv1 is enabled, and 'cgroup2fs' if cgroupv2 is enabled
```

- https://lwn.net/Kernel/Index/#Control_groups

## process-cgroup.k8s

- https://github.com/Azure/AKS/blob/master/examples/cgroups/revert-cgroup-v1.yaml
- https://kubernetes.io/docs/concepts/architecture/cgroups/
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/aks-increased-memory-usage-cgroup-v2
