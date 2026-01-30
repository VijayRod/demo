# Containerd file descriptor limits (Ubuntu 24.04)

Configure `LimitNOFILE` and `LimitNOFILESoft` for containerd on Ubuntu 24.04 nodes to ensure pods inherit the correct open file limits.

## Summary

Ubuntu 24.04 nodes default to `LimitNOFILESoft=1024`, causing pods to inherit insufficient file descriptor limits and potentially fail with "too many open files" errors. The expected behavior is `LimitNOFILE=1048576` (hard limit) and `LimitNOFILESoft=1048576` (soft limit), matching Ubuntu 22.04+ defaults so pods inherit `ulimit -n 1048576`. This can be configured using a Kubernetes DaemonSet.

> **⚠️ Important:** Test this solution in a **development/staging environment** before deploying to production. The DaemonSet restarts containerd on all matching nodes, which may cause temporary pod disruptions.

## Problem

Ubuntu 24.04 nodes ship with `LimitNOFILESoft=1024` (default), but to match Ubuntu 22.04+ behavior and ensure proper pod resource limits, this should be `1048576`.

**Without this fix:**
- Pods inherit `ulimit -n 1024` from containerd
- Applications may fail with "too many open files" errors

**With this fix:**
- Pods inherit `ulimit -n 1048576` (systemd LimitNOFILE soft limit)
- Consistent behavior across Ubuntu versions

## Quick Start

```bash
kubectl apply -f daemonset.yaml

# Verify deployment
kubectl get daemonset set-nofile-soft-ubuntu2404
kubectl get pods -l app=set-nofile-soft-ubuntu2404
kubectl logs -f -l app=set-nofile-soft-ubuntu2404
```

Expected pod status:

```bash
$ kubectl get pods -l app=set-nofile-soft-ubuntu2404
NAME                               READY   STATUS    RESTARTS   AGE
set-nofile-soft-ubuntu2404-7w5tc   1/1     Running   0          2m
set-nofile-soft-ubuntu2404-f4hbg   1/1     Running   0          2m
set-nofile-soft-ubuntu2404-pssvd   1/1     Running   0          2m
```

## Verification

Check that the limits are properly set on a pod:

```bash
kubectl run -it --rm --restart=Never test-pod --image=busybox -- sh
/ # ulimit -a | grep "open files"
# Expected: open files (-n) 1048576
```

Or directly on the node:

```bash
kubectl debug node/<NODE> -it --image=ubuntu:24.04 -- chroot /host systemctl show containerd -p LimitNOFILE -p LimitNOFILESoft
# Expected:
# LimitNOFILE=1048576
# LimitNOFILESoft=1048576
```

## Configuration

Edit `daemonset.yaml` to change values:

```yaml
HARD_DESIRED=1048576      # Hard limit
SOFT_DESIRED=1048576      # Soft limit
```

## Node Selector

Targets:
- OS: `Ubuntu2404`
- Mode: `user` nodes

Modify in `daemonset.yaml` if needed:

```yaml
nodeSelector:
  kubernetes.azure.com/os-sku-effective: Ubuntu2404
  kubernetes.azure.com/mode: user
```

## Troubleshooting

### Check pod status

```bash
kubectl get pods -l app=set-nofile-soft-ubuntu2404 -o wide
```

### View pod logs

```bash
kubectl logs <POD_NAME>
```

Expected output:
```
[INFO] before: soft=1024 hard=524288
[CHANGE] hard: 524288 → 1048576, soft: 1024 → 1048576
[WRITE] /host/etc/systemd/system/containerd.service.d/99-nofile.conf
[APPLIED] daemon-reload + restart containerd
[AFTER] systemd values:
LimitNOFILE=1048576
LimitNOFILESoft=1048576
[DONE] Configuration complete. Pod will sleep indefinitely.
```

### Pod stuck in `Running` state

Normal behavior. Pod completes configuration and sleeps indefinitely to maintain DaemonSet presence.

### Limits not applied

Check logs for errors:
```bash
kubectl logs <POD_NAME> | grep -i error
```

### Verify on host

```bash
cat /etc/systemd/system/containerd.service.d/99-nofile.conf
systemctl show containerd -p LimitNOFILE -p LimitNOFILESoft
```

Expected output:

```bash
root@aks-np24-84341029-vmss000001:/# cat /etc/systemd/system/containerd.service.d/99-nofile.conf
[Service]
LimitNOFILE=1048576:1048576

root@aks-np24-84341029-vmss000001:/# systemctl show containerd -p LimitNOFILE -p LimitNOFILESoft
LimitNOFILE=1048576
LimitNOFILESoft=1048576
```

## References

- [AgentBaker containerd.service](https://github.com/Azure/AgentBaker/blob/main/parts/linux/cloud-init/artifacts/containerd.service) - Reference for permanent VHD configuration
