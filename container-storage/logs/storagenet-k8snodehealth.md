## Cluster Autoscaler

```
# Adds/removes nodes dynamically - Use cluster-autoscaler --nodes=1:10
```

## k8s.cri.containerd

```
# for example, /containerd/blob/main/core/mount/temp.go
```

```
# containerd.error.failed to remove mount temp dir
# syslog
```

- https://github.com/containerd/containerd/blob/main/core/mount/temp.go: os.MkdirTemp(tempMountLocation, "containerd-mount"). Error("failed to remove mount temp dir")
  
## Eviction Manager

```
# Reschedules pods from failing nodes - Set Pod Disruption Budgets (PDBs)
```

## Kubelet Health Check

```
# Detects node failures - Reduce node-status-update-frequency for faster detection
```

```
# aks - Node Auto-Repair
# Auto-replaces unhealthy nodes
```

- https://learn.microsoft.com/en-us/azure/aks/node-auto-repair#how-automatic-repair-works
  
```
# aws
```

- https://docs.aws.amazon.com/eks/latest/userguide/node-health.html

## Kubelet Self-Recovery

```
# Auto-restarts unhealthy Kubelet - Ensure systemctl enable kubelet
```

## Metrics Server

```
# Monitors CPU & memory usage - Deploy metrics-server for real-time health checks
```

## Node Draining

```
# Safe pod eviction during maintenance - Use kubectl drain before updates
```

## Node Problem Detector (NPD)

```
# Monitors OS & hardware failures - Deploy as a DaemonSet for real-time node monitoring
```

## Taint-Based Recovery

```
# Prevents scheduling on failed nodes - Use tolerations for critical workloads
```
