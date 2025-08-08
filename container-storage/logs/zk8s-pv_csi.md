```
# k8s.csi
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/kubelet/volumemanager/volume_manager.go
- https://github.com/kubernetes/kubernetes/blob/master/pkg/volume/csi/csi_attacher.go

```
# k8s.csi.driver
# p: different types of workloads, including read-heavy workloads and the strategies used to optimize them

Volume
├── Ephemeral
│   └── emptyDir
│       ├── Type: File (tmpfs or node disk)
│       ├── Mounted on node: e.g., /dev/sda or tmpfs
│       ├── Exposed to pod: via bind mount
│       ├── Driver: internal (built-in, no CSI)
│       └── Mount command (by kubelet): mount -t tmpfs tmpfs /var/lib/kubelet/pods/...
│
├── Persistent (PV + PVC)
│
│   ├── Filesystem (volumeMode: Filesystem)
│   │
│   │   ├── azurefile (in-tree)
│   │   │   ├── Type: File (SMB/NFS)
│   │   │   ├── Mounted on node: network path
│   │   │   ├── Driver: kubernetes.io/azure-file
│   │   │   ├── Exposed to pod: /mnt/volume (bind mount)
│   │   │   └── Mount example: mount -t cifs //<storage>.file.core.windows.net/share /mnt/volume -o username=...,password=...
│   │
│   │   ├── azurefile (CSI)
│   │   │   ├── Type: File (SMB/NFS)
│   │   │   ├── Mounted on node: network path
│   │   │   ├── Driver: file.csi.azure.com
│   │   │   ├── Exposed to pod: /mnt/volume
│   │   │   └── Mount example: same as in-tree (CSI does mounting logic)
│   │
│   │   ├── azuredisk (in-tree)
│   │   │   ├── Type: Block (mounted as FileSystem)
│   │   │   ├── Mounted on node: /dev/sdb
│   │   │   ├── Driver: kubernetes.io/azure-disk
│   │   │   ├── kubelet runs: mkfs.ext4 /dev/sdb; mount /dev/sdb /mnt/data
│   │   │   └── Exposed to pod: /mnt/data (bind mount)
│   │
│   │   ├── azuredisk (CSI)
│   │   │   ├── Type: Block (mounted as FileSystem)
│   │   │   ├── Mounted on node: /dev/sdc
│   │   │   ├── Driver: disk.csi.azure.com
│   │   │   ├── kubelet runs: mkfs.ext4 /dev/sdc; mount /dev/sdc /mnt/data
│   │   │   └── Exposed to pod: /mnt/data
│   │
│   │   ├── azureblob (blobfuse2 CSI)
│   │   │   ├── Type: Object (simulated FileSystem via FUSE)
│   │   │   ├── Mounted on node: FUSE mount (no block device)
│   │   │   ├── Driver: blob.csi.azure.com
│   │   │   ├── Exposed to pod: /mnt/blob
│   │   │   └── Mount command (internal): blobfuse2 mount /mnt/blob --container-name=... --config-file=...
│   │
│   │   └── azure blob via NFS 3.0 (external to Kubernetes)
│   │       ├── Type: Object (exposed as NFS)
│   │       ├── Mounted manually on node (outside K8s)
│   │       ├── Exposed to pod: 
│   │       ├── Not a Kubernetes volume type
│   │       └── Mount command: mount -t nfs <account>.blob.core.windows.net:/<container> /mnt/blobnfs
│
│   └── Block (volumeMode: Block)
│       └── azuredisk (CSI only)
│           ├── Type: Block (raw device)
│           ├── Mounted directly in pod: /dev/sdd
│           ├── Not mounted on node
│           ├── Driver: disk.csi.azure.com
│           ├── kubelet: passes device, no mkfs
│           └── Mount handled by app in pod (e.g., LVM, raw access)
│
├── Azure Container Storage (CSI platform)
│   └── azuredisk (Container Storage, managed)
│       ├── Type: Block or Filesystem
│       ├── Mounted on node: same as CSI azuredisk (e.g., /dev/sde)
│       ├── Driver: containerstorage.azure.com
│       ├── Mounts: mkfs + mount (FS mode), raw pass-through (Block mode)
│       └── Features: snapshots, replication (future), scalable
│
└── Other
    ├── ConfigMap / Secret
    │   ├── Type: File
    │   ├── Mounted on node: tmpfs
    │   ├── Exposed to pod: /etc/config (or custom path)
    │   └── Mount command (internal): tmpfs + file injection
    ├── CSI Ephemeral
    │   ├── Type: Depends on driver
    │   ├── Mounted on node
    │   └── Usually inline volume, managed by CSI logic
    └── Downward API / Projected
        ├── Type: File (metadata injection)
        └── Mounted by Kubelet into pod path (read-only)

```

- Here is the list of supported storage drivers. All other drivers, including those maintained by Microsoft employees, are not supported by the AKS or the Azure Container Storage team and are generally supported online in their repository:
  - Azure Blob Storage CSI driver (blobfuse2, nfs) - https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi
  - Azure Disk CSI driver (iscsi, nvme for ultra disk) - https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi
  - Azure File CSI driver (cifs for linux / smb for windows, nfs) - https://learn.microsoft.com/en-us/azure/aks/azure-files-csi
  - Azure Container Storage driver with Azure Disk - https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disk
  - Azure Container Storage driver with Elastic SAN - https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san
  - Azure Container Storage driver with Ephemeral Disk NVMe - https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk
  - Azure Container Storage driver with Ephemeral Disk Temp SSD - https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk

- Other supported CSI drivers include the following:
  - refer to secretsstore (csi driver)

- Examples of drivers that are not supported include:
  - https://github.com/kubernetes-csi/csi-driver-nfs (Andy)
  - https://github.com/kubernetes-sigs/azuredisk-csi-driver/ (Andy)
  - https://github.com/kubernetes-sigs/azurefile-csi-driver/ (Andy)
  - https://github.com/kubernetes-sigs/blob-csi-driver (Andy)

- Kernel:
  - fs: https://man7.org/linux/man-pages/man5/filesystems.5.html
  - fs.mount: https://man7.org/linux/man-pages/man8/mount.8.html
  - fstype.ext4: https://man7.org/linux/man-pages/man5/ext4.5.html
  - fstype.fuse: https://man7.org/linux/man-pages/man4/fuse.4.html, https://man7.org/linux/man-pages/man8/mount.fuse3.8.html
  - fstype.nfs: https://man7.org/linux/man-pages/man5/nfs.5.html
  - fstype.xfs: https://www.man7.org/linux/man-pages/man8/mkfs.xfs.8.html, https://man7.org/linux/man-pages/man5/xfs.5.html

- Blob:
  - refer to storage blob
  - refer to blob/blobfuse2
  - https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/csi-debug.md  
  - https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/mounting-azure-blob-storage-container-fail
  - https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-abfs-driver#the-azure-blob-file-system-driver
  - nfs: https://learn.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support-how-to
    - mountOptions: https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#storage-class-using-nfs-protocol
    - https://deepwiki.com/kubernetes-sigs/blob-csi-driver/6.3-volume-mount-options#nfs-mount-options

- Blob/blobfuse2 aka fuse driver:
  - "blobfuse2 mount" sets up a virtual fs mountpoint in memory using FUSE (Filesystem in Userspace).
    - examples of virtual filesystems include tmpfs, proc, sysfs, and fuse (e.g., blobfuse)    
  - blobfuse2/fuse driver: https://github.com/Azure/azure-storage-fuse/blob/main/TSG.md
  - driver-parameters/mountOptions
  - p: full table mapping showing how Blobfuse2 config options, such as disable-writeback-cache, correspond to Azure CSI StorageClass mountOptions like "-o direct_io"
  - p: mount options for read-heavy workloads
  - https://github.com/Azure/azure-storage-fuse/tree/main: Blobfuse2 - A Microsoft supported Azure Storage FUSE driver
  - https://learn.microsoft.com/en-us/azure/storage/blobs/blobfuse2-troubleshooting
  - https://github.com/Azure/azure-storage-fuse?tab=readme-ov-file#frequently-asked-questions
  - fuse driver errors: https://github.com/Azure/azure-storage-fuse/blob/main/cmd/mount.go
  - https://docs.azure.cn/en-us/storage/blobs/blobfuse2-configuration
  - https://github.com/Azure/azure-storage-fuse/blob/main/docker/Dockerfile
  - https://github.com/Azure/azure-storage-fuse/tree/main?tab=readme-ov-file#cli-parameters
  - https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/example/pv-blobfuse-csi.yaml
  - https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/example/storageclass-blobfuse2.yaml
  - https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md
  - https://github.com/kubernetes-sigs/blob-csi-driver/issues/1657#issuecomment-2455192586: to disable all cache options
  - https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#storage-class-using-blobfuse, 
  - https://learn.microsoft.com/en-us/azure/storage/blobs/blobfuse2-commands-mount#flags-that-apply-only-to-the-blobfuse2-mount-command
  - https://learn.microsoft.com/en-us/azure/storage/blobs/blobfuse2-how-to-deploy?tabs=RHEL#how-to-configure-blobfuse2
  - https://techcommunity.microsoft.com/blog/azurepaasblog/how-to-troubleshoot-blobfuse2-issues/4110844
  - https://deepwiki.com/kubernetes-sigs/blob-csi-driver/6.3-volume-mount-options#blobfuse-v1-and-v2-mount-options
  - https://deepwiki.com/kubernetes-sigs/blob-csi-driver/6.2-storage-class-options
  - https://deepwiki.com/Azure/azure-storage-fuse/3-configuration

- Disk:
  - default file system is ext4: use mkfs.ext4 /dev/sdc, then mount /dev/sdc /mnt/data. 
    - this can be changed to other file systems with pv.csi.fstype=xfs, ntfs, btrfs, ntfs, fat32
      - note that this is a real, physical fs, such as HDD, SSD, VHD, etc.
  - https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/csi-debug.md
  - https://github.com/andyzhangx/demo/blob/master/issues/azuredisk-issues.md#25-multi-attach-error
  - https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/fail-to-mount-azure-disk-volume

- File:
  - https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/csi-debug.md
  - https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/fail-to-mount-azure-file-share
  - https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/files/connectivity/files-troubleshoot?tabs=powershell

- cifs/smb: curl -kv http://redacted.privatelink.file.core.windows.net:445 # curl: (52) Empty reply from server
    
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
