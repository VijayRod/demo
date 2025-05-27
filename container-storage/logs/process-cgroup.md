## process-cgroup (control group)

```
stat -fc %T /sys/fs/cgroup/ # Returns 'tmpfs' if cgroupv1 is enabled, and 'cgroup2fs' if cgroupv2 is enabled
```

- https://lwn.net/Kernel/Index/#Control_groups
- https://kubernetes.io/docs/concepts/architecture/cgroups/
  
## process-cgroup.v2

- https://github.com/Azure/AKS/blob/master/examples/cgroups/revert-cgroup-v1.yaml
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/aks-increased-memory-usage-cgroup-v2: Cgroup v2 is now the default cgroup version for Kubernetes 1.25 on AKS.
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/aks-memory-saturation-after-upgrade: Beginning in the release of Kubernetes 1.25, the cgroup version 2 API has reached general availability (GA). AKS now uses Ubuntu Linux version 22.04. By default, version 22.04 uses cgroup version 2 API.

```
kubectl describe no
  Warning  CgroupV1                 8m29s                  kubelet          Cgroup v1 support is in maintenance mode, please migrate to Cgroup v2.
```
