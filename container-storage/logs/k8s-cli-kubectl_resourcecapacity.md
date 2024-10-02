```
kubectl krew install resource-capacity

kubectl resource-capacity
NODE                                CPU REQUESTS   CPU LIMITS      MEMORY REQUESTS   MEMORY LIMITS
*                                   2224m (19%)    11494m (100%)   1720Mi (4%)       17270Mi (49%)
aks-nodepool1-37645347-vmss000006   310m (16%)     500m (26%)      220Mi (3%)        2162Mi (37%)
aks-nodepool1-37645347-vmss000007   310m (16%)     500m (26%)      220Mi (3%)        2162Mi (37%)
...
```

```
kubectl resource-capacity --util --sort cpu --node-labels kubernetes.azure.com/agentpool=nodepool1 --pod-count
NODE                                CPU REQUESTS   CPU LIMITS      CPU UTIL    MEMORY REQUESTS   MEMORY LIMITS   MEMORY UTIL    POD COUNT
*                                   2224m (19%)    11494m (100%)   817m (7%)   1720Mi (4%)       17270Mi (49%)   6815Mi (19%)   37/660
aks-nodepool1-37645347-vmss000006   310m (16%)     500m (26%)      139m (7%)   220Mi (3%)        2162Mi (37%)    1120Mi (19%)   5/110
...

kubectl resource-capacity --util --sort memory --node-labels kubernetes.azure.com/agentpool=nodepool1 --pod-count
```

- https://github.com/robscott/kube-capacity
