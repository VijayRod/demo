## process-cgroup (control group)

```
stat -fc %T /sys/fs/cgroup/ # Returns 'tmpfs' if cgroupv1 is enabled, and 'cgroup2fs' if cgroupv2 is enabled
```

- https://lwn.net/Kernel/Index/#Control_groups
- https://kubernetes.io/docs/concepts/architecture/cgroups/
  
## process-cgroup.v2

- https://github.com/Azure/AKS/blob/master/examples/cgroups/revert-cgroup-v1.yaml
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/aks-increased-memory-usage-cgroup-v2

```
kubectl describe no
  Warning  CgroupV1                 8m29s                  kubelet          Cgroup v1 support is in maintenance mode, please migrate to Cgroup v2.
```
