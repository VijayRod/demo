```
# k8s.csi
```

- https://github.com/kubernetes-csi/external-attacher
- https://github.com/kubernetes/kubernetes/blob/master/pkg/volume/csi/csi_attacher.go

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
