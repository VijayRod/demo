```
# k8s.csi
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/volume/csi/csi_attacher.go

```
# k8s.csi.driver
```
- Here is the list of supported storage drivers. All other drivers, including those maintained by Microsoft employees, are not supported by the AKS or the Azure Container Storage team and are generally supported online in their repository:
  - Azure Blob Storage CSI driver - https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi
    - https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/csi-debug.md
    - https://learn.microsoft.com/en-us/azure/storage/blobs/blobfuse2-troubleshooting
  - Azure Disk CSI driver - https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi
    - https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/csi-debug.md
    - https://github.com/andyzhangx/demo/blob/master/issues/azuredisk-issues.md#25-multi-attach-error
  - Azure File CSI driver - https://learn.microsoft.com/en-us/azure/aks/azure-files-csi
    - https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/csi-debug.md
  - Azure Container Storage driver with Azure Disk - https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disk
  - Azure Container Storage driver with Elastic SAN - https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san
  - Azure Container Storage driver with Ephemeral Disk NVMe - https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk
  - Azure Container Storage driver with Ephemeral Disk Temp SSD - https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk


- Examples of drivers that are not supported include:
  - https://github.com/kubernetes-csi/csi-driver-nfs (Andy)
  - https://github.com/kubernetes-sigs/azuredisk-csi-driver/ (Andy)
  - https://github.com/kubernetes-sigs/azurefile-csi-driver/ (Andy)
  - https://github.com/kubernetes-sigs/blob-csi-driver (Andy)

```
# k8s.csi.sidecar
```
- https://kubernetes-csi.github.io/docs/sidecar-containers.html

```
# k8s.csi.sidecar.external-attacher
```
- https://github.com/kubernetes-csi/external-attacher

```
# k8s.csi.mount.tmpmounts
# syslog contains /containerd/tmpmounts
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/volume/util/fsquota/common/quota_common_linux_impl.go: // Extract the mountpoint we care about into a temporary mounts file so that xfs_quota does
// not attempt to scan every mount on the filesystem, which could hang if e. g.
- https://github.com/containerd/containerd/blob/main/core/mount/temp.go: containerd-mount

```
# k8s.csi.mount.tmpmounts.failed to unmount target /var/lib/rancher/rke2/agent/containerd/tmpmounts/containerd-mount490508934: device or resource busy: unknown
# /var/lib/containerd/tmpmounts

# https://github.com/containerd/containerd/issues/10239#issuecomment-2224344071
kubectl get ds -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,VOLUMES:.spec.template.spec.volumes[*].hostPath.path"
NAMESPACE       NAME                                  VOLUMES
ingress-nginx   nginx-ingress-controller-internal     /var/lib/observability/nginx.conf
monitoring      datadog                               /proc,/sys/fs/cgroup,/etc/os-release,/etc/redhat-release,/etc/fedora-release,/etc/lsb-release,/etc/system-release,/var/lib/kubelet/seccomp,/sys/kernel/debug,/lib/modules,/usr/src,/var/tmp/datadog-agent/system-probe/build,/var/tmp/datadog-agent/system-probe/kernel-headers,/etc/apt,/etc/yum.repos.d,/etc/zypp,/etc/pki,/etc/yum/vars,/etc/dnf/vars,/etc/rhsm,/etc/passwd,/,/var/lib/datadog-agent/logs,/var/log/pods,/var/log/containers,/var/lib/docker/containers,/var/run
monitoring      monitoring-prometheus-node-exporter   /proc,/sys,/

#  subtle / in the datadog mount list
kubectl describe po
  procdir:
    Type:          HostPath (bare host directory volume)
    Path:          /proc
    HostPathType:  
  cgroups:
    Type:          HostPath (bare host directory volume)
    Path:          /sys/fs/cgroup
    HostPathType:
  hostroot:
    Type:          HostPath (bare host directory volume)
    Path:          /
    HostPathType:  
```

- https://github.com/containerd/containerd/issues/5538: Pulling image fails - failed to unmount temp mount - device or resource busy: unknown. security scans were the problem
- https://github.com/containerd/containerd/issues/10690: crictl pull image failed: failed to extract layer & failed to unmount target & device or resource busy: unknown. It works after close the Security Software.
  - failed to unmount target /var/lib/rancher/rke2/agent/containerd/tmpmounts/containerd-mount490508934: device or resource busy: unknown"
- https://github.com/containerd/containerd/issues/10239#issuecomment-2224344071: ImagePull failure - can't unmount tmpmount. kubectl get ds -A...  subtle / in the datadog mount list
