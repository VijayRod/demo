This uses `kubectl get --raw` from https://learn.microsoft.com/en-us/azure/aks/kubelet-logs to retrieve kubelet logs.

```
# List available logs with the corresponding node name. This command is compatible with both Linux and Windows nodes.
kubectl get --raw "/api/v1/nodes/aksnp2019000006/proxy/logs"

# Sample commands for a Linux node.
kubectl get --raw "/api/v1/nodes/aks-nodepool1-51397738-vmss000004/proxy/logs/syslog"|grep kubelet
kubectl get --raw "/api/v1/nodes/aks-nodepool1-51397738-vmss000004/proxy/logs/syslog.1"|grep kubelet
kubectl get --raw "/api/v1/nodes/aks-nodepool1-51397738-vmss000004/proxy/logs/azure/custom-script/handler.log"
```

- https://learn.microsoft.com/en-us/azure/aks/kubelet-logs
- https://kubernetes.io/docs/concepts/cluster-administration/system-logs/
