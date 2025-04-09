> ## k8snode.log.aks-log-collector

- https://github.com/Azure/AgentBaker/blob/master/parts/linux/cloud-init/artifacts/aks-log-collector.sh

> ## k8snode.log.azure-diskinspect-service

- https://github.com/Azure/azure-diskinspect-service/blob/master/manifests/linux/aks

## Cluster Autoscaler

```
# Adds/removes nodes dynamically - Use cluster-autoscaler --nodes=1:10
```
  
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
